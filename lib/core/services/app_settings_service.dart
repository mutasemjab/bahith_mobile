import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

/// Holds the remotely controlled commerce visibility used across the app.
///
/// The safe default is hidden: if the public settings request fails, no price,
/// discount, purchase, voucher, or activation entry point is exposed.
class AppSettingsService extends ChangeNotifier {
  final ApiClient _api;

  bool _remoteShowCommerce = false;
  bool _refreshing = false;

  AppSettingsService(this._api);

  /// The backend kill switch controls whether commerce entry points appear.
  /// iOS uses StoreKit while the other platforms keep card-code activation.
  bool get showCommerce => commerceVisibleFor(
    remoteEnabled: _remoteShowCommerce,
    isIOS: !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS,
  );

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;

    var nextValue = false;
    try {
      final response = await _api.get(ApiEndpoints.appSettings);
      nextValue = parseShowPriceSetting(response.data);
    } catch (_) {
      // Fail closed for App Store compliance if the setting cannot be loaded.
      nextValue = false;
    } finally {
      _refreshing = false;
    }

    if (_remoteShowCommerce == nextValue) return;
    _remoteShowCommerce = nextValue;
    notifyListeners();
  }

  @visibleForTesting
  static bool commerceVisibleFor({
    required bool remoteEnabled,
    required bool isIOS,
  }) => remoteEnabled;

  @visibleForTesting
  static bool parseShowPriceSetting(dynamic responseBody) {
    if (responseBody is! Map) return false;
    if (responseBody['status'] != true) return false;
    final data = responseBody['data'];
    if (data is! Map) return false;
    return int.tryParse(data['show_price']?.toString() ?? '') == 1;
  }
}

/// Makes [AppSettingsService] reactive without coupling presentation code to
/// a specific state-management package.
class AppSettingsScope extends InheritedNotifier<AppSettingsService> {
  const AppSettingsScope({
    super.key,
    required AppSettingsService service,
    required super.child,
  }) : super(notifier: service);

  static AppSettingsService of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope is missing above this context');
    return scope!.notifier!;
  }
}
