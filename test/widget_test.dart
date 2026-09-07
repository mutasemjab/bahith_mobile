import 'package:baheth/core/services/app_settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettingsService', () {
    test('uses the remote commerce kill switch on every platform', () {
      expect(
        AppSettingsService.commerceVisibleFor(remoteEnabled: true, isIOS: true),
        isTrue,
      );
      expect(
        AppSettingsService.commerceVisibleFor(
          remoteEnabled: true,
          isIOS: false,
        ),
        isTrue,
      );
      expect(
        AppSettingsService.commerceVisibleFor(
          remoteEnabled: false,
          isIOS: true,
        ),
        isFalse,
      );
    });

    test('parses the remote commerce flag only when show_price is 1', () {
      expect(
        AppSettingsService.parseShowPriceSetting(const {
          'status': true,
          'data': {'show_price': 1},
        }),
        isTrue,
      );
      expect(
        AppSettingsService.parseShowPriceSetting(const {
          'status': true,
          'data': {'show_price': 2},
        }),
        isFalse,
      );
    });

    test('fails closed for malformed settings responses', () {
      expect(AppSettingsService.parseShowPriceSetting(null), isFalse);
      expect(
        AppSettingsService.parseShowPriceSetting(const {'status': false}),
        isFalse,
      );
      expect(
        AppSettingsService.parseShowPriceSetting(const {
          'status': false,
          'data': {'show_price': 1},
        }),
        isFalse,
      );
    });
  });
}
