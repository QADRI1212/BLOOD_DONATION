# Technical Requirements Document (TRD)

## Smart Blood & Emergency Donor Network

**Version:** 1.0
**Project Type:** Production-Ready Mobile Application
**Platform:** Android (Primary), iOS (Future Support)
**Framework:** Flutter 3.x
**Architecture:** Clean Architecture + Feature First Architecture
**State Management:** Riverpod (Code Generation)
**Backend Platform:** Supabase (Backend-as-a-Service)
**Database:** PostgreSQL (Supabase)
**Authentication:** Supabase Authentication
**Notifications:** Firebase Cloud Messaging (FCM)
**Maps:** Flutter Map + OpenStreetMap (OSM)
**Local Storage:** Hive + SharedPreferences + Flutter Secure Storage

---

# 1. Technical Overview

The Smart Blood & Emergency Donor Network is a production-grade healthcare mobile application that enables secure and real-time communication between blood donors, patients, hospitals, blood banks, and administrators.

The system follows **Feature-First Clean Architecture** to ensure scalability, maintainability, modularity, and testability. Instead of using a custom backend, the application leverages **Supabase** as a Backend-as-a-Service (BaaS), providing authentication, PostgreSQL, real-time database capabilities, storage, and security through Row Level Security (RLS). Push notifications are handled using **Firebase Cloud Messaging (FCM)**.

---

# 2. System Architecture

```text
                        Flutter Mobile App
                               │
                               ▼
                  Riverpod State Management
                               │
                               ▼
                     Domain (Use Cases)
                               │
                               ▼
                  Repository Abstraction Layer
                               │
               ┌───────────────┴───────────────┐
               ▼                               ▼
       Supabase Services               Local Storage
 (Auth, PostgreSQL, Realtime, Storage)  (Hive, SharedPreferences)
               │
               ▼
     Firebase Cloud Messaging (FCM)
               │
               ▼
         Push Notifications
```

---

# 3. Technology Stack

| Layer                 | Technology                  |
| --------------------- | --------------------------- |
| Mobile Framework      | Flutter 3.x                 |
| Programming Language  | Dart                        |
| Architecture          | Clean Architecture          |
| Project Organization  | Feature First               |
| State Management      | Riverpod                    |
| Routing               | GoRouter                    |
| Backend               | Supabase                    |
| Database              | PostgreSQL                  |
| Authentication        | Supabase Auth               |
| Local Database        | Hive                        |
| Secure Storage        | Flutter Secure Storage      |
| Preferences           | SharedPreferences           |
| Maps                  | Flutter Map                 |
| Location              | Geolocator                  |
| Reverse Geocoding     | Geocoding                   |
| Push Notifications    | Firebase Cloud Messaging    |
| Local Notifications   | Flutter Local Notifications |
| Image Cache           | Cached Network Image        |
| SVG Support           | Flutter SVG                 |
| Animations            | Lottie                      |
| Logging               | Logger                      |
| Environment Variables | flutter_dotenv              |
| Crash Reporting       | Firebase Crashlytics        |
| Analytics             | Firebase Analytics          |

---

# 4. Project Architecture

The application follows **Feature-First Clean Architecture**.

```
Presentation Layer
        │
        ▼
Riverpod Providers
        │
        ▼
Use Cases
        │
        ▼
Repository Interfaces
        │
        ▼
Repository Implementations
        │
        ▼
Supabase Services
```

Each feature is isolated into three layers:

### Presentation

Responsible for:

* UI
* Riverpod Providers
* State Management
* Navigation

---

### Domain

Responsible for:

* Business Logic
* Entities
* Repository Contracts
* Use Cases

---

### Data

Responsible for:

* Supabase Queries
* Local Storage
* Models
* Repository Implementations

---

# 5. Functional Modules

## Authentication Module

### Features

* Register
* Login
* Forgot Password
* Email Verification
* Logout
* Session Persistence

### Authentication Flow

```
User

↓

Login Screen

↓

Supabase Authentication

↓

JWT Token

↓

Store Secure Session

↓

Dashboard
```

---

## Donor Module

Stores

* Blood Group
* Medical Eligibility
* Donation History
* Availability Status
* GPS Coordinates

Functions

* Register as Donor
* Edit Profile
* Toggle Availability
* Update Last Donation Date

---

## Patient Module

Allows

* Search Blood Donors
* Create Emergency Requests
* Track Requests
* Contact Donors

---

## Emergency Request Module

Workflow

```
Create Request

↓

Save to Supabase

↓

Realtime Update

↓

Nearby Donors

↓

Push Notification

↓

Accept Request

↓

Complete
```

---

## Nearby Donor Module

Uses

* GPS
* Latitude
* Longitude

Filters

* Blood Group
* Distance
* Availability
* Eligibility

---

## Hospital Module

Stores

* Hospital Details
* GPS
* Contact
* Opening Hours

Supports

* Search
* Save
* Navigate
* Call

---

## Blood Bank Module

Same implementation as Hospital.

---

## Donation History Module

Maintains

* Total Donations
* Last Donation
* Next Eligible Date
* Achievement Badges

---

## Notifications Module

Uses

Firebase Cloud Messaging

Categories

* Emergency
* Reminder
* General
* Announcement

---

## Settings Module

Stores

* Theme
* Notification Preferences
* Language
* Privacy

---

# 6. Database Design (Supabase)

## Tables

### profiles

```
id
name
email
phone
blood_group
gender
age
weight
city
latitude
longitude
last_donation_date
is_available
role
created_at
updated_at
```

---

### blood_requests

```
id
patient_id
blood_group
units
hospital_id
latitude
longitude
status
priority
notes
created_at
```

---

### donations

```
id
donor_id
hospital_id
units
donation_date
remarks
```

---

### hospitals

```
id
name
address
latitude
longitude
phone
verified
```

---

### blood_banks

```
id
name
address
latitude
longitude
phone
```

---

### notifications

```
id
user_id
title
body
type
is_read
created_at
```

---

### user_settings

```
id
user_id
theme
language
notification_enabled
```

---

### announcements

```
id
title
description
created_at
```

---

### reports

```
id
reporter_id
reported_user
reason
status
```

---

# 7. Supabase Integration

Used Services

* Authentication
* PostgreSQL
* Storage
* Realtime
* Row Level Security

Authentication

* Email Login
* Registration
* Password Reset
* JWT Sessions

Realtime

* Emergency Requests
* Notifications
* Donor Availability

Storage

* Profile Images
* Hospital Images
* Documents

---

# 8. Firebase Integration

Firebase Services

### Firebase Core

Application initialization.

---

### Firebase Cloud Messaging

Push Notifications

* Emergency Requests
* Donation Reminder
* Request Accepted
* Announcements

---

### Firebase Crashlytics

Automatic crash reports.

---

### Firebase Analytics

User analytics.

---

# 9. Riverpod State Management

Use

* Provider
* FutureProvider
* StreamProvider
* AsyncNotifier
* Notifier

Avoid

* Global Variables
* setState for business logic

Benefits

* Testable
* Predictable
* Scalable
* Optimized Rebuilds

---

# 10. Local Storage Strategy

## Hive

Stores

* Cached Donors
* Cached Hospitals
* Cached Blood Banks
* Notifications
* Offline Requests

---

## SharedPreferences

Stores

* Theme
* Language
* Intro Completed

---

## Flutter Secure Storage

Stores

* JWT
* Session Tokens

---

# 11. Maps & Location

Packages

* flutter_map
* geolocator
* geocoding

Features

* Current Location
* Nearby Donors
* Hospitals
* Blood Banks
* Distance Calculation
* Navigation

---

# 12. Notification Workflow

```
Patient Creates Request

↓

Save in Supabase

↓

Realtime Event Triggered

↓

Firebase Cloud Messaging

↓

Nearby Donor Receives Notification

↓

Donor Accepts Request

↓

Patient Receives Update
```

---

# 13. Security

## Authentication

Supabase Auth

---

## Authorization

Role Based Access

* Admin
* Donor
* Patient
* Hospital

---

## Database Security

Row Level Security

Policies

* User accesses only own profile.
* Donors update only their records.
* Hospitals manage only verified requests.
* Admin has full access.

---

## API Security

HTTPS Only

JWT Authentication

Environment Variables

No Secret Keys in Source Code

---

## Input Validation

Email

Phone

Age

Blood Group

Password

Medical Information

---

# 14. Performance Optimization

* Riverpod selective rebuilds
* Pagination
* Lazy Loading
* Cached Images
* Offline Cache
* Indexed PostgreSQL Queries
* Const Widgets
* Debounced Search
* Background Data Refresh

---

# 15. Offline Support

Available Offline

* Profile
* Donation History
* Saved Hospitals
* Notifications
* Settings

Synchronization

```
Offline

↓

Store in Hive

↓

Internet Available

↓

Auto Sync

↓

Supabase
```

---

# 16. Error Handling

Handle

* Internet Failure
* GPS Disabled
* Permission Denied
* Authentication Failure
* Server Timeout
* Database Failure

Display

* Friendly Error Messages
* Retry Button
* Empty States
* Offline Screen

---

# 17. Logging & Monitoring

Logger

* Debug Logs
* API Logs
* Error Logs

Firebase Crashlytics

* Crash Reports
* Stack Traces

Analytics

* Screen Tracking
* User Activity
* Feature Usage

---

# 18. Testing Strategy

### Unit Testing

* Use Cases
* Repositories
* Helpers

### Widget Testing

* Login
* Dashboard
* Donor Card

### Integration Testing

* Authentication
* Emergency Request Flow
* Notifications

---

# 19. Environment Management

Development

```
.env.dev
```

Staging

```
.env.staging
```

Production

```
.env.production
```

Variables

* Supabase URL
* Supabase Anon Key
* Firebase Config
* Map Configuration

---

# 20. CI/CD (Recommended)

* GitHub Repository
* GitHub Actions
* Automated Flutter Analyze
* Automated Unit Tests
* APK Build Pipeline
* Release Build Pipeline

---

# 21. Production Readiness Checklist

### Architecture

* ✅ Feature-First Clean Architecture
* ✅ Modular codebase
* ✅ SOLID principles
* ✅ Repository pattern
* ✅ Dependency inversion

### Security

* ✅ Supabase Authentication
* ✅ Row Level Security (RLS)
* ✅ JWT session management
* ✅ Secure Storage for tokens
* ✅ Environment variables
* ✅ HTTPS-only communication
* ✅ Input validation and sanitization

### Performance

* ✅ Lazy loading
* ✅ Pagination
* ✅ Image caching
* ✅ Optimized Riverpod rebuilds
* ✅ Background synchronization
* ✅ Indexed database queries

### Reliability

* ✅ Offline-first data caching
* ✅ Retry mechanisms
* ✅ Global exception handling
* ✅ Crash reporting
* ✅ Real-time updates
* ✅ Network connectivity monitoring

### User Experience

* ✅ Material 3 design
* ✅ Responsive layouts
* ✅ Light & Dark themes
* ✅ Accessibility support
* ✅ Smooth animations
* ✅ Loading, empty, and error states

### Monitoring

* ✅ Firebase Crashlytics
* ✅ Firebase Analytics
* ✅ Structured logging

### Maintainability

* ✅ Feature-based folder structure
* ✅ Comprehensive documentation
* ✅ Unit, widget, and integration tests
* ✅ CI/CD readiness
* ✅ Version-controlled environment configurations

---

# 22. Future Scalability

The chosen architecture allows seamless addition of new capabilities without major refactoring, including:

* AI-based donor matching and prioritization
* QR code donor verification
* Live donor location tracking during active requests
* Multi-language localization
* Voice-based emergency requests
* Wear OS and smartwatch notifications
* Volunteer management
* Blood donation camp scheduling
* Web-based administrative dashboard
* Integration with hospital management systems (HMS)
* Predictive analytics for blood demand and donor availability

---

## Conclusion

This technical design leverages **Flutter**, **Riverpod**, **Supabase**, **Firebase Cloud Messaging**, **Hive**, and **Flutter Map** to create a **secure, scalable, modular, and production-ready healthcare application**. By following Clean Architecture, implementing robust security with Supabase RLS, optimizing performance, supporting offline functionality, and incorporating monitoring, testing, and CI/CD practices, the project is positioned to meet professional software engineering standards suitable for real-world deployment and future expansion.
