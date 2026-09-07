import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/api/api_client.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/services/app_settings_service.dart';
import 'core/services/apple_iap_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/notifications/presentation/cubit/unread_notifications_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  final authCubit = sl<AuthCubit>();
  sl<ApiClient>().onUnauthorized = authCubit.forceLogout;

  // StoreKit can redeliver unfinished transactions from a previous launch.
  // Listen before building any purchase UI so none of those updates are lost.
  final appleIap = sl<AppleIapService>()..start();

  final router = buildAppRouter();

  // Push notifications require a Firebase project (google-services.json /
  // GoogleService-Info.plist + `flutterfire configure`) — guarded so the
  // app runs normally without it until that's wired up.
  PushNotificationService? pushService;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    pushService = sl<PushNotificationService>();
    await pushService.initMessaging(router: router);
  } catch (e) {
    if (kDebugMode) {
      debugPrint(
        'Push notifications unavailable (Firebase not configured yet): $e',
      );
    }
  }

  // `/device-token` is a protected route, so only register it once the
  // student is actually authenticated — never at cold-start.
  if (pushService != null) {
    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      if (authCubit.state is AuthAuthenticated) pushService?.registerToken();
    });
  }

  final unreadCubit = sl<UnreadNotificationsCubit>();
  authCubit.stream.listen((state) {
    if (state is AuthAuthenticated) {
      unreadCubit.refresh();
      pushService?.registerToken();
      appleIap.retryUnverifiedPurchases();
    } else if (state is AuthUnauthenticated) {
      unreadCubit.reset();
    }
  });

  runApp(BahethApp(router: router));
}

class BahethApp extends StatefulWidget {
  final GoRouter router;
  const BahethApp({super.key, required this.router});

  @override
  State<BahethApp> createState() => _BahethAppState();
}

class _BahethAppState extends State<BahethApp> with WidgetsBindingObserver {
  late final AppSettingsService _appSettings = sl<AppSettingsService>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appSettings.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _appSettings.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: AppSettingsScope(
        service: _appSettings,
        child: MaterialApp.router(
          title: 'الباحث الأكاديمي',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.light,
          routerConfig: widget.router,
          builder: (context, child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
        ),
      ),
    );
  }
}
