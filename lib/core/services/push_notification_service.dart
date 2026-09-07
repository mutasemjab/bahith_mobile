import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/cubit/unread_notifications_cubit.dart';

/// Top-level background handler required by firebase_messaging — must run
/// outside any class and re-initialize Firebase since it executes in its
/// own isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // No UI work needed: the OS already shows the notification for payloads
  // that include a `notification` block while the app is backgrounded.
}

/// Registers the device's FCM token with the backend, shows a local
/// notification while the app is in the foreground (FCM does this
/// automatically in background/terminated states), and routes taps to the
/// notifications screen.
///
/// Split into two entry points on purpose: [initMessaging] wires up
/// permissions/listeners once at app startup (no auth needed), while
/// [registerToken] must be called only once the student is actually
/// logged in — `/device-token` is a protected route, so calling it before
/// login would either 401 or register a token with no student attached.
class PushNotificationService {
  final NotificationRepository _repository;
  final UnreadNotificationsCubit _unreadCubit;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _listenersReady = false;

  static const _channel = AndroidNotificationChannel(
    'baheth_default',
    'إشعارات عامة',
    description: 'إشعارات الباحث الأكاديمي',
    importance: Importance.high,
  );

  PushNotificationService(this._repository, this._unreadCubit);

  Future<void> initMessaging({required GoRouter router}) async {
    await FirebaseMessaging.instance.requestPermission();

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await _localNotifications.initialize(
      // `launcher_icon` is the app's own icon (generated from
      // assets/icon.png by flutter_launcher_icons) — not the default
      // Flutter template icon that `ic_launcher` would point to.
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) {
        router.push('/notifications');
        _unreadCubit.refresh();
      },
    );

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
        id: message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            // The status-bar icon set in initialize() is forced to a
            // monochrome silhouette by Android itself (API 21+) no matter
            // what image is used — the large icon is what actually shows
            // the app's real icon, in full color, in the notification body.
            largeIcon: const DrawableResourceAndroidBitmap('launcher_icon'),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
      _unreadCubit.refresh();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((_) {
      router.push('/notifications');
      _unreadCubit.refresh();
    });

    _listenersReady = true;
  }

  /// Call once the student is authenticated (and again on token refresh
  /// while still authenticated) to associate this device with their
  /// account server-side.
  Future<void> registerToken() async {
    if (!_listenersReady) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _repository.saveDeviceToken(token);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('FCM token registration failed: $e');
    }
  }
}
