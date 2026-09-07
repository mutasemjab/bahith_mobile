import 'dart:async';

import 'package:flutter/foundation.dart';

/// Bridges a [Stream] (here, [AuthCubit]'s state stream) into a
/// [Listenable] so [GoRouter] can re-evaluate redirects whenever auth
/// state changes, without polling.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
