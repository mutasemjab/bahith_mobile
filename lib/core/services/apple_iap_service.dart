import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:uuid/uuid.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

bool _isUuid(String value) => RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
).hasMatch(value);

/// Each paid course maps to its own non-consumable App Store product.
///
/// Course access is permanent and course prices differ, so sharing one product
/// would let a low-priced transaction unlock a higher-priced course.
class AppleIapProductIds {
  AppleIapProductIds._();

  static const coursePrefix = 'com.baheth.school.course.v2.';
  static const _maxCourseId = 0x7fffffff;

  static String forCourse(int courseId) {
    if (courseId <= 0 || courseId > _maxCourseId) {
      throw ArgumentError.value(
        courseId,
        'courseId',
        'must be between 1 and $_maxCourseId',
      );
    }
    return '$coursePrefix$courseId';
  }

  static int? courseIdFrom(String productId) {
    if (!productId.startsWith(coursePrefix)) return null;
    final suffix = productId.substring(coursePrefix.length);
    if (!RegExp(r'^[1-9][0-9]*$').hasMatch(suffix)) return null;
    final courseId = int.tryParse(suffix);
    return courseId != null && courseId <= _maxCourseId ? courseId : null;
  }

  static bool isCourseAccess(String productId) =>
      courseIdFrom(productId) != null;
}

/// Builds a deterministic UUID that binds an Apple transaction to both the
/// authenticated student and the selected course.
///
/// The first 12 bytes are a UUIDv5 hash of the student's permanent account
/// token. The final four bytes contain the course ID, and the UUID uses the
/// custom v8 version marker. The backend must reproduce and compare this value
/// after verifying Apple's signed transaction.
class AppleIapPurchaseToken {
  AppleIapPurchaseToken._();

  static const _context = 'com.baheth.school.course.access';
  static const _maxCourseId = 0x7fffffff;

  static String forCourse({
    required String appAccountToken,
    required int courseId,
  }) {
    if (!_isUuid(appAccountToken)) {
      throw const AppleIapException(
        'حساب الطالب غير مجهز للشراء من App Store.',
      );
    }
    if (courseId <= 0 || courseId > _maxCourseId) {
      throw const AppleIapException('معرّف الدورة غير صالح.');
    }

    final bytes = Uuid.parse(const Uuid().v5(appAccountToken, _context));
    bytes[12] = (courseId >> 24) & 0xff;
    bytes[13] = (courseId >> 16) & 0xff;
    bytes[14] = (courseId >> 8) & 0xff;
    bytes[15] = courseId & 0xff;
    bytes[6] = (bytes[6] & 0x0f) | 0x80; // RFC 9562 UUID version 8.
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC variant.
    return Uuid.unparse(bytes);
  }

  static int? courseIdFrom(String? purchaseToken) {
    if (purchaseToken == null || !_isUuid(purchaseToken)) return null;
    final bytes = Uuid.parse(purchaseToken);
    if ((bytes[6] >> 4) != 8) return null;
    final courseId =
        (bytes[12] << 24) | (bytes[13] << 16) | (bytes[14] << 8) | bytes[15];
    return courseId > 0 && courseId <= _maxCourseId ? courseId : null;
  }

  static bool matches({
    required String purchaseToken,
    required String appAccountToken,
    required int courseId,
  }) =>
      purchaseToken.toLowerCase() ==
      forCourse(
        appAccountToken: appAccountToken,
        courseId: courseId,
      ).toLowerCase();
}

enum AppleIapEventType { pending, verified, canceled, failed }

class AppleIapEvent {
  final AppleIapEventType type;
  final String productId;
  final int? courseId;
  final String? message;

  const AppleIapEvent({
    required this.type,
    required this.productId,
    required this.courseId,
    this.message,
  });
}

class AppleIapException implements Exception {
  final String message;
  const AppleIapException(this.message);

  @override
  String toString() => message;
}

/// Owns the StoreKit transaction stream for the entire app lifetime.
///
/// Successful transactions are delivered only after the authenticated API
/// verifies Apple's signed transaction and grants the matching course. Failed
/// verification deliberately leaves the StoreKit transaction unfinished so it
/// can be retried after login or after a temporary backend outage.
class AppleIapService {
  final ApiClient _api;
  final InAppPurchase _store;
  final _events = StreamController<AppleIapEvent>.broadcast();
  final _unverified = <String, PurchaseDetails>{};
  final _processing = <String>{};

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  AppleIapService(this._api, {InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance;

  static bool get isSupportedPlatform =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Stream<AppleIapEvent> get events => _events.stream;

  /// Register this listener during app bootstrap, before any purchase UI is
  /// shown, so unfinished transactions from an earlier launch are not missed.
  void start() {
    if (!isSupportedPlatform || _subscription != null) return;
    _subscription = _store.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        _events.add(
          AppleIapEvent(
            type: AppleIapEventType.failed,
            productId: '',
            courseId: null,
            message: _storeErrorMessage(error),
          ),
        );
      },
    );
  }

  Future<ProductDetails> loadCourseProduct({required int courseId}) async {
    _ensureSupported();
    start();

    final available = await _store.isAvailable();
    if (!available) {
      throw const AppleIapException(
        'متجر App Store غير متاح الآن. تحقق من اتصال الإنترنت وحساب App Store.',
      );
    }

    final id = AppleIapProductIds.forCourse(courseId);
    final response = await _store.queryProductDetails({id});
    if (response.error != null) {
      throw AppleIapException(_storeErrorMessage(response.error!));
    }
    if (response.productDetails.isEmpty || response.notFoundIDs.contains(id)) {
      throw AppleIapException(
        'لم يتم إعداد منتج هذه الدورة في App Store Connect ($id).',
      );
    }
    return response.productDetails.firstWhere((product) => product.id == id);
  }

  Future<void> buyCourse({
    required int courseId,
    required ProductDetails product,
    required String appAccountToken,
  }) async {
    _ensureSupported();
    start();

    if (product.id != AppleIapProductIds.forCourse(courseId)) {
      throw const AppleIapException('معرّف منتج الدورة غير صالح.');
    }
    final purchaseToken = AppleIapPurchaseToken.forCourse(
      appAccountToken: appAccountToken,
      courseId: courseId,
    );

    try {
      final started = await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(
          productDetails: product,
          applicationUserName: purchaseToken,
        ),
      );
      if (!started) {
        throw const AppleIapException('تعذر بدء عملية الشراء. حاول مرة أخرى.');
      }
    } on PlatformException catch (error) {
      throw AppleIapException(_storeErrorMessage(error));
    }
  }

  /// Replays the student's non-consumable StoreKit purchases through the
  /// regular verification stream so the backend can restore enrollments.
  Future<void> restorePurchases() async {
    _ensureSupported();
    start();

    final available = await _store.isAvailable();
    if (!available) {
      throw const AppleIapException(
        'متجر App Store غير متاح الآن. تحقق من اتصال الإنترنت وحساب App Store.',
      );
    }

    try {
      await _store.restorePurchases();
    } on PlatformException catch (error) {
      throw AppleIapException(_storeErrorMessage(error));
    }
  }

  /// Called when authentication becomes available, allowing transactions that
  /// arrived during the splash/login flow to be verified again.
  Future<void> retryUnverifiedPurchases() async {
    if (!isSupportedPlatform || _unverified.isEmpty) return;
    final pending = List<PurchaseDetails>.from(_unverified.values);
    for (final purchase in pending) {
      await _processVerifiedPurchase(purchase);
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      unawaited(_handlePurchase(purchase));
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    final courseId = _courseIdFrom(purchase);
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _emit(
          AppleIapEventType.pending,
          purchase,
          courseId,
          'بانتظار تأكيد الدفع من App Store…',
        );
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _processVerifiedPurchase(purchase);
      case PurchaseStatus.canceled:
        _emit(AppleIapEventType.canceled, purchase, courseId, null);
        await _completeNonDeliverablePurchase(purchase);
      case PurchaseStatus.error:
        _emit(
          AppleIapEventType.failed,
          purchase,
          courseId,
          _storeErrorMessage(purchase.error),
        );
        await _completeNonDeliverablePurchase(purchase);
    }
  }

  Future<void> _processVerifiedPurchase(PurchaseDetails purchase) async {
    final key = _transactionKey(purchase);
    if (!_processing.add(key)) return;

    final courseId = _courseIdFrom(purchase);
    if (courseId == null) {
      _emit(
        AppleIapEventType.failed,
        purchase,
        null,
        'تعذّر تحديد الدورة المرتبطة بعملية App Store.',
      );
      _processing.remove(key);
      return;
    }

    _emit(
      AppleIapEventType.pending,
      purchase,
      courseId,
      'جارٍ التحقق من عملية الشراء…',
    );

    try {
      final signedTransaction =
          purchase.verificationData.serverVerificationData;
      if (signedTransaction.isEmpty) {
        throw const AppleIapException(
          'لم يرسل App Store بيانات التحقق من عملية الشراء.',
        );
      }

      final transactionId = purchase.purchaseID;
      if (transactionId == null || transactionId.isEmpty) {
        throw const AppleIapException(
          'لم يرسل App Store رقم عملية الشراء.',
        );
      }

      final purchaseToken = _purchaseTokenFrom(purchase);
      if (purchaseToken == null || purchaseToken.isEmpty) {
        throw const AppleIapException(
          'عملية الشراء غير مرتبطة بحساب الطالب. أعد تسجيل الدخول ثم حاول الاستعادة.',
        );
      }

      final response = await _api.post(
        ApiEndpoints.verifyApplePurchase,
        data: {
          'course_id': courseId,
          'product_id': purchase.productID,
          'transaction_id': transactionId,
          'signed_transaction': signedTransaction,
          'transaction_date': purchase.transactionDate,
          'source': purchase.verificationData.source,
          'purchase_token': purchaseToken,
        },
      );
      final body = response.data;
      if (body is! Map || body['status'] != true) {
        final message = body is Map ? body['message']?.toString() : null;
        throw AppleIapException(
          message?.isNotEmpty == true
              ? message!
              : 'رفض الخادم التحقق من عملية الشراء.',
        );
      }

      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
      _unverified.remove(key);
      _emit(AppleIapEventType.verified, purchase, courseId, null);
    } catch (error) {
      _unverified[key] = purchase;
      _emit(
        AppleIapEventType.failed,
        purchase,
        courseId,
        _verificationErrorMessage(error),
      );
    } finally {
      _processing.remove(key);
    }
  }

  Future<void> _completeNonDeliverablePurchase(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return;
    try {
      await _store.completePurchase(purchase);
    } catch (_) {
      // StoreKit will redeliver an unfinished transaction on a later launch.
    }
  }

  void _emit(
    AppleIapEventType type,
    PurchaseDetails purchase,
    int? courseId,
    String? message,
  ) {
    _events.add(
      AppleIapEvent(
        type: type,
        productId: purchase.productID,
        courseId: courseId,
        message: message,
      ),
    );
  }

  void _ensureSupported() {
    if (!isSupportedPlatform) {
      throw const AppleIapException(
        'الشراء من App Store متاح على أجهزة iPhone وiPad فقط.',
      );
    }
  }

  static String? _purchaseTokenFrom(PurchaseDetails purchase) =>
      purchase is SK2PurchaseDetails ? purchase.appAccountToken : null;

  static int? _courseIdFrom(PurchaseDetails purchase) {
    return AppleIapProductIds.courseIdFrom(purchase.productID);
  }

  static String _transactionKey(PurchaseDetails purchase) =>
      purchase.purchaseID ??
      '${purchase.productID}:${purchase.transactionDate ?? purchase.verificationData.serverVerificationData.hashCode}';

  static String _storeErrorMessage(Object? error) {
    final text = error?.toString().toLowerCase() ?? '';
    if (text.contains('cancel')) return 'تم إلغاء عملية الشراء.';
    if (text.contains('network')) {
      return 'تعذر الاتصال بـ App Store. تحقق من الإنترنت ثم حاول مجدداً.';
    }
    if (text.contains('not allowed') || text.contains('payment_not_allowed')) {
      return 'عمليات الشراء غير مسموحة على هذا الجهاز.';
    }
    return 'حدث خطأ في App Store. حاول مرة أخرى.';
  }

  static String _verificationErrorMessage(Object error) {
    if (error is AppleIapException) return error.message;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        final message = (data['message'] as String).trim();
        if (message.isNotEmpty) return message;
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'تعذر الاتصال بخادم التحقق. سنحاول إكمال العملية لاحقاً.';
      }
    }
    return 'تعذر التحقق من الشراء. لن يتم خصم العملية مجدداً، وسنحاول التحقق لاحقاً.';
  }
}
