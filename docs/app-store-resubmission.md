# App Store resubmission — build 12

## Required before submission

1. Deploy the Laravel backend and run `php artisan migrate --force`.
2. Confirm production login/profile returns `app_account_token` and the Apple
   verification endpoint accepts Sandbox transactions.
3. Create and attach the five Non-Consumable products listed in
   `docs/apple-in-app-purchases.md`.
4. Complete the missing U.S. tax information in **Business > Agreements**.
5. Keep `show_price=1` throughout review.
6. Use a fresh reviewer student account with no existing paid enrollments.
7. Test purchase and Restore Purchases with TestFlight before submission.

## Guideline 3.2 decision

Use the public-distribution explanation below only if it is factually true that
any member of the public can register without invitation, affiliation, or
manual approval. If the app is restricted to one academy/organization, request
Unlisted App distribution (or use Apple School Manager custom distribution)
instead of making that claim.

## App Review notes

Replace the credentials and the tested course ID before pasting:

```text
Hello App Review,

Thank you for your feedback. We corrected the purchase flow in build 12.

Every paid digital course shown in the iOS app is now purchasable through
Apple In-App Purchase. Each course has its own Non-Consumable product because
course access is permanent and course prices differ. The iOS app contains no
external payment link or alternative-payment call to action.

The app now refreshes legacy account data automatically, includes a permanent
appAccountToken in StoreKit purchases, verifies Apple's signed StoreKit 2
transaction on our backend, and unlocks only the course whose product ID was
purchased. Restore Purchases is also available.

Product ID pattern:
com.baheth.school.course.v2.<course-id>

Regarding Guideline 3.2:

1. No. The app is not restricted to a single company, school, or organization.
2. No. It is a consumer education platform open to individual students from
   the general public.
3. Public features include course and teacher catalogs, lessons, exams,
   announcements, and educational resources.
4. Any user can create an account in the app using a name, phone number, and
   password. No invitation, affiliation, or manual approval is required.
5. Individuals purchase paid digital courses through Apple In-App Purchase.

Review account:
Phone: [REVIEW PHONE]
Password: [REVIEW PASSWORD]

Steps:
1. Sign in with the review account.
2. Open Courses.
3. Select paid course [COURSE ID/NAME].
4. Tap "Buy Course from App Store".
5. Tap the button displaying Apple's localized price.

The matching Non-Consumable IAP products are attached to this submission.
```
