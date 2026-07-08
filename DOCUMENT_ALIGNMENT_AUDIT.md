# Smart Blood & Emergency Donor Network - Document Alignment Audit

Generated: 2026-07-07  
Source document: `C:\Users\aliha\.codex\attachments\cfc38b5a-4268-4bde-83b5-cad185a668e3\pasted-text.txt`  
Project inspected: `D:\Blood_Donation_App\blood_donation`

## Executive Verdict

The project is **substantially aligned**, but it is **not completely aligned** with the assignment document yet.

Estimated alignment: **~82-88% overall**.

The implementation already covers most major product areas: authentication, role-aware routing, donor profiles, patient request creation, donor search, hospital/blood-bank directories, donation history, notifications, dashboard, admin screens, settings, localization, local cache, Supabase, Firebase, and clean feature-based architecture.

The remaining mismatch is not that the app is empty; it is that several important flows are incomplete, incorrectly wired, or risky for a fresh submission setup:

- Emergency request creation does not collect hospital details.
- Blood request realtime stream is a stub.
- Nearby donor sort controls are cosmetic.
- Request detail lets non-donor users accept pending requests.
- Hospital role onboarding is not exposed in normal registration.
- Settings notification columns and emergency alert toggle are inconsistent.
- Database schema is split across base migration plus fix scripts, so fresh setup can fail.
- README is still the default Flutter template.
- `flutter analyze` and `flutter test` could not be completed in this session because both verification processes became unresponsive with no output.

## Requirement-by-Requirement Alignment

| Document Requirement | Current Status | Evidence | Notes |
|---|---:|---|---|
| Secure user registration/login/logout | Mostly aligned | `lib/shared/providers/auth_provider.dart`, `lib/features/authentication/screens/register_screen.dart`, `login_screen.dart` | Email/password login exists. Secure storage is used. Email verification exists but registration routes directly into the app after signup. |
| Forgot password | Aligned | `lib/features/authentication/screens/forgot_password_screen.dart`, `auth_provider.dart` reset flow | Uses Supabase reset email. |
| Profile management | Aligned | `lib/features/profile`, `lib/features/donor/screens/donor_edit_screen.dart` | Profile and donor fields are editable. |
| Secure session management | Mostly aligned | `lib/shared/providers/auth_provider.dart` | Supabase session plus secure storage fallback. Token restore code uses `setSession(accessToken)`, which may be fragile if refresh token is needed. |
| Role-based user management | Partially aligned | `lib/core/routes/app_router.dart:90`, `register_screen.dart:230` | Routes support donor/patient/hospital/admin, but signup UI only exposes donor and patient. |
| Donor registration fields | Mostly aligned | `lib/features/donor/screens/donor_edit_screen.dart` | Blood group, age, gender, city, phone, weight, location, availability are present. Last donation date is derived from donation flow rather than directly entered in donor registration. |
| Medical eligibility | Aligned | `lib/core/utils/donor_eligibility.dart` | Checks age, weight, and 90-day interval. |
| Emergency blood request | Partially aligned | `lib/features/patient/screens/create_request_screen.dart:80` | Blood group, units, priority, notes, GPS are present; hospital details/address are not collected despite model support. |
| Patients or hospitals can create requests | Partially aligned | `lib/core/routes/app_router.dart:165`, `hospital_dashboard_screen.dart` | Patient create route exists. Hospital dashboard does not expose create emergency request flow. |
| Nearby donor search | Mostly aligned | `lib/features/nearby_donors/screens/nearby_donors_screen.dart`, `nearby_donor_remote_datasource.dart` | Blood group/distance filtering and contact call button exist. Sorting UI does not affect results. |
| View donor availability | Partially aligned | `lib/shared/widgets/donor_card.dart`, `nearby_donor_remote_datasource.dart:19` | Availability shown, but datasource filters only `role = donor`, not `is_available = true`. |
| Hospital directory | Aligned | `lib/features/hospitals/screens/hospitals_screen.dart` | Search, contact, hours, navigation, verified filter exist. |
| Blood bank directory | Mostly aligned | `lib/features/blood_banks/screens/blood_banks_screen.dart`, `hospitals_screen.dart` blood-bank tab | Search/contact exists. Dedicated `BloodBanksScreen` lacks map navigation while hospital tab blood-bank card has navigation. |
| Save favorite locations | Likely aligned | `supabase_migration.sql:132`, hospital providers/screens | Saved locations table exists; not deeply verified in UI during this audit. |
| Donation history | Aligned | `lib/features/donation_history`, `blood_request_provider.dart:101` | History, stats, next eligibility, achievements, auto-record on completed request. |
| Emergency notifications | Mostly aligned | `lib/features/notifications`, `supabase/migrations/20240707000001_blood_request_notification_trigger.sql` | Notification records and push pipeline exist. Donation reminders are not scheduled. Settings may not suppress alerts. |
| User dashboard | Mostly aligned | `lib/features/dashboard/screens/dashboard_screen.dart` | Stats, active requests, notifications, quick actions, availability, donation summary. Nearby emergency cases are represented through active/recent requests but not explicitly distance-based. |
| Admin panel | Mostly aligned | `lib/features/admin/screens`, `admin_remote_datasource.dart` | Users, requests, reports, approvals, announcements, stats exist. Some report display fields do not match schema. |
| Settings | Mostly aligned | `lib/features/settings/screens/settings_screen.dart` | Dark mode, language, notifications, privacy/terms dialogs, report issue, delete account, logout. Emergency alert toggle is local-only. |
| Clean architecture / modular structure | Aligned | `lib/features/*/{screens,providers,services}`, shared/core folders | Feature-first architecture is strong. Some duplicate repository paths exist. |
| State management | Aligned | Riverpod providers throughout | Uses `StateNotifierProvider`, `FutureProvider`, `StreamProvider`. |
| REST/backend integration | Mostly aligned | Supabase services and migrations | Supabase is used; not a traditional REST API, but acceptable backend integration for the stack. |
| GPS/location services | Aligned | `lib/core/services/location_service.dart`, donor/search/request/register flows | Used in request creation, donor search, profile, location picker. |
| Local storage/offline | Partially aligned | `lib/core/database`, `CachedApiService` | Hive cache exists for non-emergency data. Emergency requests intentionally not cached. |
| Environment variables | Mostly aligned | `lib/core/config/app_config.dart`, `pubspec.yaml:52` | `.env` is supported, but fallback placeholder values can cause runtime failure if README/setup is missing. |
| README documentation | Not aligned | `README.md:3` | Still default Flutter starter README. |
| Tests | Partially aligned | `test/` contains unit/widget/integration tests | Tests exist, but could not be verified in this session because `flutter test` became unresponsive. |

## Confirmed Strengths

1. **Feature breadth is strong.** The app includes far more than a skeleton: patient, donor, hospital, blood bank, admin, notifications, settings, maps, profile, health tips, and dashboard modules exist.
2. **Architecture is credible.** The codebase follows a feature-first structure with services/providers/screens and shared/core layers.
3. **Supabase + Firebase integration is real.** Supabase auth/database/realtime pieces and Firebase analytics/crashlytics/messaging are present.
4. **Local caching is thoughtful.** `CachedApiService` avoids caching `blood_requests`, which is correct for safety-critical emergency data.
5. **Admin coverage has improved.** Reports, approvals, announcements, user suspension, request management, and stats screens exist.
6. **Bonus features are partially present.** Health tips, multilingual support, offline cache, eligibility checker, and hospital/blood-bank registration are present or partially present.

## High-Priority Gaps and Incorrect Flows

### P0 - Emergency Request Form Missing Hospital Details

Document requirement:

- Enter hospital details.
- Patients or hospitals should create emergency blood requests.

Current implementation:

- `BloodRequest` supports `hospitalId`, `hospitalName`, and `address` in `lib/shared/models/blood_request.dart:17`.
- `CreateRequestScreen` creates the request at `lib/features/patient/screens/create_request_screen.dart:80`, but the form only collects blood group, units, priority, notes, and GPS.
- No hospital picker, hospital name text field, or address field is included.

Impact:

Evaluators can create a request, but the workflow does not fully match the document. Hospital context is critical in an emergency blood request.

Recommended fix:

- Add a hospital selector using `hospitalsProvider`, plus optional manual hospital/address fields.
- Persist `hospital_id`, `hospital_name`, and `address`.
- Show hospital details in request cards/detail screen.
- Add create-request access from hospital dashboard if hospital users are expected to create requests.

### P0 - Blood Request Realtime Provider Is a Stub

Document requirement:

- Real-time emergency requests.
- Instant notifications for new blood requests and nearby urgent cases.

Current implementation:

- `NotificationRemoteDataSource.subscribeToNewNotifications` uses Supabase `onPostgresChanges`.
- `BloodRequestRepositoryImpl.subscribeToNewRequests` only creates a `StreamController` and returns the stream without subscribing or adding events at `lib/features/blood_requests/services/blood_request_repository_impl.dart:78`.
- `realtimeRequestsProvider` depends on that stub at `lib/features/blood_requests/providers/blood_request_provider.dart:146`.

Impact:

Notifications may arrive through the notification channel, but the blood request realtime stream itself is non-functional.

Recommended fix:

- Implement Supabase realtime on `blood_requests`.
- Filter by blood group/distance where possible.
- Invalidate/refetch paginated request lists when a new relevant request arrives.

### P0 - Fresh Database Setup Is Inconsistent

Current implementation relies on base migration plus separate fix scripts:

- Base `profiles` table does not include `is_suspended`, but login and admin flows query/update it in `auth_provider.dart:267` and `admin_remote_datasource.dart:78`.
- `is_suspended` is only added by `supabase/fix_suspension_column.sql:4`.
- Base `blood_banks` table does not include `verified`, but app queries it in `blood_bank_remote_datasource.dart:22` and admin approvals in `admin_remote_datasource.dart:197`.
- `blood_banks.verified` is only added by `supabase/fix_rls_policies.sql:31`.
- Notification push migration adds `channel_id` and `sound` after triggers, while a later blood-request trigger inserts those fields.

Impact:

A fresh evaluator setup using only `supabase_migration.sql` can fail at login, blood bank listing, admin approvals, and request notification creation.

Recommended fix:

- Consolidate all schema changes into ordered migrations.
- Ensure base schema includes: `profiles.is_suspended`, `blood_banks.verified`, `notifications.channel_id`, `notifications.sound`, and settings fields used by the app.
- Update README with exact migration order.

### P1 - Request Detail Allows Wrong Users to Accept Requests

Current implementation:

- Request list gates accept action with `user.isDonor` at `lib/features/blood_requests/screens/blood_requests_screen.dart:123`.
- Request detail shows accept action for any pending request at `lib/features/blood_requests/screens/request_detail_screen.dart:243`.

Impact:

A patient/admin/hospital user who opens a pending request detail can attempt to accept it as donor. RLS may block some users, but the UI flow is incorrect and confusing.

Recommended fix:

- In `RequestDetailScreen`, show accept only when `currentUser.isDonor && request.status == 'pending'`.
- Consider preventing the patient who created the request from accepting their own request.

### P1 - Nearby Donor Sort Controls Do Not Sort

Current implementation:

- UI tracks `_sortBy` in `nearby_donors_screen.dart:29`.
- Sort chips update `_sortBy` at `nearby_donors_screen.dart:222`, `:231`, and `:240`.
- `NearbyDonorSearchParams` does not include sort mode.
- `NearbyDonorRemoteDataSource` returns filtered donors without sorting at `nearby_donor_remote_datasource.dart:53`.

Impact:

Users see sorting options, but results do not change. This is a visible flow mismatch.

Recommended fix:

- Add `sortBy` to `NearbyDonorSearchParams.props`.
- Compute distance per donor and sort by nearest.
- Add real definitions for `most_active` and `high_donations`, likely from donation counts and `updated_at`/last activity fields.
- Pass distance into `DonorCard.distance`.

### P1 - Donor Search Does Not Enforce Availability in Data Source

Document requirement:

- View donor availability.
- Contact eligible donors.

Current implementation:

- `NearbyDonorRemoteDataSource` filters `role = donor` and optional blood group only at `nearby_donor_remote_datasource.dart:19`.
- It does not filter `is_available = true`.

Impact:

Unavailable donors can appear unless hidden elsewhere. This weakens the emergency donor discovery flow.

Recommended fix:

- Add `is_available: true` and optionally eligibility constraints to the donor query/filter.
- Consider excluding suspended users.

### P1 - Hospital Role Onboarding Is Not Complete

Current implementation:

- Router supports hospital default route at `app_router.dart:103`.
- Register screen contains cases for hospital/admin navigation at `register_screen.dart:46`, but the visible role cards only include donor and patient at `register_screen.dart:230`.

Impact:

Hospital users are part of the required system, but normal signup cannot create a hospital role. This makes hospital workflows dependent on manual database/admin setup.

Recommended fix:

- Add hospital registration role choice or a separate hospital-manager onboarding flow.
- Decide whether public self-signup for hospitals is allowed or admin-invited only.
- Document how demo hospital/admin accounts are created.

### P1 - Settings Notification Preferences Are Inconsistent

Current implementation:

- Base schema has `notification_enabled` at `supabase_migration.sql:115`.
- `UserSettingsDto` uses `notification_enabled` and `emergency_alerts_enabled`.
- `settings_repository_impl.dart` uses `notifications_enabled` plural.
- Emergency alerts switch only updates local widget state in `settings_screen.dart:174`; it does not call a provider method.

Impact:

Push notification preference may be unreliable depending on which repository path is used. Emergency alert preference is not persisted or enforced by the trigger/push pipeline.

Recommended fix:

- Choose one column naming convention.
- Add `emergency_alerts_enabled` to schema.
- Persist emergency alert toggle.
- Update blood-request notification trigger to respect user settings.

### P1 - Admin Report Data Does Not Match Report Schema

Current implementation:

- Reports schema has `reported_user_id` at `supabase_migration.sql:142`.
- Settings report issue inserts only `reporter_id` and `reason` at `settings_screen.dart:585`.
- Admin reports UI reads `reported_user` at `admin_reports_screen.dart:109`, which is not in the base schema.

Impact:

Report moderation exists, but reported user display is likely always "Unknown User" for app-submitted issue reports.

Recommended fix:

- Decide whether "Report an Issue" is platform feedback or user report.
- For platform feedback, rename/display accordingly.
- For user reports, collect `reported_user_id` and join profile data for admin display.

### P2 - README Is Not Submission-Ready

Current implementation:

- `README.md:3` still says "A new Flutter project."
- It contains Flutter starter links rather than setup, architecture, screenshots, env, migrations, or demo credentials.

Impact:

The assignment explicitly requires README documentation. This can cost evaluation points even if the app works.

Recommended fix:

- Replace README with project overview, feature list, architecture, setup, `.env` keys, migration order, Firebase/Supabase setup, run/build commands, screenshots, and known limitations.

### P2 - Verification Could Not Be Completed in This Session

Attempted:

- `flutter analyze`
- `flutter test`

Result:

- Both commands produced no output and became unresponsive.
- Dart child processes were stopped manually.

Impact:

This audit cannot claim the current code passes analyzer/tests.

Recommended fix:

- Re-run locally in a fresh terminal.
- Capture analyzer/test output.
- If hangs repeat, run `flutter pub get -v`, `flutter test -r expanded`, and individual test files to isolate the blocker.

## Bonus Feature Status

| Bonus Feature | Status |
|---|---|
| Live location tracking | Not found as continuous tracking; current location capture exists. |
| QR code donor identification | Not found. |
| AI-based donor matching | Not found. |
| Health tips/guidelines | Implemented in `lib/features/health_tips/screens/health_tips_screen.dart`. |
| Blood donation eligibility checker | Implemented in `lib/core/utils/donor_eligibility.dart`. |
| Voice emergency request | Not found. |
| Offline support | Partial through Hive/cache for non-emergency data. |
| Multi-language support | Partial/implemented for app strings through `LocalizationService` and locale provider. |
| Emergency contact integration | Not found. |
| Volunteer registration | Not found. |
| Blood donation camp announcements | Partial; admin announcements exist, but camp-specific workflow not found. |

## Priority Fix Plan

### Must Fix Before Submission

1. Add hospital details to emergency request creation.
2. Implement real Supabase realtime for `blood_requests`.
3. Consolidate database schema/migrations so a fresh setup works.
4. Replace the default README.
5. Re-run and capture `flutter analyze` and `flutter test`.

### High-Value Flow Fixes

1. Role-gate accept action in request detail.
2. Make donor sorting real.
3. Filter donor search by availability and suspension status.
4. Complete hospital-role onboarding or document seeded hospital accounts.
5. Persist emergency alert settings and use them in notification generation.

### Polish/Completeness

1. Show hospital/address details in request cards/detail.
2. Add explicit nearby emergency cases section/filter on dashboard.
3. Add donation reminder scheduling.
4. Make blood-bank directory behavior consistent across tab/dedicated screen.
5. Improve admin report display with reporter/reported profile joins.

## Final Assessment

This project is a strong implementation and clearly goes beyond a basic assignment scaffold. It is close to the document in architecture and feature breadth, but **not completely aligned** because several evaluator-visible flows either miss required inputs or are only partially wired.

The most important fixes are not huge redesigns. They are targeted correctness and submission-readiness work: emergency request hospital details, realtime requests, database migration cleanup, role gating, real donor sorting, README, and verification.
