================================================================================
  BLOOD DONATION APP - PROJECT README
================================================================================
  A Flutter-based mobile application connecting blood donors, patients,
  hospitals, and blood banks in real-time.

  Version: 1.0.0
  Platform: Android / iOS
  Framework: Flutter 3.x
  State Management: Riverpod + GoRouter
  Backend: Supabase (PostgreSQL, Auth, Real-time)
  Offline Storage: Hive (caching only)

================================================================================
TABLE OF CONTENTS
================================================================================
1. Architecture Overview
2. Features
3. Tech Stack
4. Project Structure
5. Setup Guide
6. Authentication Flow
7. Offline Caching
8. Deep Links
9. Onboarding
10. Hero Transitions
11. Key Screens
12. Environment Variables
13. Supabase Configuration

================================================================================
1. ARCHITECTURE OVERVIEW
================================================================================

The app follows a feature-first architecture with a shared core:

  lib/
  ├── core/          # Shared utilities, theme, network, database, errors
  ├── features/      # Feature modules (each with screens, providers, services)
  ├── shared/        # Shared models, providers, widgets
  └── main.dart      # App entry point

Key patterns:
  - StateNotifier + Riverpod for state management
  - GoRouter with auth state redirects
  - Repository pattern with remote data sources
  - Offline-first caching via CachedApiService + Hive
  - Supabase for auth, database, and real-time subscriptions

================================================================================
2. FEATURES
================================================================================

  [✓] User Authentication (Email/Password, OAuth)
  [✓] Email Verification with Deep Links
  [✓] Password Reset Flow
  [✓] Onboarding Screens (persisted via SharedPreferences)
  [✓] Role-based Dashboards (Donor, Patient, Hospital, Admin)
  [✓] Donor Profile Management
  [✓] Blood Request System (Create, Accept, Complete)
  [✓] Emergency Request Priority (Urgent, Critical)
  [✓] Push Notifications (FCM)
  [✓] Nearby Donor Discovery (GPS-based)
  [✓] Hospital & Blood Bank Directory
  [✓] Donation History with Pagination
  [✓] Donor Achievements/Levels
  [✓] Admin Panel (Users, Requests, Reports, Announcements)
  [✓] Offline Caching (Hospitals, Blood Banks, Profiles, Notifications, Settings)
  [✓] Multi-language Support
  [✓] Hero Transitions

================================================================================
3. TECH STACK
================================================================================

  Frontend:
    - Flutter 3.x (Dart)
    - Riverpod (State Management)
    - GoRouter (Navigation)
    - Freezed (Data Classes)
    - Hive (Offline Cache)
    - SharedPreferences (Simple Persistence)
    - FCM (Push Notifications)

  Backend:
    - Supabase (PostgreSQL)
    - Supabase Auth (Email/Password, OAuth)
    - Supabase Realtime (Live Updates)
    - Edge Functions (Push Notifications)

================================================================================
4. PROJECT STRUCTURE
================================================================================

  lib/
  ├── bootstrap/
  │   └── app_initializer.dart    # App initialization (Hive, Firebase, etc.)
  │
  ├── core/
  │   ├── constants/              # App-wide constants
  │   ├── database/               # Hive cache manager
  │   ├── errors/                 # Error handling & user-friendly messages
  │   ├── network/                # API service, cached API, connectivity
  │   ├── routes/                 # GoRouter configuration
  │   ├── services/               # Logger, localization, analytics, notifications
  │   ├── storage/                # Secure storage (auth tokens)
  │   ├── theme/                  # Colors, typography, themes
  │   └── utils/                  # Helpers (geometry, eligibility)
  │
  ├── features/
  │   ├── admin/                  # Admin dashboard, users, requests, reports
  │   ├── authentication/         # Login, register, forgot/reset password, verify
  │   ├── blood_banks/            # Blood bank directory & registration
  │   ├── blood_requests/         # Request listing & detail
  │   ├── dashboard/              # Role-based home screens
  │   ├── donation_history/       # Donation records with pagination
  │   ├── donor/                  # Donor profile & edit
  │   ├── health_tips/            # Health tips screen
  │   ├── hospitals/              # Hospital directory & registration
  │   ├── maps/                   # Map-based location views
  │   ├── nearby_donors/          # GPS-based donor search
  │   ├── notifications/          # Notification list & detail
  │   ├── onboarding/             # Onboarding pages
  │   ├── patient/                # Patient dashboard & request creation
  │   ├── profile/                # User profile screen
  │   ├── settings/               # App settings
  │   └── splash/                 # Splash screen
  │
  ├── shared/
  │   ├── models/                 # Data models (Donation, Hospital, User, etc.)
  │   ├── providers/              # Auth, theme, locale providers
  │   └── widgets/                # Reusable UI components
  │
  ├── app.dart                    # MaterialApp configuration
  ├── main.dart                   # Entry point
  └── firebase_options.dart       # Firebase config (auto-generated)

================================================================================
5. SETUP GUIDE
================================================================================

  Prerequisites:
    - Flutter SDK 3.x
    - Android Studio / Xcode
    - A Supabase project
    - A Firebase project (for FCM)

  Steps:

    1. Clone the repository
    2. Install dependencies:
         flutter pub get

    3. Create .env file:
         SUPABASE_URL=https://your-project.supabase.co
         SUPABASE_ANON_KEY=your-anon-key

    4. Run migrations (Supabase SQL Editor):
         Execute supabase_migration.sql

    5. Run the app:
         flutter run

================================================================================
6. AUTHENTICATION FLOW
================================================================================

  Registration:
    1. User signs up with email + password
    2. Supabase sends verification email
    3. Deep link opens app on click
    4. App detects verified status and signs user out for manual login
    5. User logs in with credentials

  Login:
    1. User enters email + password
    2. Supabase authenticates and returns session
    3. Profile loaded from profiles table
    4. FCM token uploaded
    5. GoRouter redirects to role-specific dashboard

  Password Reset:
    1. User enters email on forgot-password screen
    2. Supabase sends reset link with redirectTo deep link
    3. Clicking link opens app
    4. passwordRecovery event detected
    5. Router redirects to reset-password screen
    6. User sets new password and is signed out

  Deep Link URL:  com.blooddonation.app://verify
  Applies to:     - Email verification redirect
                  - Password reset redirect

================================================================================
7. OFFLINE CACHING
================================================================================

  Cached data tables (via CachedApiService + Hive):
    - cached_hospitals     ✓
    - cached_blood_banks   ✓
    - cached_profiles      ✓
    - cached_notifications ✓
    - cached_settings      ✓
    - cached_donations     ✓

  NOT cached (real-time safety-critical):
    - blood_requests (CachedApiService has a guard assertion)

  How it works:
    1. On successful API fetch, data is cached to Hive
    2. On network failure, cached data is returned if available
    3. Each cache box tracks a refresh timestamp
    4. Stale cache (default: 30 min TTL) triggers background refresh
    5. All caches are cleared on logout

================================================================================
8. DEEP LINKS
================================================================================

  Scheme:  com.blooddonation.app://

  Android (AndroidManifest.xml):
    <intent-filter>
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="com.blooddonation.app" android:host="verify" />
    </intent-filter>

  iOS (Info.plist):
    <key>CFBundleURLTypes</key>
    <array>
      <dict>
        <key>CFBundleURLSchemes</key>
        <array><string>com.blooddonation.app</string></array>
      </dict>
    </array>

  Supabase Dashboard Configuration:
    Site URL:              com.blooddonation.app://
    Redirect URLs:         com.blooddonation.app://verify

================================================================================
9. ONBOARDING
================================================================================

  - 3-page onboarding flow (Find Donors, Real-time Location, Notifications)
  - Completion persisted via SharedPreferences (key: 'onboarding_completed')
  - AuthStateProvider checks SharedPreferences on app cold start
  - Until persisted, user sees onboarding on every fresh launch
  - After completion, user is redirected directly to login

================================================================================
10. HERO TRANSITIONS
================================================================================

  Hero transitions are used to create smooth animations between screens
  when navigating between a list item and its detail view:

    - Blood Request Cards  →  Request Detail Screen
      Tag: 'request_{id}_icon'
      Element: Priority/Blood icon animates from card to detail

================================================================================
11. KEY SCREENS
================================================================================

  Screen                  Route                   Description
  ─────────────────────────────────────────────────────────────────────
  Splash                  /splash                 App initialization
  Onboarding              /onboarding             3-page intro
  Login                   /auth/login             Login form
  Register                /auth/login/register    Registration form
  Forgot Password         /auth/login/forgot-pwd  Password reset email
  Reset Password          /auth/login/reset-pwd   New password form
  Email Verification      /auth/login/verify-email Verification pending
  Dashboard               /dashboard              Donor home
  Patient                 /patient                Patient home
  Hospital Dashboard      /hospital-dashboard     Hospital home
  Donor Profile           /donor                  Donor info & eligibility
  Profile                 /profile                User profile & menu
  Settings                /settings               App settings
  Blood Requests          /requests               All active requests
  Request Detail          /requests/:id           Single request
  Donation History        /donation-history       Paginated donation log
  Hospitals               /hospitals              Hospital directory
  Blood Banks             /blood-banks            Blood bank directory
  Nearby Donors           /donors                 GPS donor search
  Notifications           /notifications          Notification list
  Health Tips             /health-tips            Health info
  Admin Dashboard         /admin                  Admin home
  Admin Users             /admin/users            User management
  Admin Requests          /admin/requests         Request management
  Admin Announcements     /admin/announcements    Send announcements
  Admin Reports           /admin/reports          User reports
  Admin Approvals         /admin/approvals        Verify hospitals/banks

================================================================================
12. ENVIRONMENT VARIABLES
================================================================================

  Variable              Description
  ─────────────────────────────────────────────────────────────────────
  SUPABASE_URL          Supabase project URL
  SUPABASE_ANON_KEY     Supabase anonymous API key

  File: .env (not committed to git)

================================================================================
13. SUPABASE CONFIGURATION
================================================================================

  Authentication:
    - Confirm email: ON
    - Site URL:      com.blooddonation.app://
    - Redirect URLs: com.blooddonation.app://verify

  Database:
    Tables: profiles, hospitals, blood_banks, blood_requests,
            donations, notifications, saved_locations, reports,
            announcements, fcm_tokens

  RLS (Row Level Security):
    - Applied to all tables
    - Users can only access their own data
    - Admins have elevated access via role check

  Edge Functions:
    - send-push-notification: Sends FCM push on new requests/updates

================================================================================
  © 2026 Blood Donation App | Built with Flutter & Supabase
================================================================================
