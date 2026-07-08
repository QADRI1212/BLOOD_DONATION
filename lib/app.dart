import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'bootstrap/app_initializer.dart';
import 'core/services/localization_service.dart';
import 'shared/models/user_profile.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'shared/providers/theme_provider.dart';

class BloodDonorApp extends ConsumerStatefulWidget {
  final AppInitializer appInitializer;

  const BloodDonorApp({super.key, required this.appInitializer});

  @override
  ConsumerState<BloodDonorApp> createState() => _BloodDonorAppState();
}

class _BloodDonorAppState extends ConsumerState<BloodDonorApp> {
  late AppRouter _appRouter;
  bool _isInitialized = false;
  bool _initializationStarted = false;
  final AuthStateProvider _authStateProvider = AuthStateProvider();

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    if (_initializationStarted) return;
    _initializationStarted = true;

    try {
      await widget.appInitializer.initialize();
    } catch (_) {
      // Continue even if initialization fails partially
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _appRouter = AppRouter(_authStateProvider);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Blood Donor Network',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const _InitializingScreen(),
          );
        },
      );
    }

    // Bridge Riverpod auth state to the ChangeNotifier for GoRouter redirects
    ref.listen<AsyncValue<UserProfile?>>(authProvider, (_, next) {
      final user = next.valueOrNull;
      _authStateProvider.updateAuthState(
        authenticated: user != null,
        role: user?.role,
      );
    });

    final themeMode = ref.watch(themeModeProvider);
    final localeCode = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Blood Donor Network',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          locale: LocalizationService.toFlutterLocale(localeCode),
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('ur'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // Urdu is only supported by our custom LocalizationService, not by
            // Flutter's built-in Material/Cupertino delegates. Fall back to
            // English for built-in widgets — our LocalizationService.tr()
            // handles Urdu for app strings independently.
            if (locale?.languageCode == 'ur') {
              return const Locale('en');
            }
            // For supported locales (en, hi), let Flutter resolve normally
            return null;
          },
          routerConfig: _appRouter.router,
        );
      },
    );
  }
}

class _InitializingScreen extends StatelessWidget {
  const _InitializingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bloodtype_rounded,
              size: 64,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 24),
            const Text(
              'Blood Donor Network',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
