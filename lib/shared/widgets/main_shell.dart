import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;
    final userRole = user?.role ?? 'donor';
    final unreadCount = user != null
        ? ref.watch(unreadCountProvider(user.id))
        : null;

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context, userRole, unreadCount),
    );
  }

  Widget _buildBottomNav(BuildContext context, String role, AsyncValue<int>? unreadCount) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    int currentIndex = _currentIndex(currentLocation);
    
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTap(context, index, role),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        items: _navItems(role, unreadCount),
      ),
    );
  }

  int _unreadBadgeCount(AsyncValue<int>? unreadCount) {
    return unreadCount?.valueOrNull ?? 0;
  }

  int _currentIndex(String location) {
    if (location == '/hospital-dashboard' ||
        location.startsWith('/dashboard') ||
        location.startsWith('/patient') ||
        location.startsWith('/admin')) {
      return 0;
    }
    if (location.startsWith('/donors') || location.startsWith('/requests')) return 1;
    if (location.startsWith('/hospital') || location.startsWith('/blood-bank')) return 2;
    if (location.startsWith('/notifications') || location.startsWith('/profile') || location.startsWith('/settings')) return 3;
    return 0;
  }

  /// Returns the home route for the user's role.
  String _homeRouteForRole(String role) {
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

  void _onTap(BuildContext context, int index, String role) {
    switch (index) {
      case 0:
        context.go(_homeRouteForRole(role));
        break;
      case 1:
        if (role == 'donor') {
          context.go('/requests');
        } else {
          context.go('/donors');
        }
        break;
      case 2:
        context.go('/hospitals');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  List<BottomNavigationBarItem> _navItems(String role, AsyncValue<int>? unreadCount) {
    final badgeCount = _unreadBadgeCount(unreadCount);

    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard_rounded),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(
          role == 'donor' ? Icons.bloodtype_outlined : Icons.search_outlined,
        ),
        activeIcon: Icon(
          role == 'donor' ? Icons.bloodtype_rounded : Icons.search_rounded,
        ),
        label: role == 'donor' ? 'Requests' : 'Donors',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.local_hospital_outlined),
        activeIcon: Icon(Icons.local_hospital_rounded),
        label: 'Hospitals',
      ),
      BottomNavigationBarItem(
        icon: badgeCount > 0
            ? Badge(
                isLabelVisible: true,
                label: Text(badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
                child: const Icon(Icons.person_outline),
              )
            : const Icon(Icons.person_outline),
        activeIcon: badgeCount > 0
            ? Badge(
                isLabelVisible: true,
                label: Text(badgeCount > 9 ? '9+' : '$badgeCount',
                    style: const TextStyle(fontSize: 10, color: Colors.white)),
                child: const Icon(Icons.person_rounded),
              )
            : const Icon(Icons.person_rounded),
        label: 'Profile',
      ),
    ];
  }
}
