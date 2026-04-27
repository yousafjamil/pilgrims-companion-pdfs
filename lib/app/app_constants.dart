
class AppConstants {
  // ── App Info ───────────────────────────────────────────────────────────
  static const String appName = 'Pilgrim\'s Companion';
  static const String appVersion = '1.0.0';

  // ── GitHub Release Base URL ────────────────────────────────────────────
  // UPDATE THIS with your actual GitHub username and repo
  static const String githubReleaseBaseUrl =
      'https://github.com/yousafjamil/pilgrims-companion-pdfs/releases/download/v1.0';

  // ── Storage Keys ───────────────────────────────────────────────────────
  static const String keySelectedLanguage = 'selected_language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyContentDownloaded = 'content_downloaded';

  // ── Supported Languages ────────────────────────────────────────────────
  static const List<LanguageConfig> supportedLanguages = [
    LanguageConfig(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇬🇧',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
      isRTL: true,
    ),
    LanguageConfig(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flag: '🇵🇰',
      isRTL: true,
    ),
    LanguageConfig(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Türkçe',
      flag: '🇹🇷',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'bn',
      name: 'Bengali',
      nativeName: 'বাংলা',
      flag: '🇧🇩',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      flag: '🇷🇺',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'fa',
      name: 'Persian',
      nativeName: 'فارسی',
      flag: '🇮🇷',
      isRTL: true,
    ),
    LanguageConfig(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flag: '🇮🇳',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'ha',
      name: 'Hausa',
      nativeName: 'Hausa',
      flag: '🇳🇬',
      isRTL: false,
    ),
    LanguageConfig(
      code: 'so',
      name: 'Somali',
      nativeName: 'Soomaali',
      flag: '🇸🇴',
      isRTL: false,
    ),
  ];

  // ── Content Sections (EXCLUDING QURAN) ────────────────────────────────
  // Quran is handled separately by QuranDownloader
  static const List<ContentSection> contentSections = [
    ContentSection(
      id: 'umrah_guide',
      titleKey: 'umrah_guide',
      icon: '🕋',
      fileName: 'umrah_guide',
    ),
    ContentSection(
      id: 'hajj_guide',
      titleKey: 'hajj_guide',
      icon: '🌙',
      fileName: 'hajj_guide',
    ),
    ContentSection(
      id: 'duas',
      titleKey: 'duas_collection',
      icon: '🤲',
      fileName: 'duas',
    ),
    ContentSection(
      id: 'makkah_guide',
      titleKey: 'makkah_guide',
      icon: '🕌',
      fileName: 'makkah_guide',
    ),
    ContentSection(
      id: 'madinah_guide',
      titleKey: 'madinah_guide',
      icon: '🌟',
      fileName: 'madinah_guide',
    ),
    ContentSection(
      id: 'health_safety',
      titleKey: 'health_safety',
      icon: '🏥',
      fileName: 'health_safety',
    ),
    ContentSection(
      id: 'packing',
      titleKey: 'packing_checklist',
      icon: '🎒',
      fileName: 'packing',
    ),
    ContentSection(
      id: 'mistakes',
      titleKey: 'common_mistakes',
      icon: '⚠️',
      fileName: 'mistakes',
    ),
    ContentSection(
      id: 'emergency',
      titleKey: 'emergency_info',
      icon: '🚨',
      fileName: 'emergency',
    ),
    // ⚠️ Quran section kept here ONLY for reference
    // actual download handled by QuranDownloader
    ContentSection(
      id: 'quran',
      titleKey: 'quran',
      icon: '📖',
      fileName: 'quran',
    ),
  ];
}

// ── Language Config Model ──────────────────────────────────────────────────

class LanguageConfig {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isRTL;

  const LanguageConfig({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.isRTL,
  });
}

// ── Content Section Model ──────────────────────────────────────────────────

class ContentSection {
  final String id;
  final String titleKey;
  final String icon;
  final String fileName;

  const ContentSection({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.fileName,
  });

  // Generate download URL
  String getDownloadUrl(String languageCode) {
    return '${AppConstants.githubReleaseBaseUrl}/${fileName}_$languageCode.pdf';
  }
}
// class AppConstants {
//     // App Info
//   static const String appName = 'Pilgrim\'s Companion';
//   static const String appVersion = '1.0.0';
  
//   // GitHub Release Base URL
//   static const String githubReleaseBaseUrl = 
//       'https://github.com/yousafjamil/pilgrims-companion-pdfs/releases/tag/v1.0';
  
//   // Supported Languages
//   static const List<LanguageConfig> supportedLanguages = [
//     LanguageConfig(
//       code: 'en',
//       name: 'English',
//       nativeName: 'English',
//       flag: '🇬🇧',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'ar',
//       name: 'Arabic',
//       nativeName: 'العربية',
//       flag: '🇸🇦',
//       isRTL: true,
//     ),
//     LanguageConfig(
//       code: 'ur',
//       name: 'Urdu',
//       nativeName: 'اردو',
//       flag: '🇵🇰',
//       isRTL: true,
//     ),
//     LanguageConfig(
//       code: 'tr',
//       name: 'Turkish',
//       nativeName: 'Türkçe',
//       flag: '🇹🇷',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'id',
//       name: 'Indonesian',
//       nativeName: 'Bahasa Indonesia',
//       flag: '🇮🇩',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'fr',
//       name: 'French',
//       nativeName: 'Français',
//       flag: '🇫🇷',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'bn',
//       name: 'Bengali',
//       nativeName: 'বাংলা',
//       flag: '🇧🇩',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'ru',
//       name: 'Russian',
//       nativeName: 'Русский',
//       flag: '🇷🇺',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'fa',
//       name: 'Persian',
//       nativeName: 'فارسی',
//       flag: '🇮🇷',
//       isRTL: true,
//     ),
//     LanguageConfig(
//       code: 'hi',
//       name: 'Hindi',
//       nativeName: 'हिन्दी',
//       flag: '🇮🇳',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'ha',
//       name: 'Hausa',
//       nativeName: 'Hausa',
//       flag: '🇳🇬',
//       isRTL: false,
//     ),
//     LanguageConfig(
//       code: 'so',
//       name: 'Somali',
//       nativeName: 'Soomaali',
//       flag: '🇸🇴',
//       isRTL: false,
//     ),
//   ];
  
//   // PDF Content Sections
//   static const List<ContentSection> contentSections = [
//     ContentSection(
//       id: 'umrah_guide',
//       titleKey: 'umrah_guide',
//       icon: '🕋',
//       fileName: 'umrah_guide',
//     ),
//     ContentSection(
//       id: 'hajj_guide',
//       titleKey: 'hajj_guide',
//       icon: '🌙',
//       fileName: 'hajj_guide',
//     ),
//     ContentSection(
//       id: 'duas',
//       titleKey: 'duas_collection',
//       icon: '🤲',
//       fileName: 'duas',
//     ),
//     ContentSection(
//       id: 'makkah_guide',
//       titleKey: 'makkah_guide',
//       icon: '🕌',
//       fileName: 'makkah_guide',
//     ),
//     ContentSection(
//       id: 'madinah_guide',
//       titleKey: 'madinah_guide',
//       icon: '🌟',
//       fileName: 'madinah_guide',
//     ),
//     ContentSection(
//       id: 'health_safety',
//       titleKey: 'health_safety',
//       icon: '🏥',
//       fileName: 'health_safety',
//     ),
//     ContentSection(
//       id: 'packing',
//       titleKey: 'packing_checklist',
//       icon: '🎒',
//       fileName: 'packing',
//     ),
//     ContentSection(
//       id: 'mistakes',
//       titleKey: 'common_mistakes',
//       icon: '⚠️',
//       fileName: 'mistakes',
//     ),
//     ContentSection(
//       id: 'emergency',
//       titleKey: 'emergency_info',
//       icon: '🚨',
//       fileName: 'emergency',
//     ),
//     ContentSection(
//       id: 'quran',
//       titleKey: 'quran',
//       icon: '📖',
//       fileName: 'quran',
//     ),
//   ];
  
//   // Storage Keys
//   static const String keySelectedLanguage = 'selected_language';
//   static const String keyFirstLaunch = 'first_launch';
//   static const String keyThemeMode = 'theme_mode';
//   static const String keyContentDownloaded = 'content_downloaded';
// }

// // Language Configuration Model
// class LanguageConfig {
//   final String code;
//   final String name;
//   final String nativeName;
//   final String flag;
//   final bool isRTL;
  
//   const LanguageConfig({
//     required this.code,
//     required this.name,
//     required this.nativeName,
//     required this.flag,
//     required this.isRTL,
//   });
// }

// // Content Section Model
// class ContentSection {
//   final String id;
//   final String titleKey;
//   final String icon;
//   final String fileName;
  
//   const ContentSection({
//     required this.id,
//     required this.titleKey,
//     required this.icon,
//     required this.fileName,
//   });
  
//   // Generate download URL for this section
//   String getDownloadUrl(String languageCode) {
//     return '${AppConstants.githubReleaseBaseUrl}/${fileName}_$languageCode.pdf';
//   }
// }