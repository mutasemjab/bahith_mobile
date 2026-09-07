import 'package:baheth/core/services/apple_iap_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppleIapProductIds', () {
    test('uses one non-consumable product per course', () {
      expect(AppleIapProductIds.forCourse(1), 'com.baheth.school.course.v2.1');
      expect(AppleIapProductIds.forCourse(42), 'com.baheth.school.course.v2.42');
    });

    test('recognizes and decodes only valid course products', () {
      expect(
        AppleIapProductIds.isCourseAccess('com.baheth.school.course.v2.42'),
        isTrue,
      );
      expect(
        AppleIapProductIds.courseIdFrom('com.baheth.school.course.v2.42'),
        42,
      );
      expect(
        AppleIapProductIds.isCourseAccess('com.baheth.school.course.access'),
        isFalse,
      );
      expect(AppleIapProductIds.courseIdFrom('com.baheth.school.course.v2.0'), isNull);
      expect(AppleIapProductIds.courseIdFrom('com.baheth.school.course.v2.01'), isNull);
    });

    test('rejects a non-positive course id', () {
      expect(() => AppleIapProductIds.forCourse(0), throwsArgumentError);
    });
  });

  group('AppleIapPurchaseToken', () {
    const accountToken = '5a1b23af-bf50-4afd-9a3a-c643f32c7f81';

    test('round-trips the selected course using a valid UUID', () {
      final token = AppleIapPurchaseToken.forCourse(
        appAccountToken: accountToken,
        courseId: 42,
      );

      expect(token, matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(token, '2c6cdbad-2b37-8e8d-927d-68260000002a');
      expect(token.split('-')[2].startsWith('8'), isTrue);
      expect(AppleIapPurchaseToken.courseIdFrom(token), 42);
      expect(
        AppleIapPurchaseToken.matches(
          purchaseToken: token,
          appAccountToken: accountToken,
          courseId: 42,
        ),
        isTrue,
      );
    });

    test('produces different tokens for different courses', () {
      final first = AppleIapPurchaseToken.forCourse(
        appAccountToken: accountToken,
        courseId: 1,
      );
      final second = AppleIapPurchaseToken.forCourse(
        appAccountToken: accountToken,
        courseId: 2,
      );

      expect(first, isNot(second));
      expect(AppleIapPurchaseToken.courseIdFrom(first), 1);
      expect(AppleIapPurchaseToken.courseIdFrom(second), 2);
    });

    test('rejects malformed and non-v8 purchase tokens', () {
      expect(AppleIapPurchaseToken.courseIdFrom('not-a-uuid'), isNull);
      expect(AppleIapPurchaseToken.courseIdFrom(accountToken), isNull);
    });
  });
}
