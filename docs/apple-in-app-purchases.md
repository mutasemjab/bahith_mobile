# Apple In-App Purchase setup

Paid course access is permanent and course prices differ. Every paid course
therefore uses its own **Non-Consumable** App Store product.

## Fixed contract

| Item | Value |
|---|---|
| Bundle ID | `com.baheth.school` |
| Apple team | `D7ZNW2XCPQ` |
| Minimum iOS | 15.0 |
| Product type | Non-Consumable |
| Product ID format | `com.baheth.school.course.v2.<database-course-id>` |
| Verification endpoint | `POST /api/v1/student/purchases/apple/verify` |

The rejected shared product `com.baheth.school.course.access` must not be used.
Its type/identifier cannot be repurposed, and one shared price would not match
the different course prices.

Products configured in App Store Connect on August 21, 2026:

| Course ID | Product ID | Apple ID | Course | Backend price | US base price | Status |
|---:|---|---:|---|---:|---:|---|
| 1 | `com.baheth.school.course.v2.1` | `6803670333` | الرياضيات الشامل — الصف العاشر | 25.00 JOD | $34.99 | Ready for Review |
| 2 | `com.baheth.school.course.v2.2` | `6803670514` | الفيزياء المكثّف — الصف العاشر | 20.00 JOD | $29.99 | Ready for Review |
| 3 | `com.baheth.school.course.v2.3` | `6803670349` | اللغة العربية الشامل — الصف التاسع | 18.00 JOD | $24.99 | Ready for Review |
| 4 | `com.baheth.school.course.v2.4` | `6803670576` | الكيمياء المتقدم — الصف العاشر | 22.00 JOD | $29.99 | Ready for Review |
| 5 | `com.baheth.school.course.v2.5` | `6803670774` | اللغة الإنجليزية الشامل — الصف التاسع | 15.00 JOD | $19.99 | Ready for Review |

All five products use all-region availability, Arabic localization, and a
course-specific 1320 × 2868 review screenshot stored in
`docs/app-store/screenshots/`. They are attached to the same draft submission.

Before publishing a new paid course, create its matching product and wait for
it to become available in StoreKit. The app always displays Apple's localized
price; the backend price is not displayed in the iOS purchase sheet.

## App Store Connect

For every row above:

1. Open **Apps > Baheth > Monetization > In-App Purchases**.
2. Create a **Non-Consumable** product with the exact product ID.
3. Use the course title as the reference/display name.
4. Use `وصول دائم إلى الدورة المحددة` as the Arabic description.
5. Choose the App Store price that matches the course's intended selling
   price, then enable the supported countries/regions.
6. Add an App Review screenshot that shows this course's purchase sheet.
7. Save it and attach it to the same app-version submission as build 12.

The first non-consumable purchase must be submitted with a new app version.
Complete the required tax forms before testing; Paid Apps and banking alone
are not sufficient when App Store Connect reports missing tax information.

## Secure transaction flow

1. Login/registration/profile returns a permanent student
   `app_account_token` UUID.
2. Flutter maps course 42 to `com.baheth.school.course.v2.42`.
3. Flutter creates a deterministic UUIDv8 that binds that student and course,
   and passes it as StoreKit's `appAccountToken`.
4. StoreKit returns a signed StoreKit 2 JWS transaction.
5. The Laravel API verifies Apple's certificate chain and signature, bundle,
   environment, `Non-Consumable` type, quantity, ownership, revocation state,
   product ID, transaction ID, and account/course token.
6. Laravel grants only the course encoded by the exact product ID, inside the
   same database transaction that records the unique Apple transaction.
7. Flutter finishes the StoreKit transaction only after backend success.

The endpoint request is:

```json
{
  "course_id": 42,
  "product_id": "com.baheth.school.course.v2.42",
  "transaction_id": "2000000123456789",
  "signed_transaction": "eyJhbGciOiJFUzI1NiIs...",
  "transaction_date": "1786636800000",
  "source": "app_store",
  "purchase_token": "2c6cdbad-2b37-8e8d-927d-68260000002a"
}
```

Retries are idempotent. A transaction already bound to a different student or
course is rejected. Non-consumable purchases can be replayed through the app's
**Restore Purchases** button and revalidated by the backend.

## Backend deployment

1. Deploy `/Users/tajawal/Downloads/bahith_backend`.
2. Configure:

   ```dotenv
   APPLE_IAP_BUNDLE_ID=com.baheth.school
   APPLE_IAP_COURSE_PRODUCT_PREFIX=com.baheth.school.course.v2.
   APPLE_IAP_ALLOWED_ENVIRONMENTS=Production,Sandbox
   APPLE_IAP_MAX_CLOCK_SKEW_SECONDS=300
   ```

3. Run `php artisan migrate --force`.
4. Run `php artisan config:clear`, then `php artisan config:cache` if used.
5. Confirm login, registration, and `GET /profile` return
   `app_account_token`.
6. Confirm the verification endpoint is reachable over HTTPS and
   `GET /app-settings` returns `show_price: 1`.

## End-to-end test

Use a Sandbox Apple Account on a real iPhone/iPad or TestFlight:

1. Sign in to a Baheth test account.
2. Open each paid course and confirm its own localized product/price loads.
3. Purchase one course and confirm only it becomes enrolled.
4. Relaunch and confirm access persists.
5. Reinstall, sign in to the same Baheth and Apple sandbox accounts, tap
   **Restore Purchases**, and confirm access is restored.
6. Test cancel, Ask to Buy/pending, and a network failure during backend
   verification.
7. Confirm retry creates only one `apple_purchases` row and one enrollment.

Do not resubmit until this test passes against the deployed production API.
