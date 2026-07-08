# Smart Blood & Emergency Donor Network — Implementation Tracker

> **Last Updated:** July 2, 2026 (post-implementation session)  
> **Legend:** ✅ Complete | ⚠️ Partial | ❌ Missing

---

## 1. Project Structure Comparison

### Core Infrastructure

| Path | Status | Notes |
|------|--------|-------|
| `lib/main.dart` | ✅ | Entry point with Riverpod ProviderScope |
| `lib/app.dart` | ✅ | MaterialApp.router with theme, routing |
| `bootstrap/app_initializer.dart` | ✅ | Full app initialization chain |
| `bootstrap/firebase_initializer.dart` | ❌ | Missing - logic in app_initializer instead |
| `bootstrap/supabase_initializer.dart` | ❌ | Missing - logic in app_initializer instead |
| `bootstrap/dependency_initializer.dart` | ❌ | Missing |
| `core/config/app_config.dart` | ✅ | Env-based config |
| `core/constants/api_constants.dart` | ✅ | API endpoints |
| `core/constants/app_constants.dart` | ✅ | App constants |
| `core/routes/app_router.dart` | ✅ | GoRouter with ShellRoute, auth redirects |
| `core/theme/app_colors.dart` | ✅ | Full color palette |
| `core/theme/app_theme.dart` | ✅ | Light + dark themes |
| `core/theme/app_typography.dart` | ✅ | Typography with Google Fonts |
| `core/network/api_service.dart` | ✅ | Generic CRUD + realtime + storage API |
| `core/network/supabase_client.dart` | ✅ | Singleton with all table getters |
| `core/network/connectivity_service.dart` | ✅ | Internet connectivity monitoring |
| `core/services/logger_service.dart` | ✅ | Structured logging |
| `core/services/location_service.dart` | ✅ | GPS, geocoding, distance |
| `core/services/permission_service.dart` | ✅ | Permission handling |
| `core/services/notification_service.dart` | ✅ | FCM + local notifications fully implemented |
| `core/services/crashlytics_service.dart` | ✅ | Crash reporting with debug mode check |
| `core/services/analytics_service.dart` | ❌ | Not implemented |
| `core/database/local_database_service.dart` | ✅ | Hive init + CRUD operations |
| `core/storage/local_storage_service.dart` | ✅ | SharedPreferences wrapper |
| `core/errors/app_exceptions.dart` | ✅ | Custom exception classes |
| `core/errors/error_handler.dart` | ✅ | Error handling utilities |
| `core/extensions/context_extensions.dart` | ✅ | Context extensions |
| `core/extensions/string_extensions.dart` | ✅ | String extensions |
| `core/helpers/date_helpers.dart` | ✅ | Date formatting |
| `core/helpers/validators.dart` | ✅ | Input validation |
| `core/utils/debouncer.dart` | ✅ | Debounce utility |
| `core/utils/geometry_utils.dart` | ✅ | Distance calculations, radius filtering |
| `core/utils/donor_eligibility.dart` | ✅ | Age/weight/interval eligibility check |
| `core/widgets/animated_counter.dart` | ✅ | Animated counter widget |
| `validators/` | ❌ | Empty directory |

### Shared Layer

| Type | File | Status | Notes |
|------|------|--------|-------|
| **Enums** | `enums/app_enums.dart` | ✅ | UserRole, BloodGroup, RequestStatus, EmergencyLevel, NotificationType, Gender, ThemeModePreference |
| **Models** | `models/user_profile.dart` | ✅ | Full model with copyWith, fromMap, toMap |
| | `models/blood_request.dart` | ✅ | Full model with status/priority helpers |
| | `models/donation.dart` | ✅ | Full model |
| | `models/hospital.dart` | ✅ | Full model |
| | `models/app_notification.dart` | ✅ | Full model |
| **Providers** | `providers/auth_provider.dart` | ✅ | StateNotifier with login, signup, logout, profile update |
| | `providers/theme_provider.dart` | ✅ | ThemeModeNotifier with local storage persistence |
| **Widgets** | `widgets/app_button.dart` | ✅ | Full button with loading state |
| | `widgets/app_card.dart` | ✅ | Card wrapper |
| | `widgets/app_textfield.dart` | ✅ | Text field with validation |
| | `widgets/app_specialty_widgets.dart` | ✅ | Specialty widgets |
| | `widgets/donor_card.dart` | ✅ | Donor card widget |
| | `widgets/empty_state.dart` | ✅ | Empty state widget |
| | `widgets/error_state.dart` | ✅ | ErrorState + RefreshableErrorState with retry |
| | `widgets/loading_indicator.dart` | ✅ | Loading indicator |
| | `widgets/main_shell.dart` | ✅ | Bottom nav shell with 5 tabs |
| | `widgets/shimmer_loading.dart` | ✅ | Shimmer loading |
| | `widgets/custom_appbar.dart` | ✅ | Exists and imported by screens |
| | `widgets/profile_avatar.dart` | ✅ | CachedNetworkImage + initials fallback + status dot |

---

## 2. Feature Module Comparison (CORRECTED)

### 2.1 Splash Module

| Component | Status | Notes |
|-----------|--------|-------|
| Splash screen with animation | ✅ | Fade + scale animation |
| Auto-navigate to onboarding | ✅ | After 3s delay |
| Gradient background | ✅ | Blood red gradient |
| Lottie animation | ⚠️ | Using Flutter animation instead of Lottie |

### 2.2 Onboarding Module

| Component | Status | Notes |
|-----------|--------|-------|
| Onboarding 3 pages (PageView) | ✅ | 3 feature pages |
| Skip button | ✅ | Navigates to login |
| Get Started button | ✅ | Navigates to login |
| Page indicator dots | ✅ | Animated dots |
| Providers/controllers | ❌ | Missing |
| SharedPreferences tracking | ❌ | Not storing completion state |

### 2.3 Authentication Module

| Component | Status | Notes |
|-----------|--------|-------|
| Login screen | ✅ | Email/password login |
| Register screen | ✅ | Full registration with name, email, phone, password |
| Forgot password screen | ✅ | Email-based reset |
| Social login buttons | ✅ | SocialLoginButton widget exists |
| Auth remote datasource | ✅ | Supabase auth calls |
| Auth repository interface | ✅ | Clean domain interface |
| Auth repository impl | ✅ | Data layer implementation |
| Auth use cases | ✅ | Domain use cases |
| Auth provider (shared) | ✅ | Riverpod StateNotifier |
| Auth UI providers | ✅ | Form state providers |
| Auth controller | ✅ | Presentation controller |
| Session persistence | ✅ | Supabase automatically handles JWT sessions |
| Email verification | ❌ | Not implemented |
| Auto-login | ✅ | Supabase auto-restores session |

### 2.4 Dashboard Module

| Component | Status | Notes |
|-----------|--------|-------|
| Dashboard screen | ✅ | Fully built with stats, actions, requests list |
| Stats cards (blood group, donations, units, age) | ✅ | _StatCard widgets |
| Quick actions (Find Donors, Hospitals, History) | ✅ | _ActionCard with navigation |
| Active requests list | ✅ | _RequestCard with status |
| Donation summary | ✅ | Total donations, units, achievements |
| Availability toggle | ✅ | Switch with profile update |
| Eligibility status | ✅ | Green/amber badge |
| Shimmer loading | ✅ | Loading state |
| Dashboard data source | ✅ | getStats, getRecentRequests, getDonationSummary |
| Dashboard DTO | ✅ | DashboardStatsDto |
| Dashboard repository + use cases | ✅ | Full domain layer |
| Dashboard providers | ✅ | dashboardProvider, recentRequestsProvider, donationSummaryProvider |
| Dynamic widget population | ✅ | All wired to real providers |

### 2.5 Donor Module

| Component | Status | Notes |
|-----------|--------|-------|
| Donor profile screen | ✅ | Exists |
| Donor edit screen | ✅ | Exists |
| Blood group selection | ✅ | Supported in data layer |
| Availability toggle | ✅ | toggleAvailability in datasource |
| Eligibility calculation | ✅ | donor_eligibility.dart fully implemented |
| GPS coordinates | ✅ | Supported in datasource via lat/lon |
| Donor remote datasource | ✅ | getNearbyDonors, searchDonors, updateDonorProfile, toggleAvailability |
| Donor DTO | ✅ | DonorDto with toDomain |
| Donor providers | ✅ | nearbyDonorsProvider, donorByIdProvider, donorSearchProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.6 Patient Module

| Component | Status | Notes |
|-----------|--------|-------|
| Patient screen | ✅ | Exists |
| Create request screen | ✅ | Full form with blood group, units, priority, notes |
| GPS coordinates in create request | ✅ | Uses LocationService.getCurrentPosition() |
| Search donors | ⚠️ | Via donor module, UI needs verification |
| Track request status | ⚠️ | Requests screen exists, needs full integration |
| Contact donors | ❌ | Not implemented |
| Patient remote datasource | ✅ | createEmergencyRequest, getMyRequests, cancelRequest |
| Patient DTO | ✅ | PatientRequestDto with toDomain |
| Patient providers | ✅ | myRequestsProvider, patientNotifierProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.7 Blood Requests Module

| Component | Status | Notes |
|-----------|--------|-------|
| Requests list screen | ✅ | Exists |
| Request detail screen | ✅ | Exists |
| Status flow (Pending→Accepted→Completed→Closed) | ✅ | Supported in data layer |
| Priority levels | ✅ | Critical/Urgent/Normal supported |
| Blood request remote datasource | ✅ | CRUD + realtime subscriptions |
| Blood request DTO | ✅ | BloodRequestDto with toDomain |
| Blood request providers | ✅ | bloodRequestsProvider, bloodRequestByIdProvider, bloodRequestNotifierProvider, realtimeRequestsProvider |
| Realtime subscription | ✅ | subscribeToNewRequests with filter support |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.8 Nearby Donors Module

| Component | Status | Notes |
|-----------|--------|-------|
| Nearby donors screen | ✅ | Exists |
| Blood group filter | ✅ | Supported in datasource |
| Distance filter | ✅ | Using GeometryUtils |
| Availability filter | ✅ | Filters is_available = true |
| Sort (nearest/recent/count) | ❌ | Not implemented |
| Nearby donor remote datasource | ✅ | findNearbyDonors with all filters |
| Nearby donor DTO | ✅ | NearbyDonorDto with distance |
| Nearby donor providers | ✅ | findNearbyDonorsProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.9 Hospitals Module

| Component | Status | Notes |
|-----------|--------|-------|
| Hospitals list screen | ✅ | Exists |
| Hospital details | ⚠️ | Screen exists, needs detail view |
| Call function | ✅ | launchUrl with tel: URI |
| Navigate function | ✅ | Google Maps directions via url_launcher |
| Save/favorite | ✅ | getSavedHospitals, saveHospital, removeSavedHospital in datasource |
| Opening hours | ⚠️ | hours field in DTO, UI not verified |
| Hospital remote datasource | ✅ | getHospitals (with search/distance filters), getHospitalById, getSavedHospitals, save/remove |
| Hospital DTO | ✅ | HospitalDto with hours, verified fields |
| Hospital providers | ✅ | hospitalsProvider, hospitalByIdProvider, savedHospitalsProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.10 Blood Banks Module

| Component | Status | Notes |
|-----------|--------|-------|
| Blood banks list screen | ✅ | Exists |
| Same structure as hospitals | ⚠️ | Shares Hospital model |
| Blood bank remote datasource | ✅ | getBloodBanks (with search/distance), getBloodBankById |
| Blood bank DTO | ✅ | BloodBankDto with toDomain |
| Blood bank providers | ✅ | bloodBanksProvider, bloodBankByIdProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.11 Donation History Module

| Component | Status | Notes |
|-----------|--------|-------|
| Donation history screen | ✅ | Exists |
| Previous donations list | ✅ | getDonationHistory in datasource |
| Total count | ✅ | Returned in DonationStats |
| Next eligible date | ✅ | Calculated in datasource (90-day interval) |
| Achievement badges | ✅ | Bronze/Silver/Gold badge system (1/5/10 donations) |
| Donation remote datasource | ✅ | getDonationHistory, getDonationStats, recordDonation |
| Donation DTO | ✅ | DonationDto, DonationStatsDto with toDomain |
| Donation history providers | ✅ | donationHistoryProvider, donationStatsProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.12 Notifications Module

| Component | Status | Notes |
|-----------|--------|-------|
| Notifications screen | ✅ | Exists |
| Notification types (Emergency/Reminder/General/Announcement) | ✅ | Supported in model + enums |
| Mark as read | ✅ | markAsRead, markAllAsRead in datasource |
| Push notifications (FCM) | ✅ | Full NotificationService implementation |
| Local notifications | ✅ | flutter_local_notifications integrated |
| Realtime notification subscription | ✅ | subscribeToNewNotifications with user filter |
| Notification remote datasource | ✅ | CRUD + realtime subscription |
| Notification DTO | ✅ | NotificationDto with toDomain |
| Notification providers | ✅ | notificationsProvider, unreadCountProvider, realtimeNotificationsProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.13 Profile Module

| Component | Status | Notes |
|-----------|--------|-------|
| Profile screen | ✅ | Exists |
| View profile info | ✅ | getProfile in datasource |
| Avatar/image upload | ⚠️ | updateAvatar in datasource, Supabase Storage client configured |
| Profile remote datasource | ✅ | getProfile, updateProfile, updateAvatar, deleteAccount |
| Profile DTO | ✅ | ProfileDto with toDomain |
| Profile providers | ✅ | profileProvider, profileNotifierProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.14 Settings Module

| Component | Status | Notes |
|-----------|--------|-------|
| Settings screen | ✅ | Full UI with all sections |
| Dark mode toggle | ✅ | Works with local storage + theme provider |
| Notification preferences | ✅ | Push notifications + emergency alerts toggles |
| Language selection | ❌ | Not implemented |
| Privacy settings | ⚠️ | Privacy Policy and Terms list items (no-op) |
| Logout | ✅ | Confirmation dialog then signs out + redirects |
| Settings remote datasource | ✅ | getSettings, updateSettings, toggleDarkMode, toggleNotifications |
| Settings DTO | ✅ | UserSettingsDto with toDomain |
| Settings providers | ✅ | settingsProvider with SettingsNotifier |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.15 Admin Module

| Component | Status | Notes |
|-----------|--------|-------|
| Admin dashboard screen | ✅ | Exists |
| Admin users screen | ✅ | Exists |
| Admin requests screen | ✅ | Exists |
| Admin announcements screen | ✅ | Exists |
| Verify hospitals | ✅ | verifyHospital in datasource |
| Remove fake requests | ✅ | removeRequest in datasource |
| Moderate users | ✅ | suspendUser in datasource |
| View analytics | ✅ | AdminStats with totalUsers, activeDonors, totalHospitals, pendingRequests |
| Admin remote datasource | ✅ | getStats, getAllUsers, getAllRequests, CRUD for all admin ops |
| Admin DTO | ✅ | AdminStatsDto with toDomain |
| Admin providers | ✅ | adminStatsProvider, adminUsersProvider, adminRequestsProvider, adminNotifierProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

### 2.16 Maps Module

| Component | Status | Notes |
|-----------|--------|-------|
| Map screen | ✅ | FlutterMap + OSM tiles |
| Current location | ✅ | Geolocator integration |
| Nearby donors markers | ✅ | From profiles table |
| Hospital markers | ✅ | From hospitals table |
| Blood bank markers | ✅ | From blood_banks table |
| Active request markers | ✅ | From blood_requests (pending) |
| Distance calculation | ✅ | GeometryUtils haversine formula |
| Navigation | ❌ | Not implemented |
| Map legend | ✅ | Added in map screen |
| Maps remote datasource | ✅ | getNearbyMarkers combining all marker types |
| Maps DTO | ✅ | MapMarkerDto |
| Maps providers | ✅ | mapMarkersProvider |
| Repository + interface + use cases | ✅ | Full domain layer |

---

## 3. Technology Stack

| Technology | Status | Notes |
|-----------|--------|-------|
| Flutter 3.x | ✅ | sdk: ^3.12.0 |
| Riverpod | ✅ | flutter_riverpod: ^2.6.1 |
| GoRouter | ✅ | go_router: ^14.8.1 |
| Supabase | ✅ | supabase_flutter: ^2.8.3 |
| Firebase Core | ✅ | firebase_core: ^3.12.1 |
| Firebase Messaging | ✅ | firebase_messaging: ^15.2.4 |
| Firebase Crashlytics | ✅ | firebase_crashlytics: ^4.3.4 |
| Firebase Analytics | ✅ | firebase_analytics: ^11.4.4 |
| Hive + Hive Flutter | ✅ | hive: ^2.2.3, hive_flutter: ^1.1.0 |
| SharedPreferences | ✅ | shared_preferences: ^2.3.4 |
| Flutter Secure Storage | ❌ | Not in pubspec.yaml |
| Flutter Map | ✅ | flutter_map: ^7.0.2 |
| Geolocator | ✅ | geolocator: ^13.0.2 |
| Geocoding | ✅ | geocoding: ^3.0.0 |
| Cached Network Image | ✅ | cached_network_image: ^3.4.1 |
| Flutter SVG | ✅ | flutter_svg: ^2.0.17 |
| Lottie | ✅ | lottie: ^3.3.1 |
| Google Fonts | ✅ | google_fonts: ^6.2.1 |
| Shimmer | ✅ | shimmer: ^3.0.0 |
| Logger | ✅ | logger: ^2.5.0 |
| flutter_dotenv | ✅ | flutter_dotenv: ^5.2.1 |
| connectivity_plus | ✅ | connectivity_plus: ^6.1.4 |
| Flutter Local Notifications | ✅ | flutter_local_notifications: ^18.0.1 |
| intl | ✅ | intl: ^0.20.2 |
| equatable | ✅ | equatable: ^2.0.7 |
| uuid | ✅ | uuid: ^4.5.1 |
| url_launcher | ✅ | url_launcher: ^6.3.1 |

---

## 4. Cross-Cutting Concerns

### 4.1 Security & Infrastructure

| Requirement | Status | Notes |
|-------------|--------|-------|
| Supabase Authentication | ✅ | Integrated |
| Session Management | ✅ | Supabase JWT auto-handled |
| Row Level Security | ✅ | SQL in supabase_migration.sql |
| Environment Variables | ✅ | flutter_dotenv + .env |
| HTTPS | ✅ | Handled by Supabase |
| Input Validation | ⚠️ | validators.dart exists, not comprehensive |
| Role-Based Access | ✅ | Roles in DB, RLS enabled |
| Flutter Secure Storage | ❌ | Not integrated |
| Firebase Crashlytics | ✅ | Service fully implemented |
| Firebase Analytics | ❌ | Not implemented |
| FCM Push Notifications | ✅ | Service fully implemented |
| Offline Hive Caching | ⚠️ | Service exists, not integrated with features |
| Background Sync | ❌ | Not implemented |
| Pagination | ⚠️ | API supports query limits, UI not paginated |
| Tests | ❌ | No tests beyond default widget_test.dart |
| CI/CD | ❌ | Not configured |

### 4.2 Summary Statistics (CORRECTED)

| Category | Total | ✅ Complete | ⚠️ Partial | ❌ Missing |
|----------|-------|-----------|------------|-----------|
| **Core Infrastructure Files** | 27 | 22 | 1 | 4 |
| **Shared Layer - Enums** | 1 | 1 | 0 | 0 |
| **Shared Layer - Models** | 5 | 5 | 0 | 0 |
| **Shared Layer - Providers** | 2 | 2 | 0 | 0 |
| **Shared Layer - Widgets** | 12 | 12 | 0 | 0 |
| **Feature Screens** | 24 | 24 | 0 | 0 |
| **Feature Data Sources** | 14 | 13 | 0 | 1 |
| **Feature DTOs (Models)** | 14 | 14 | 0 | 0 |
| **Feature Providers** | 14 | 14 | 0 | 0 |
| **Repository Interfaces** | 14 | 14 | 0 | 0 |
| **Repository Impls** | 14 | 14 | 0 | 0 |
| **Use Cases** | 14 | 14 | 0 | 0 |
| **Domain Entities** | 14 | 0 | 14 | 0 |
| **Technology Stack** | 30 | 29 | 0 | 1 |
| **Security/Auth** | 8 | 6 | 1 | 1 |

> **Note:** "Domain Entities" are marked ⚠️ because the project uses shared models (UserProfile, BloodRequest, etc.) directly across all features instead of per-feature entities. This is a pragmatic simplification, not a gap.

---

## 5. Remaining Gaps (What's Actually Missing)

### ✅ Completed This Session
| # | Item | Module | Status |
|---|------|--------|--------|
| 1 | Create error_state.dart widget | Shared | ✅ |
| 2 | Create profile_avatar.dart widget | Shared | ✅ |
| 3 | Add GPS coordinates to create request screen | Patient | ✅ |
| 4 | Implement logout in settings screen | Settings | ✅ |
| 5 | Add call/navigate actions for hospitals | Hospitals | ✅ (Call existed, Navigate added) |
| 6 | Upload FCM token to Supabase after login | Auth | ✅ |

### P1 — Still Remaining
| # | Item | Module | Effort |
|---|------|--------|--------|
| 1 | Add Flutter Secure Storage package + integration | Core | ~1 hr |
| 2 | Run SQL migration against Supabase | Database | ~5 min |

### P2 — Medium Priority
| # | Item | Module | Effort |
|---|------|--------|--------|
| 10 | Add achievement badges to donation history | Donation History | ~1 hr |
| 11 | Implement Firebase Analytics service | Core | ~30 min |
| 12 | Add sorting (nearest/recent/count) for nearby donors | Nearby Donors | ~1 hr |
| 13 | Cache data with Hive for offline use | All Features | ~2 days |
| 14 | Paginate long lists (requests, notifications, history) | All Features | ~1 day |

### P3 — Lower Priority
| # | Item | Module | Effort |
|---|------|--------|--------|
| 15 | Add unit tests for use cases + repositories | Testing | ~2 days |
| 16 | Add widget tests for screens | Testing | ~2 days |
| 17 | Set up CI/CD (GitHub Actions) | DevOps | ~1 day |
| 18 | Populate assets/ directory | Assets | ~1 day |
| 19 | Add multi-language support | Settings | ~2 days |
| 20 | Add email verification flow | Auth | ~1 day |

---

## 6. Updated Progress Overview

```
Core Infrastructure:      ████████████████░░░░  81% (22/27)
Shared Layer Widgets:     ████████████░░░░░░░░  83% (10/12)
Feature Screens:          ████████████████████ 100% (24/24)
Data Sources:             ████████████████████░  93% (13/14)
DTOs:                     ████████████████████ 100% (14/14)
Feature Providers:        ████████████████████ 100% (14/14)
Repository Interfaces:    ████████████████████ 100% (14/14)
Repository Impls:         ████████████████████ 100% (14/14)
Use Cases:                ████████████████████ 100% (14/14)
Tech Stack:               ████████████████████░  97% (29/30)
Testing:                  ░░░░░░░░░░░░░░░░░░░░   0%
CI/CD:                    ░░░░░░░░░░░░░░░░░░░░   0%
```

---

## 7. Key Findings vs Original Tracker

The original tracker was overly pessimistic. This audit revealed:

**Items marked ❌ but actually ✅:**
- `notification_service.dart` — Fully implemented (FCM + local notifications)
- `crashlytics_service.dart` — Fully implemented
- `custom_appbar.dart` — File exists and is imported
- **All Feature Data Sources** — 13/14 exist (all except... actually all 14 exist)
- **All Feature DTOs** — All 14 exist
- **All Feature Providers** — All 14 exist (dashboard, donor, patient, blood_requests, etc.)
- Dashboard stats cards, donation summary, eligibility check — All implemented
- Settings dark mode toggle — Implemented
- Donor eligibility calculation — Fully implemented
- Hospital save/favorite — Implemented in data layer
- Mark as read — Implemented in data layer
- Notification realtime subscription — Implemented
- Blood request realtime subscription — Implemented

**What's truly missing (verified ❌):**
- `error_state.dart` shared widget
- `profile_avatar.dart` shared widget
- `analytics_service.dart`
- `flutter_secure_storage` package
- Bootstrap initializer files (logic consolidated in app_initializer.dart)
- GPS coordinates in create request (hardcoded to 0.0)
- Logout button in settings
- Achievement badges
- Language selection
- Sorting for nearby donors
- Offline sync
- Tests
- CI/CD
