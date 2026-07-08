import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  bool get isSmallScreen => screenWidth < 360;

  bool get isMediumScreen => screenWidth >= 360 && screenWidth < 600;

  bool get isLargeScreen => screenWidth >= 600;

  double get topPadding => mediaQuery.padding.top;

  double get bottomPadding => mediaQuery.padding.bottom;

  bool get isKeyboardVisible => mediaQuery.viewInsets.bottom > 0;

  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop<T>(result);

  Future<T?> push<T>(Widget page) {
    return navigator.push<T>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushReplacement<T>(Widget page) {
    return navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<T?> pushAndRemoveAll<T>(Widget page) {
    return navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(this).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}
