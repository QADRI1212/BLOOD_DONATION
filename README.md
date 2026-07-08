# Smart Blood & Emergency Donor Network 🩸

A Flutter-based mobile application connecting blood donors, patients, hospitals, and blood banks in real-time.

[![Flutter CI/CD](https://github.com/QADRI1212/BLOOD_DONATION/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/QADRI1212/BLOOD_DONATION/actions/workflows/flutter_ci.yml)

---

## Features

- **User Authentication** — Email/password with email verification & deep links
- **Role-based Dashboards** — Donor, Patient, Hospital, Admin
- **Blood Request System** — Create, accept, complete with priority levels
- **Push Notifications** — FCM-based alerts for new requests & updates
- **Nearby Donor Discovery** — GPS-based donor search within radius
- **Hospital & Blood Bank Directory** — Verified listings with maps & contact
- **Donation History** — Paginated records with achievements & levels
- **Admin Panel** — User management, requests, announcements, reports, approvals
- **Offline Caching** — Hive-powered offline support for 6 data tables
- **Hero Transitions** — Smooth animated transitions across screens
- **Multi-language Support** — English, Hindi, Urdu, and more
- **Dark Mode** — Theme-aware UI with light/dark support

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | Flutter 3.x, Dart |
| **State Management** | Riverpod + GoRouter |
| **Backend** | Supabase (PostgreSQL, Auth, Realtime) |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **Offline Storage** | Hive + SharedPreferences |
| **Maps** | FlutterMap + OpenStreetMap |
| **Analytics** | Firebase Analytics + Crashlytics |

## Architecture

```
lib/
├── core/          # Theme, network, database, errors, routes
├── features/      # 14 feature modules (auth, dashboard, requests, etc.)
├── shared/        # Models, providers, reusable widgets
└── main.dart      # Entry point
```

## Screens (30+ Routes)

| Screen | Route | Role |
|--------|-------|------|
| Splash | `/splash` | All |
| Onboarding | `/onboarding` | New users |
| Login | `/auth/login` | All |
| Register | `/auth/login/register` | New users |
| Dashboard | `/dashboard` | Donor |
| Patient | `/patient` | Patient |
| Blood Requests | `/requests` | All |
| Donation History | `/donation-history` | Donor |
| Hospitals | `/hospitals` | All |
| Blood Banks | `/blood-banks` | All |
| Nearby Donors | `/donors` | Donor |
| Admin Panel | `/admin` | Admin |
| *and 20+ more...* | | |

## Setup

```bash
# Prerequisites: Flutter 3.x, Supabase project, Firebase project

git clone https://github.com/QADRI1212/BLOOD_DONATION.git
cd blood_donation
flutter pub get

# Create .env file with your Supabase credentials
echo "SUPABASE_URL=https://your-project.supabase.co" > .env
echo "SUPABASE_ANON_KEY=your-anon-key" >> .env

# Run migrations in Supabase SQL Editor (supabase_migration.sql)
# Run the app
flutter run
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anonymous API key |

## CI/CD

GitHub Actions automatically runs on every push to `main`:

1. **Analyze** — `flutter analyze` for code quality
2. **Test** — `flutter test` with coverage
3. **Build Android** — Debug APK uploaded as artifact
4. **Build iOS** — Debug build (no codesign)

---

Built with ❤️ using Flutter & Supabase
