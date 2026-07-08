# Implementation Audit & Fix Plan

**Date:** 2026-07-07  
**Files analyzed:** All Dart source, SQL migrations, README  
**Total tests:** 79 passing / 0 failing

---

## Phase 1: Critical Alignment Fixes

### 1. Fix Emergency Request Creation Flow

**Plan requirement:**
- Hospital selector in `CreateRequestScreen`
- Manual hospital/address entry
- Save `hospital_id`, `hospital_name`, `address` into `BloodRequest`
- Show hospital/address in request list and request detail
- "Create Blood Request" action for hospital users on hospital dashboard

**Current state:**
- `CreateRequestScreen` (`lib/features/patient/screens/create_request_screen.dart`) has **no hospital selector** — only blood group, units, priority, notes
- `BloodRequest` model already has `hospitalId`, `hospitalName`, `address` fields — but they're never set in the `_submit()` method
- `HospitalDashboardScreen` exists but doesn't have a "Create Blood Request" button for hospital users (only registration links)
- `RequestDetailScreen` shows patient name, blood group, units, priority, status, donor — but **no hospital name or address**
- `DashboardScreen` request cards show blood group, units, priority, time — **no hospital or address**

**Gap:** 🔴 MAJOR — Hospital info fields exist in model but are never populated in the UI

**What needs to change:**
1. `CreateRequestScreen`: Add hospital dropdown (from `hospitalsProvider`) + manual address text field
2. `_submit()`: Pass `hospitalId`, `hospitalName`, `address` into `BloodRequest`
3. `RequestDetailScreen`: Add hospital info detail rows
4. `DashboardScreen._RequestCard`: Show hospital name if available
5. `HospitalDashboardScreen`: Add FAB or button to navigate to CreateRequestScreen

---

### 2. Implement Real Blood Request Realtime

**Plan requirement:**
- Replace stub `subscribeToNewRequests()` with Supabase realtime subscription
- Listen to `blood_requests` inserts/updates
- Filter by status, blood group, location
- Refresh UI on new emergency requests
- Cleanup/unsubscribe logic

**Current state:**
- `BloodRequestRepositoryImpl.subscribeToNewRequests()` (`lib/features/blood_requests/services/blood_request_repository_impl.dart` line 52-57) is a **stub** — returns a broadcast `StreamController` with no real subscription
- `NotificationRemoteDataSource.subscribeToNewNotifications()` has a **working** Supabase realtime subscription — this pattern can be replicated for blood_requests
- `realtimeRequestsProvider` (`lib/features/blood_requests/providers/blood_request_provider.dart` line 97-100) consumes the stub stream

**Gap:** 🔴 MAJOR — No realtime blood request updates. Donors won't see new requests appear in real-time.

**What needs to change:**
1. Replace stub in `BloodRequestRepositoryImpl.subscribeToNewRequests()` with Supabase `channel.onPostgresChanges()` using the same pattern as `NotificationRemoteDataSource`
2. Add filtering by blood group (channel filter) and/or location (client-side after receiving)
3. Add `StreamSubscription` management and proper cleanup/disposal
4. Connect `realtimeRequestsProvider` in `DashboardScreen` and `BloodRequestsScreen`

---

### 3. Consolidate Supabase Schema

**Plan requirement:**
- Merge fix scripts into proper ordered migrations
- Ensure: `profiles.is_suspended`, `blood_banks.verified`, `notifications.channel_id`, `notifications.sound`, `user_settings.emergency_alerts_enabled`
- Update RLS policies for blood-bank registration/approval
- Document exact migration order

**Current state:**
- Migrations in `supabase/migrations/` are mostly properly numbered but incomplete:
  - `20240704000001_add_fcm_token.sql` — adds fcm_token to profiles ✓
  - `20240704000002_fix_rls_recursion.sql` — fixes RLS on users/hospitals/announcements ✓
  - `20240705000001_notification_push_trigger.sql` — push notification trigger, adds `channel_id`, `sound` ✓
  - `20240705000002_add_reports_update_policy.sql` — admin update policy for reports ✓
  - `20240706000001_add_donations_columns.sql` — donation columns ✓
  - `20240706000002_fix_notifications_rls_policies.sql` — notification RLS ✓
  - `20240707000001_blood_request_notification_trigger.sql` — blood request → notification trigger ✓
- Fix scripts still exist as standalone `.sql` files:
  - `supabase/fix_suspension_column.sql` — not a migration!
  - `supabase/fix_rls_policies.sql` — not a migration! (adds `blood_banks.verified`, RLS policies)
  - `supabase/fix_notifications_rls.sql` — not a migration!
- `user_settings.emergency_alerts_enabled` exists in the DTO (`UserSettingsDto`) and migrations

**Gap:** 🟡 MEDIUM — Fix scripts aren't proper migrations. `blood_banks.verified` column only exists via a standalone fix script.

**What needs to change:**
1. Move fix script contents into numbered migration files
2. Create a new migration `20240708000001_consolidate_fix_scripts.sql` that includes all the fix script logic
3. Document migration order clearly in README

---

### 4. Fix README

**Plan requirement:**
- Replace template README with full documentation

**Current state:**
- `README.md` is the default Flutter template — completely empty of project info

**Gap:** 🔴 MAJOR — README is entirely useless

**What needs to change:**
Complete rewrite with: project overview, feature list, tech stack, architecture, setup steps, `.env` variables, Supabase migration steps, Firebase setup, run/build commands, demo credentials, screenshots, known limitations.

---

## Phase 2: Flow Correctness Fixes

### 5. Role-Gate Request Accept Action

**Plan requirement:**
- Show accept button only for donors
- Prevent request owner from accepting their own request
- Keep cancel/complete actions role-aware

**Current state:**
- `RequestDetailScreen` (`lib/features/blood_requests/screens/request_detail_screen.dart`):
  - Accept button (`ElevatedButton` with "Accept Request as Donor") shows for ALL pending requests with **no role check**
  - Cancel button shows for all non-completed/non-cancelled requests with **no ownership check**
  - Complete button shows only for accepted requests (correct)
- The accept button calls `bloodRequestNotifierProvider.notifier.acceptRequest()` with the current user's info — ANY logged-in user can accept, even the patient who created the request

**Gap:** 🟡 MEDIUM — Accept button has no role gate or ownership prevention

**What needs to change:**
1. In `RequestDetailScreen._buildActions()`: Check `ref.read(authProvider).valueOrNull?.role == 'donor'` before showing accept button
2. Check `request.patientId != currentUser.id` to prevent self-acceptance
3. Cancel button should also verify ownership (only the patient who created it or the accepting donor can cancel)

---

### 6. Fix Nearby Donor Sorting

**Plan requirement:**
- Add `sortBy` to `NearbyDonorSearchParams`
- Implement: `nearest`, `most_active`, `high_donations`
- Calculate and pass donor distance to `DonorCard`
- Sort chips actually refresh provider

**Current state:**
- `NearbyDonorSearchParams` (`lib/features/nearby_donors/providers/nearby_donor_provider.dart`) has **no `sortBy` field**
- Sort chips exist in `NearbyDonorsScreen` UI (`_sortBy = 'nearest' | 'most_active' | 'high_donations'`) but don't affect the provider — they only call `setState()` which doesn't change the `_searchParams`
- `NearbyDonorRemoteDataSource.findNearbyDonors()` returns donors unsorted (no ORDER BY in query)
- `DonorCard` doesn't display distance
- The `_searchDebounce` pattern uses `setState(() {})` which doesn't re-create `_searchParams` properly

**Gap:** 🟡 MEDIUM — Sort chips are decorative, no actual sorting or distance display

**What needs to change:**
1. Add `sortBy` to `NearbyDonorSearchParams` and include in `props` list for equality
2. Update `NearbyDonorRemoteDataSource` to sort results by distance (client-side after fetching all donors, or add a DB ordering field)
3. When `sortBy` changes, actually rebuild `_searchParams` and re-trigger the provider
4. Calculate and pass distance to `DonorCard`

---

### 7. Filter Donor Search Properly

**Plan requirement:**
- Add `is_available = true` filter
- Exclude suspended users
- Optionally filter medically ineligible donors
- Show clear message if no eligible donors

**Current state:**
- `NearbyDonorRepositoryImpl.findNearbyDonors()` ALREADY queries `is_available = true` ✓
- `NearbyDonorRemoteDataSource.findNearbyDonors()` queries with role='donor' filter but does NOT filter `is_available` or `is_suspended` — it relies on all-profile fetch + distance filtering
- Suspended users are not excluded in the remote datasource version
- No medical eligibility filtering (age, weight, last donation date)
- The empty state ALREADY shows helpful messages ✓

**Gap:** 🟢 MINOR — Remote datasource doesn't filter availability/suspension at DB level

**What needs to change:**
1. Add `is_available = true` and `is_suspended = false` filters to `NearbyDonorRemoteDataSource`

---

### 8. Complete Hospital Role Onboarding

**Plan requirement:**
- Decide: public hospital signup OR admin-created accounts
- If public: add hospital role card to registration, route to /hospital-dashboard
- If admin-only: hide unused signup logic, add README instructions

**Current state:**
- `HospitalRegisterScreen` exists as a public registration form — hospital managers can register directly
- Route `/hospital/register` is accessible from the app (via hospital dashboard)
- Registration is gated by DB permissions (RLS), not by the app's registration flow
- The registration screen is shown in the shell navigation
- The registration flow does NOT set the user's role to 'hospital' — it just inserts a hospital record. The user must already be a 'hospital' role user (set separately via admin or DB).

**Gap:** 🟡 MEDIUM — Hospital registration exists but role assignment is unclear. The signup flow doesn't let users choose 'hospital' role.

**What needs to change:**
1. Add 'Hospital' role option to the registration screen
2. On hospital registration success, set the user's role to 'hospital' in profiles table
3. Route newly registered hospital users to `/hospital-dashboard`

---

## Phase 3: Settings and Notification Integrity

### 9. Fix Notification Settings Columns

**Plan requirement:**
- Standardize column naming: use `notification_enabled` or `notifications_enabled` consistently
- Persist emergency alert toggle
- Add repository/provider method for emergency alert updates
- Sync settings screen with Supabase and local storage

**Current state:**
- `UserSettingsDto` uses `notification_enabled` (singular) in `toJson()`/`fromJson()`
- Column name exists in DB as `notification_enabled` — this needs verification
- Settings screen uses `settingsProvider` for push notifications toggle but the **emergency alerts toggle (`_emergencyAlertsEnabled`) does NOT call any provider method** — it only calls `setState()`
- `SettingsNotifier` has `toggleDarkMode`, `toggleNotifications`, `toggleLanguage` but **NO `toggleEmergencyAlerts` method**
- Settings screen does NOT sync with Supabase on emergency alerts change

**Gap:** 🟡 MEDIUM — Emergency alerts toggle is cosmetic only, not persisted

**What needs to change:**
1. Add `toggleEmergencyAlerts()` to `SettingsNotifier`
2. Add `toggleEmergencyAlerts()` to `SettingsRemoteDataSource`
3. Wire up emergency alerts switch in settings screen to call the provider

---

### 10. Respect Notification Preferences

**Plan requirement:**
- Update blood-request notification trigger to skip users with notifications disabled
- Skip emergency alerts if `emergency_alerts_enabled = false`
- Consider notifying only matching blood group donors

**Current state:**
- `handle_new_blood_request()` trigger (`20240707000001_...sql`) notifies ALL active non-suspended donors with NO preference check
- `user_settings` table has `notification_enabled` and `emergency_alerts_enabled` columns but the trigger doesn't join on it
- No blood group matching — a donor with blood type A+ gets notified about a B- request

**Gap:** 🟡 MEDIUM — Trigger doesn't respect notification preferences or blood group

**What needs to change:**
1. Update `handle_new_blood_request()` trigger to:
   - JOIN `user_settings` to check `notification_enabled` and `emergency_alerts_enabled`
   - Optionally filter by matching blood group (compatible: O- can donate to all, etc.) — this is a product decision
2. Create migration for this change

---

### 11. Add Donation Reminder Scheduling

**Plan requirement:**
- Calculate next eligibility date when donation is recorded
- Create reminder notification when user becomes eligible again
- Optionally use local notifications for device reminders

**Current state:**
- **Not implemented at all** — no donation reminder scheduling exists

**Gap:** 🟢 MINOR — Nice-to-have feature, lowest priority

**What needs to change:**
1. When a donation is completed + recorded, calculate next eligible date (typically 56-84 days for whole blood)
2. Schedule a local notification (using `flutter_local_notifications`) for that date
3. Optionally create a Supabase notification record as well

---

## Phase 4: Admin and Reporting Improvements

### 12. Fix Admin Report Flow

**Plan requirement:**
- Decide: user reports OR platform feedback
- If user reports: collect `reported_user_id`, join names in admin UI
- If feedback: rename UI
- Add status actions: pending, reviewed, resolved

**Current state:**
- Reports system exists ("Report an Issue" in Settings screen) — it's **platform feedback/issues**, NOT user-to-user reports
- Admin reports screen exists (`AdminReportsScreen`) with dismiss functionality
- Report DTO stores `reporter_id`, `reason` — but `reported_user_id` is not collected
- Reports only have status `resolved` (set by dismiss) — no `pending` or `reviewed` states

**Gap:** 🟢 MINOR — Reports are feedback-only, no user reporting. Status workflow is minimal.

**What needs to change:**
1. If keeping as feedback: Rename "Report an Issue" screen labels to be clearly feedback-focused
2. Add `pending`, `reviewed`, `resolved` statuses with a dropdown in admin UI
3. Optionally add optional `reported_user_id` field for future user-to-user reporting

---

### 13. Improve Admin Approval Workflow

**Plan requirement:**
- Ensure hospital/blood-bank pending approvals work from fresh DB
- Add rejection reason
- Notify submitter after approval/rejection

**Current state:**
- Admin approvals screen (`AdminApprovalsScreen`) exists with verify/delete for both hospitals and blood banks
- `AdminRemoteDataSource` has `getPendingHospitals()`, `getPendingBloodBanks()`, `verifyHospital()`, `verifyBloodBank()`, `deleteHospital()`, `deleteBloodBank()`
- Verification sets `verified = true` — no rejection reason / notification flow

**Gap:** 🟢 MINOR — Core approval flow works. Rejection reasons and submitter notifications are missing.

**What needs to change:**
1. Add rejection reason dialog to approval screen
2. When rejecting, create a notification for the submitter if hospital/blood bank is linked to a user

---

## Phase 5: UX and Submission Polish

### 14. Improve Request Cards

**Plan requirement:** Show hospital name, address, priority, distance, creation time. Add direct navigation.

**Current state:**
- `DashboardScreen._RequestCard` shows: blood group, units, priority, time ago — **NO hospital, NO address, NO distance**
- `BloodRequestsScreen` items show limited info
- `RequestDetailScreen` shows: patient, blood group, units, priority, status, donor, notes — **NO hospital name or address**

**Gap:** 🟡 MEDIUM — Request cards don't show hospital info even though model supports it

**What needs to change:**
1. Populate `hospitalId`/`hospitalName`/`address` during request creation (Phase 1 item 1 prerequisite)
2. Add hospital name + address to all request card widgets and detail screen

---

### 15. Improve Dashboard Alignment

**Plan requirement:**
- Add "Nearby Emergency Cases" section for donors
- Use location/blood group filters
- Keep existing active requests and notifications

**Current state:**
- Dashboard has: greeting, eligibility status, stats, notifications, quick actions, active requests, donation summary, availability toggle
- No "Nearby Emergency Cases" section
- Active requests are fetched globally, not filtered by location or blood group

**Gap:** 🟢 MINOR — Dashboard is content-rich but doesn't prioritize nearby emergency cases for donors

**What needs to change:**
1. Add a "Nearby Emergency Cases" card section visible only to donors
2. Use the user's location + blood group to filter relevant requests

---

### 16. Make Blood Bank Directory Consistent

**Plan requirement:**
- Add map/navigation button to `BloodBanksScreen`
- Same card capabilities in tab and standalone screen

**Current state:**
- `BloodBanksScreen` exists as a standalone screen (route `/blood-banks`)
- `_BloodBankCard` has call (phone) and map (navigation) buttons ✓
- `HospitalsScreen` has both Hospitals and Blood Banks tabs — the Blood Banks tab uses `_BloodBankCard` ✓
- The tab version and standalone version are consistent

**Gap:** 🟢 MINOR — Already consistent

**What needs to change:** Nothing

---

### 17. Email Verification Decision

**Plan requirement:**
- Either enforce email verification after signup, or remove/soften unused verification screen
- Best: route new users to `EmailVerificationScreen` before full app access

**Current state:**
- `EmailVerificationScreen` exists at `/auth/login/verify-email` and is reachable after signup
- The route is accessible but the signup flow doesn't force navigation to it
- Users can access the app with unverified emails

**Gap:** 🟢 MINOR — Verification screen exists but isn't enforced

**What needs to change:**
1. After successful signup, navigate to `/auth/login/verify-email?email=xxx`
2. In `_handleRedirect`, check Supabase `user.email_confirmed_at` and redirect unverified users

---

## Phase 6: Verification and Quality

### 18. Fix Analyzer/Test Hang

**Plan requirement:**
- Run commands one by one
- If tests hang, run individual files
- Identify stuck Firebase/Supabase init

**Current state:**
- Tests work (79/79 pass) — no hanging issues
- `flutter analyze` not yet run

**Gap:** 🟢 MINOR — Just need to run and verify

**What needs to change:**
1. Run `flutter analyze` and fix any warnings
2. Document any known analyzer warnings

### 19. Add/Update Tests

**Plan requirement:**
- Unit tests: donor eligibility, request validation, notification settings mapping, donor sorting
- Widget tests: create request form with hospital fields, request detail donor-only accept button, settings toggles
- Integration tests: patient creates request, donor receives/sees, donor accepts/completes, donation history updates

**Current state:**
- 79 tests exist covering: pagination, localization, models, MainShell, HospitalCard, blood request notification flow
- Missing: donor eligibility, request validation, settings toggles, create request form widget test, request detail role-gated accept button

**Gap:** 🟡 MEDIUM — Good foundation but significant gaps in test coverage

**What needs to change:**
Create new tests for the areas listed above.

### 20. Final Submission Checklist

Most items need to be created/verified:
- APK/AAB build
- Demo users
- Screenshots
- Screen recording

---

## Recommended Fix Order (Prioritized)

```
Phase 1    1. Emergency Request — Hospital Selector  🔴 HIGH
           2. Real Blood Request Realtime             🔴 HIGH
           3. Consolidate Supabase Schema             🔴 HIGH
           4. Fix README                              🔴 HIGH

Phase 2    5. Role-Gate Request Actions               🟡 MEDIUM
           6. Nearby Donor Sorting                    🟡 MEDIUM
          14. Improve Request Cards                   🟡 MEDIUM
           8. Hospital Onboarding                     🟡 MEDIUM

Phase 3    9. Notification Settings Columns           🟡 MEDIUM
          10. Respect Notification Preferences        🟡 MEDIUM
           7. Filter Donor Search                     🟢 MINOR

Phase 4   12. Admin Report Flow                       🟢 MINOR
          13. Admin Approval Workflow                 🟢 MINOR

Phase 5   15. Dashboard — Nearby Emergency Section    🟢 MINOR
          17. Email Verification                      🟢 MINOR
          11. Donation Reminder Scheduling            🟢 MINOR

Phase 6   19. Add/Update Tests                        🟡 MEDIUM
          18. Analyzer / Test Verification            🟢 MINOR
          20. Final Submission Checklist              🟢 MINOR
```

**Total effort estimate:**
- 🔴 HIGH (4 items): ~3-4 days
- 🟡 MEDIUM (7 items): ~3-4 days
- 🟢 MINOR (8 items): ~2-3 days
- **Total: ~8-11 days**

**Already working correctly:**
- Blood request notification trigger ✅
- Push notification pipeline ✅
- Admin approval verify/delete ✅
- Hospital card with Call/Navigate buttons ✅
- Blood bank card consistency ✅
- All 79 tests passing ✅
