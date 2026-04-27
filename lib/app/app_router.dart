import 'package:flutter/material.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/language_screen.dart';
import '../presentation/screens/download_screen.dart';
import '../presentation/screens/onboarding_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/pdf_viewer_screen.dart';
import '../app/app_constants.dart';

class AppRouter {
  // ── Route Names ────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String language = '/language';
  static const String download = '/download';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String pdfViewer = '/pdf-viewer';

  // ── Generate Route ─────────────────────────────────────────────────────
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());

      case language:
        return _fadeRoute(const LanguageScreen());

      case download:
        final args = settings.arguments as Map<String, dynamic>?;
        final languageCode = args?['languageCode'] as String? ?? 'en';
        return _slideRoute(
          DownloadScreen(languageCode: languageCode),
        );

      case onboarding:
        return _slideRoute(const OnboardingScreen());

      case home:
        return _fadeRoute(const HomeScreen());

      case AppRouter.settings:
        return _slideRoute(const SettingsScreen());

      case pdfViewer:
        final args = settings.arguments as Map<String, dynamic>?;
        final section = args?['section'] as ContentSection?;
        final customPath = args?['customFilePath'] as String?;

        if (section == null) {
          return _fadeRoute(const HomeScreen());
        }

        return _slideRoute(
          PdfViewerScreen(
            section: section,
            customFilePath: customPath,
          ),
        );

      default:
        return _fadeRoute(const SplashScreen());
    }
  }

  // ── Transitions ────────────────────────────────────────────────────────

  static PageRoute _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRoute _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}