class AppStrings {
  // App
  static const String appName = 'Pilgrim\'s Companion';
  static const String appTagline =
      'Your Complete Hajj & Umrah Guide';

  // Greetings
  static const String salam = 'As-salamu alaykum';
  static const String salamArabic = 'السلام عليكم';
  static const String bismillah =
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
  static const String taqabbal =
      'تَقَبَّلَ اللهُ مِنَّا وَمِنْكُمْ';

  // Errors
  static const String noInternet =
      'No internet connection. Please connect and retry.';
  static const String downloadFailed =
      'Download failed. Please check your internet.';
  static const String pdfNotFound =
      'PDF file not found. Please re-download from Settings.';

  // Success
  static const String downloadComplete =
      'All content downloaded successfully!';
  static const String bookmarkAdded = 'Page bookmarked!';
  static const String bookmarkRemoved = 'Bookmark removed';
  static const String cacheCleared =
      'Cache cleared successfully';
  static const String progressCleared =
      'Reading progress cleared';
}

class AppDimensions {
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Button Height
  static const double buttonHeight = 56.0;
  static const double buttonHeightSmall = 44.0;

  // Grid
  static const double gridSpacing = 14.0;
  static const double gridAspectRatioPhone = 0.88;
  static const double gridAspectRatioTablet = 0.95;

  // Breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 900.0;
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration verySlow =
      Duration(milliseconds: 1000);
}