import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_donation/shared/widgets/main_shell.dart';
import 'package:blood_donation/shared/providers/auth_provider.dart';
import 'package:blood_donation/features/notifications/providers/notification_provider.dart';
import 'package:blood_donation/shared/models/user_profile.dart';

/// Mock auth notifier — uses [AuthNotifier.test] to skip the Supabase
/// _checkSession() call so tests can run without a real Supabase instance.
class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier() : super.test();
}

/// Helper to create a test user profile.
UserProfile createTestUser({String role = 'donor'}) {
  return UserProfile(
    id: 'test-user-1',
    name: 'Test Donor',
    email: 'donor@test.com',
    role: role,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Wraps [MainShell] in [ProviderScope] with mocked providers, a
/// [MaterialApp.router] for GoRouter context, and [ScreenUtilInit].
///
/// The [body] callback receives the [MockAuthNotifier] so the test can
/// set the desired auth state via `mockAuth.state = ...`.
Future<void> withMainShell(
  WidgetTester tester, {
  required void Function(MockAuthNotifier mockAuth) body,
  int unreadCount = 0,
}) async {
  final mockAuth = MockAuthNotifier();

  // Create a fresh GoRouter per test to avoid state leaking between tests.
  final goRouter = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const Scaffold(body: Center(child: Text('Home Content'))),
          ),
          GoRoute(path: '/dashboard', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/requests', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/donors', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/hospitals', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/notifications', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/profile', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/settings', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/patient', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/admin', builder: (_, _) => const Scaffold()),
          GoRoute(
            path: '/hospital-dashboard',
            builder: (_, _) => const Scaffold(),
          ),
          GoRoute(path: '/blood-bank', builder: (_, _) => const Scaffold()),
        ],
      ),
    ],
  );

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => mockAuth),
          unreadCountProvider.overrideWith((ref, userId) async => unreadCount),
        ],
        child: MaterialApp.router(routerConfig: goRouter),
      ),
    ),
  );

  body(mockAuth);

  // Use pumpAndSettle so any Material Badge animations complete
  await tester.pumpAndSettle();
}

void main() {
  group('MainShell with notification badge', () {
    testWidgets('renders bottom navigation with correct tabs', (tester) async {
      final user = createTestUser();
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
      );

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Hospitals'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows Requests tab for donor role', (tester) async {
      final user = createTestUser(role: 'donor');
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
      );

      expect(find.text('Requests'), findsOneWidget);
    });

    testWidgets('shows badge when there are unread notifications', (
      tester,
    ) async {
      final user = createTestUser();
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
        unreadCount: 5,
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('does not show badge when unread count is 0', (tester) async {
      final user = createTestUser();
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
        unreadCount: 0,
      );

      expect(find.text('0'), findsNothing);
    });

    testWidgets('shows truncated badge count for 10+ notifications', (
      tester,
    ) async {
      final user = createTestUser();
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
        unreadCount: 10,
      );

      expect(find.text('9+'), findsOneWidget);
    });

    testWidgets('handles unauthenticated user gracefully', (tester) async {
      await withMainShell(tester, body: (_) {});

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('shows Donors tab for patient role', (tester) async {
      final user = createTestUser(role: 'patient');
      await withMainShell(
        tester,
        body: (mockAuth) {
          mockAuth.state = AsyncValue.data(user);
        },
      );

      expect(find.text('Donors'), findsOneWidget);
    });
  });
}
