import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';

/// A customizable app bar that follows the app's design system.
///
/// Supports:
/// - Title with optional subtitle
/// - Back button (automatic based on navigation stack)
/// - Leading widget override
/// - Action buttons
/// - Bottom widget (e.g. search bar, tabs)
/// - Gradient or solid background
/// - Custom height via [toolbarHeight]
/// - Notification bell with badge when user is logged in
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  /// The title text displayed in the center.
  final String? title;

  /// Optional widget to use instead of title text.
  final Widget? titleWidget;

  /// Optional subtitle shown below the title.
  final String? subtitle;

  /// Actions displayed on the right side.
  final List<Widget>? actions;

  /// Optional widget displayed below the title (e.g. search bar, tabs).
  final PreferredSizeWidget? bottom;

  /// Whether to show the back button when navigation is available.
  /// The button only appears when [Navigator.canPop] is true.
  final bool showBackButton;

  /// Custom leading widget to replace the back button.
  final Widget? leading;

  /// Background color override. Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// Whether to use the gradient background style.
  final bool useGradient;

  /// Toolbar height. Defaults to kToolbarHeight (56).
  final double? toolbarHeight;

  /// Whether the title should be centered.
  final bool centerTitle;

  /// Elevation of the app bar.
  final double elevation;

  /// Foreground color for icons and text.
  final Color? foregroundColor;

  /// Whether to show the notification bell with unread badge.
  final bool showNotificationBadge;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.leading,
    this.backgroundColor,
    this.useGradient = false,
    this.toolbarHeight,
    this.centerTitle = false,
    this.elevation = 0,
    this.foregroundColor,
    this.showNotificationBadge = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = context.canPop();

    final effectiveLeading = leading ??
        (showBackButton && canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Back',
              )
            : null);

    final effectiveBg = backgroundColor ??
        (useGradient ? null : (isDark ? AppColors.darkSurface : Colors.white));

    final effectiveFg = foregroundColor ??
        (useGradient ? Colors.white : (isDark ? Colors.white : AppColors.grey900));

    // Build notification bell with badge for the actions list
    final List<Widget> effectiveActions = [];

    if (showNotificationBadge) {
      final authState = ref.watch(authProvider);
      final user = authState.valueOrNull;
      if (user != null) {
        final unreadAsync = ref.watch(unreadCountProvider(user.id));
        final unreadCount = unreadAsync.valueOrNull ?? 0;

        effectiveActions.add(
          IconButton(
            icon: unreadCount > 0
                ? Badge(
                    isLabelVisible: true,
                    label: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    child: Icon(Icons.notifications_outlined, color: effectiveFg),
                  )
                : Icon(Icons.notifications_none_rounded, color: effectiveFg),
            onPressed: () => context.push('/notifications'),
            tooltip: 'Notifications',
          ),
        );
      }
    }

    if (actions != null) {
      effectiveActions.addAll(actions!);
    }

    final appBar = AppBar(
      toolbarHeight: toolbarHeight,
      title: titleWidget ??
          (title != null
              ? Column(
                  crossAxisAlignment: centerTitle
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      style: AppTypography.titleLarge.copyWith(color: effectiveFg),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: effectiveFg.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                )
              : null),
      leading: effectiveLeading,
      actions: effectiveActions.isNotEmpty ? effectiveActions : null,
      bottom: bottom,
      backgroundColor: useGradient ? null : effectiveBg,
      flexibleSpace: useGradient
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            )
          : null,
      centerTitle: centerTitle,
      elevation: elevation,
      scrolledUnderElevation: 0.5,
      foregroundColor: effectiveFg,
      iconTheme: IconThemeData(color: effectiveFg),
      surfaceTintColor: Colors.transparent,
    );

    return appBar;
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight((toolbarHeight ?? kToolbarHeight) + bottomHeight);
  }
}
