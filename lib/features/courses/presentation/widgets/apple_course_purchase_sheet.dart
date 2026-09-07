import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/services/apple_iap_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

Future<void> showAppleCoursePurchaseSheet({
  required BuildContext context,
  required int courseId,
  required VoidCallback onPurchased,
}) {
  if (!AppleIapService.isSupportedPlatform) return Future<void>.value();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: (_) =>
        _AppleCoursePurchaseSheet(courseId: courseId, onPurchased: onPurchased),
  );
}

class _AppleCoursePurchaseSheet extends StatefulWidget {
  final int courseId;
  final VoidCallback onPurchased;

  const _AppleCoursePurchaseSheet({
    required this.courseId,
    required this.onPurchased,
  });

  @override
  State<_AppleCoursePurchaseSheet> createState() =>
      _AppleCoursePurchaseSheetState();
}

class _AppleCoursePurchaseSheetState extends State<_AppleCoursePurchaseSheet> {
  final AppleIapService _iap = sl<AppleIapService>();
  ProductDetails? _product;
  StreamSubscription<AppleIapEvent>? _subscription;
  bool _loading = true;
  bool _busy = false;
  String? _status;
  String? _error;

  String get _productId => AppleIapProductIds.forCourse(widget.courseId);

  @override
  void initState() {
    super.initState();
    _subscription = _iap.events.listen(_onPurchaseEvent);
    _loadProduct();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await _iap.loadCourseProduct(courseId: widget.courseId);
      if (!mounted) return;
      setState(() {
        _product = product;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _messageFor(error);
      });
    }
  }

  String? _appAccountToken() {
    final auth = context.read<AuthCubit>().state;
    return auth is AuthAuthenticated ? auth.student.appAccountToken : null;
  }

  Future<void> _buy() async {
    final product = _product;
    var accountToken = _appAccountToken();
    if (product == null) return;

    if (accountToken == null || accountToken.isEmpty) {
      setState(() {
        _busy = true;
        _error = null;
        _status = 'جارٍ تحديث بيانات الحساب…';
      });
      accountToken = await context.read<AuthCubit>().refreshAppAccountToken();
      if (!mounted) return;
    }

    if (accountToken == null || accountToken.isEmpty) {
      setState(() {
        _busy = false;
        _status = null;
        _error =
            'تعذر تجهيز الحساب للشراء من App Store. تحقق من الاتصال ثم حاول مرة أخرى.';
      });
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _status = 'جارٍ فتح App Store…';
    });
    try {
      await _iap.buyCourse(
        courseId: widget.courseId,
        product: product,
        appAccountToken: accountToken,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = null;
        _error = _messageFor(error);
      });
    }
  }

  Future<void> _restore() async {
    setState(() {
      _busy = true;
      _error = null;
      _status = 'جارٍ استعادة مشتريات App Store…';
    });
    try {
      await _iap.restorePurchases();
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _status = null;
        _error = _messageFor(error);
      });
    }
  }

  void _onPurchaseEvent(AppleIapEvent event) {
    if (!mounted ||
        event.productId != _productId ||
        event.courseId != widget.courseId) {
      return;
    }
    switch (event.type) {
      case AppleIapEventType.pending:
        setState(() {
          _busy = true;
          _error = null;
          _status = event.message;
        });
      case AppleIapEventType.verified:
        Navigator.of(context).pop();
        widget.onPurchased();
      case AppleIapEventType.canceled:
        setState(() {
          _busy = false;
          _status = null;
        });
      case AppleIapEventType.failed:
        setState(() {
          _busy = false;
          _status = null;
          _error = event.message ?? 'تعذر إكمال عملية الشراء.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'شراء الدورة من App Store',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (product != null) ...[
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (product.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'دفعة واحدة · وصول دائم',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      product.price,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_status != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 9),
                  Expanded(child: Text(_status!)),
                ],
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColors.accent, fontSize: 13),
                ),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: !_busy && product != null ? _buy : null,
              icon: const Icon(Icons.lock_open_rounded),
              label: Text(
                product == null ? 'شراء الدورة' : 'شراء مقابل ${product.price}',
                textDirection: TextDirection.rtl,
              ),
            ),
            TextButton.icon(
              onPressed: !_busy ? _restore : null,
              icon: const Icon(Icons.restore_rounded),
              label: const Text('استعادة المشتريات'),
            ),
            if (!_loading && product == null)
              TextButton(
                onPressed: _loadProduct,
                child: const Text('إعادة المحاولة'),
              ),
            const Text(
              'دفعة واحدة لكل دورة مع وصول دائم. يمكنك استعادة مشترياتك على أجهزتك بعد تسجيل الدخول إلى الحساب نفسه.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(Object error) => error is AppleIapException
      ? error.message
      : 'حدث خطأ غير متوقع. حاول مرة أخرى.';
}
