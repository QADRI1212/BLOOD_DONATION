import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/main_shell.dart';
import '../services/analytics_service.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/authentication/screens/login_screen.dart';
import '../../features/authentication/screens/register_screen.dart';
import '../../features/authentication/screens/forgot_password_screen.dart';
import '../../features/authentication/screens/reset_password_screen.dart';
import '../../features/authentication/screens/email_verification_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/donor/screens/donor_screen.dart';
import '../../features/donor/screens/donor_edit_screen.dart';
import '../../features/patient/screens/patient_screen.dart';
import '../../features/patient/screens/create_request_screen.dart';
import '../../features/blood_requests/screens/blood_requests_screen.dart';
import '../../features/blood_requests/screens/request_detail_screen.dart';
import '../../features/nearby_donors/screens/nearby_donors_screen.dart';
import '../../features/hospitals/screens/hospitals_screen.dart';
import '../../features/hospitals/screens/hospital_dashboard_screen.dart';
import '../../features/hospitals/screens/hospital_register_screen.dart';
import '../../features/blood_banks/screens/blood_bank_register_screen.dart';
import '../../features/blood_banks/screens/blood_banks_screen.dart';
import '../../features/donation_history/screens/donation_history_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/notifications/screens/notification_detail_screen.dart';
import '../../shared/models/app_notification.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/health_tips/screens/health_tips_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_users_screen.dart';
import '../../features/admin/screens/admin_requests_screen.dart';
import '../../features/admin/screens/admin_announcements_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_approvals_screen.dart';

class AppRouter {
  final AuthStateProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: _handleRedirect,
    routes: _routes,
    observers: [
      AnalyticsScreenObserver(),
    ],
  );

  String? _handleRedirect(BuildContext context, GoRouterState state) {
    final isAuthenticated = authProvider.isAuthenticated;
    final isOnboardingComplete = authProvider.isOnboardingComplete;
    final currentPath = state.matchedLocation;

    // Splash screen - always allow
    if (currentPath == '/splash') return null;

    // Onboarding - wait for loading to complete before redirecting
    if (authProvider.isOnboardingLoading) return null;

    // Password recovery mode — redirect to the reset password screen
    // regardless of auth state, so the user can set a new password.
    if (authProvider.isRecoveryMode && currentPath != '/auth/login/reset-password') {
      return '/auth/login/reset-password';
    }

    // Onboarding
    if (!isOnboardingComplete && currentPath != '/onboarding') {
      return '/onboarding';
    }
    if (currentPath == '/onboarding' && isOnboardingComplete && !isAuthenticated) {
      return '/auth/login';
    }

    // Auth routes
    if (!isAuthenticated) {
      if (currentPath.startsWith('/auth')) return null;
      if (currentPath == '/onboarding') return null;
      return '/auth/login';
    }

    // Authenticated users - redirect away from auth pages to role-specific home
    if (currentPath.startsWith('/auth') && currentPath != '/auth/login/reset-password') {
      return _defaultRouteForRole(authProvider.userRole);
    }

    // Redirect from root to role-specific home
    if (currentPath == '/') {
      return _defaultRouteForRole(authProvider.userRole);
    }

    // Admin routes - only allow admins
    if (currentPath.startsWith('/admin') && authProvider.userRole != 'admin') {
      return _defaultRouteForRole(authProvider.userRole);
    }

    return null;
  }

  /// Returns the default home route based on the user's role.
  String _defaultRouteForRole(String? role) {
    switch (role) {
      case 'patient':
        return '/patient';
      case 'hospital':
        return '/hospital-dashboard';
      case 'admin':
        return '/admin';
      case 'donor':
      default:
        return '/dashboard';
    }
  }

  List<RouteBase> get _routes => [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth/login',
          builder: (context, state) => const LoginScreen(),
          routes: [
            GoRoute(
              path: 'register',
              builder: (context, state) => const RegisterScreen(),
            ),
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) => const ForgotPasswordScreen(),
            ),
            GoRoute(
              path: 'reset-password',
              builder: (context, state) => const ResetPasswordScreen(),
            ),
            GoRoute(
              path: 'verify-email',
              builder: (context, state) {
                final email = state.extra as String? ?? '';
                return EmailVerificationScreen(email: email);
              },
            ),
          ],
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/donor',
              builder: (context, state) => const DonorScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const DonorEditScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/patient',
              builder: (context, state) => const PatientScreen(),
              routes: [
                GoRoute(
                  path: 'create-request',
                  builder: (context, state) => const CreateRequestScreen(),
                ),
              ],
            ),
            GoRoute(
              path: '/requests',
              builder: (context, state) => const BloodRequestsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return RequestDetailScreen(requestId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/donors',
              builder: (context, state) => const NearbyDonorsScreen(),
            ),
            GoRoute(
              path: '/hospital-dashboard',
              builder: (context, state) => const HospitalDashboardScreen(),
            ),
            GoRoute(
              path: '/hospital/register',
              builder: (context, state) => const HospitalRegisterScreen(),
            ),
            GoRoute(
              path: '/blood-bank/register',
              builder: (context, state) => const BloodBankRegisterScreen(),
            ),
            GoRoute(
              path: '/hospitals',
              builder: (context, state) => const HospitalsScreen(),
            ),
            GoRoute(
              path: '/blood-banks',
              builder: (context, state) => const BloodBanksScreen(),
            ),
            GoRoute(
              path: '/donation-history',
              redirect: (context, state) {
                // Restrict to donors only
                if (authProvider.userRole != 'donor') {
                  return '/dashboard';
                }
                return null;
              },
              builder: (context, state) => const DonationHistoryScreen(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) {
                    final notification = state.extra as AppNotification;
                    return NotificationDetailScreen(notification: notification);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: '/health-tips',
              builder: (context, state) => const HealthTipsScreen(),
            ),
            GoRoute(
              path: '/admin',
              builder: (context, state) => const AdminDashboardScreen(),
              routes: [
                GoRoute(
                  path: 'users',
                  builder: (context, state) => const AdminUsersScreen(),
                ),
                GoRoute(
                  path: 'requests',
                  builder: (context, state) => const AdminRequestsScreen(),
                ),
                GoRoute(
                  path: 'announcements',
                  builder: (context, state) => const AdminAnnouncementsScreen(),
                ),
                GoRoute(
                  path: 'reports',
                  builder: (context, state) => const AdminReportsScreen(),
                ),
                GoRoute(
                  path: 'approvals',
                  builder: (context, state) => const AdminApprovalsScreen(),
                ),
              ],
            ),
          ],
        ),
      ];
}
