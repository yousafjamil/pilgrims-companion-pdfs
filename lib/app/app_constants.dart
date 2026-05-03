class AppConstants {
  // ── App Info ───────────────────────────────────────
  static const String appName = 'Pilgrim\'s Companion';
  static const String appVersion = '2.0.0';
  static const String prhWebsite = 'https://prh.gov.sa';

  // ── Storage Keys ───────────────────────────────────
  static const String keySelectedLanguage =
      'selected_language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyContentDownloaded =
      'content_downloaded';

  // ── Supported Languages ────────────────────────────
static const List<LanguageConfig> supportedLanguages = [
  LanguageConfig(code: 'ar', name: 'Arabic',     nativeName: 'العربية',    flag: '🇸🇦', isRTL: true),
  LanguageConfig(code: 'en', name: 'English',    nativeName: 'English',    flag: '🇬🇧', isRTL: false),
  LanguageConfig(code: 'ur', name: 'Urdu',       nativeName: 'اردو',       flag: '🇵🇰', isRTL: true),
  LanguageConfig(code: 'id', name: 'Indonesian', nativeName: 'Indonesia',  flag: '🇮🇩', isRTL: false),
  LanguageConfig(code: 'hi', name: 'Hindi',      nativeName: 'हिन्दी',    flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'bn', name: 'Bengali',    nativeName: 'বাংলা',     flag: '🇧🇩', isRTL: false),
  LanguageConfig(code: 'sw', name: 'Swahili',    nativeName: 'Kiswahili',  flag: '🇰🇪', isRTL: false),
  LanguageConfig(code: 'ha', name: 'Hausa',      nativeName: 'Hausa',      flag: '🇳🇬', isRTL: false),
  LanguageConfig(code: 'uz', name: 'Uzbek',      nativeName: 'Ўзбек',      flag: '🇺🇿', isRTL: false),
  LanguageConfig(code: 'fr', name: 'French',     nativeName: 'Français',   flag: '🇫🇷', isRTL: false),
  LanguageConfig(code: 'ru', name: 'Russian',    nativeName: 'Русский',    flag: '🇷🇺', isRTL: false),
  LanguageConfig(code: 'fa', name: 'Persian',    nativeName: 'فارسي',      flag: '🇮🇷', isRTL: true),
  LanguageConfig(code: 'tr', name: 'Turkish',    nativeName: 'Türkçe',     flag: '🇹🇷', isRTL: false),
  LanguageConfig(code: 'tl', name: 'Tagalog',    nativeName: 'Tagalog',    flag: '🇵🇭', isRTL: false),
  LanguageConfig(code: 'ms', name: 'Malay',      nativeName: 'Melayu',     flag: '🇲🇾', isRTL: false),
  LanguageConfig(code: 'zh', name: 'Chinese',    nativeName: '中文',        flag: '🇨🇳', isRTL: false),
  LanguageConfig(code: 'am', name: 'Amharic',    nativeName: 'አማርኛ',      flag: '🇪🇹', isRTL: false),
  LanguageConfig(code: 'as', name: 'Assamese',   nativeName: 'অসমীয়া',   flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'tg', name: 'Tajik',      nativeName: 'тоҷикӣ',    flag: '🇹🇯', isRTL: false),
  LanguageConfig(code: 'th', name: 'Thai',       nativeName: 'ไทย',        flag: '🇹🇭', isRTL: false),
  LanguageConfig(code: 'pt', name: 'Portuguese', nativeName: 'português',  flag: '🇵🇹', isRTL: false),
  LanguageConfig(code: 'sq', name: 'Albanian',   nativeName: 'Shqip',      flag: '🇦🇱', isRTL: false),
  LanguageConfig(code: 'ml', name: 'Malayalam',  nativeName: 'മലയാളം',    flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'si', name: 'Sinhala',    nativeName: 'සිංහල',     flag: '🇱🇰', isRTL: false),
  LanguageConfig(code: 'ta', name: 'Tamil',      nativeName: 'தமிழ்',     flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'es', name: 'Spanish',    nativeName: 'español',    flag: '🇪🇸', isRTL: false),
  LanguageConfig(code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳', isRTL: false),
  LanguageConfig(code: 'ps', name: 'Pashto',     nativeName: 'بشتو',       flag: '🇦🇫', isRTL: true),
  LanguageConfig(code: 'az', name: 'Azerbaijani',nativeName: 'azərbaycanca',flag: '🇦🇿', isRTL: false),
  LanguageConfig(code: 'te', name: 'Telugu',     nativeName: 'తెలుగు',    flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'ky', name: 'Kyrgyz',     nativeName: 'Кыргызча',   flag: '🇰🇬', isRTL: false),
  LanguageConfig(code: 'bs', name: 'Bosnian',    nativeName: 'bosanski',   flag: '🇧🇦', isRTL: false),
  LanguageConfig(code: 'gu', name: 'Gujarati',   nativeName: 'ગુજરાતી',   flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'sr', name: 'Serbian',    nativeName: 'Српски',     flag: '🇷🇸', isRTL: false),
  LanguageConfig(code: 'lt', name: 'Lithuanian', nativeName: 'lietuvių',   flag: '🇱🇹', isRTL: false),
  LanguageConfig(code: 'or', name: 'Oromoo',     nativeName: 'afaan oromoo',flag: '🇪🇹', isRTL: false),
  LanguageConfig(code: 'de', name: 'German',     nativeName: 'Deutsch',    flag: '🇩🇪', isRTL: false),
  LanguageConfig(code: 'it', name: 'Italian',    nativeName: 'italiano',   flag: '🇮🇹', isRTL: false),
  LanguageConfig(code: 'ne', name: 'Nepali',     nativeName: 'नेपाली',    flag: '🇳🇵', isRTL: false),
  LanguageConfig(code: 'mk', name: 'Macedonian', nativeName: 'македонски', flag: '🇲🇰', isRTL: false),
  LanguageConfig(code: 'uk', name: 'Ukrainian',  nativeName: 'українська', flag: '🇺🇦', isRTL: false),
  LanguageConfig(code: 'ka', name: 'Georgian',   nativeName: 'ქართული',   flag: '🇬🇪', isRTL: false),
  LanguageConfig(code: 'nl', name: 'Dutch',      nativeName: 'Nederlands', flag: '🇳🇱', isRTL: false),
  LanguageConfig(code: 'cs', name: 'Czech',      nativeName: 'čeština',    flag: '🇨🇿', isRTL: false),
  LanguageConfig(code: 'bg', name: 'Bulgarian',  nativeName: 'български',  flag: '🇧🇬', isRTL: false),
  LanguageConfig(code: 'km', name: 'Khmer',      nativeName: 'ភាសាខ្មែរ', flag: '🇰🇭', isRTL: false),
  LanguageConfig(code: 'mg', name: 'Malagasy',   nativeName: 'Malagasy',   flag: '🇲🇬', isRTL: false),
  LanguageConfig(code: 'sv', name: 'Swedish',    nativeName: 'svenska',    flag: '🇸🇪', isRTL: false),
  LanguageConfig(code: 'jo', name: 'Jóola',      nativeName: 'Jóola',      flag: '🇸🇳', isRTL: false),
  LanguageConfig(code: 'lo', name: 'Lao',        nativeName: 'ພາສາລາວ',   flag: '🇱🇦', isRTL: false),
  LanguageConfig(code: 'da', name: 'Danish',     nativeName: 'dansk',      flag: '🇩🇰', isRTL: false),
  LanguageConfig(code: 'st', name: 'Sesotho',    nativeName: 'Sesotho',    flag: '🇱🇸', isRTL: false),
  LanguageConfig(code: 'hy', name: 'Armenian',   nativeName: 'Հայերէն',   flag: '🇦🇲', isRTL: false),
  LanguageConfig(code: 'sl', name: 'Slovenian',  nativeName: 'slovenščina',flag: '🇸🇮', isRTL: false),
  LanguageConfig(code: 'sn', name: 'Shona',      nativeName: 'Shona',      flag: '🇿🇼', isRTL: false),
  LanguageConfig(code: 'kn', name: 'Kannada',    nativeName: 'ಕನ್ನಡ',     flag: '🇮🇳', isRTL: false),
  LanguageConfig(code: 'dv', name: 'Dhivehi',    nativeName: 'ދިވެހި',    flag: '🇲🇻', isRTL: true),
  LanguageConfig(code: 'hu', name: 'Hungarian',  nativeName: 'magyar',     flag: '🇭🇺', isRTL: false),
  LanguageConfig(code: 'pl', name: 'Polish',     nativeName: 'polski',     flag: '🇵🇱', isRTL: false),
];
  // ── Home Categories ────────────────────────────────
  static const List<HomeCategory> homeCategories = [
    HomeCategory(
      id: 'masjid_haram',
      titleEn: 'Masjid Al-Haram',
      titleAr: 'المسجد الحرام',
      icon: '🕋',
      color: 0xFF2D5F3F,
      subcategories: [
        SubCategory(
          id: 'haram_news',
          titleEn: 'Latest News',
          titleAr: 'أخبار المسجد الحرام',
          icon: '📰',
          url: 'https://prh.gov.sa/المسجد-الحرام/makkah-news',
        ),
        SubCategory(
          id: 'haram_prayer',
          titleEn: 'Prayer Times',
          titleAr: 'مواقيت الصلاة',
          icon: '🕐',
          url: '',
        ),
        SubCategory(
          id: 'haram_imams',
          titleEn: 'Imam Schedule',
          titleAr: 'جداول الائمة',
          icon: '👨‍💼',
          url: 'https://prh.gov.sa/المسجد-الحرام/جداول-الائمة-مكة-المكرمة',
        ),
        SubCategory(
          id: 'haram_muezzin',
          titleEn: 'Muezzin Schedule',
          titleAr: 'جداول المؤذنين',
          icon: '📢',
          url: 'https://prh.gov.sa/المسجد-الحرام/جداول-المؤذنين-مكة-المكرمة',
        ),
        SubCategory(
          id: 'haram_lessons',
          titleEn: 'Scientific Lessons',
          titleAr: 'جداول الدروس',
          icon: '📚',
          url: 'https://prh.gov.sa/المسجد-الحرام/جداول-الدروس-العلمية-بالمسجد-الحرام',
        ),
      ],
    ),
    HomeCategory(
      id: 'masjid_nabawi',
      titleEn: 'Masjid An-Nabawi',
      titleAr: 'المسجد النبوي',
      icon: '🕌',
      color: 0xFF1A5276,
      subcategories: [
        SubCategory(
          id: 'nabawi_news',
          titleEn: 'Latest News',
          titleAr: 'أخبار المسجد النبوي',
          icon: '📰',
          url: 'https://prh.gov.sa/المسجد-النبوي/madina-news',
        ),
        SubCategory(
          id: 'nabawi_prayer',
          titleEn: 'Prayer Times',
          titleAr: 'مواقيت الصلاة',
          icon: '🕐',
          url: '',
        ),
        SubCategory(
          id: 'nabawi_imams',
          titleEn: 'Imam Schedule',
          titleAr: 'جداول الائمة',
          icon: '👨‍💼',
          url: 'https://prh.gov.sa/المسجد-النبوي/جداول-الائمة-المدينة-المنورة',
        ),
        SubCategory(
          id: 'nabawi_muezzin',
          titleEn: 'Muezzin Schedule',
          titleAr: 'جداول المؤذنين',
          icon: '📢',
          url: 'https://prh.gov.sa/المسجد-النبوي/جداول-المؤذنين-المدينة-المنورة',
        ),
        SubCategory(
          id: 'nabawi_lessons',
          titleEn: 'Scientific Lessons',
          titleAr: 'جداول الدروس',
          icon: '📚',
          url: 'https://prh.gov.sa/المسجد-النبوي/جداول-الدروس-بالمسجد-النبوي',
        ),
      ],
    ),
    HomeCategory(
      id: 'islamic_content',
      titleEn: 'Islamic Content',
      titleAr: 'المحتوى الإسلامي',
      icon: '📖',
      color: 0xFF6C3483,
      subcategories: [
        SubCategory(
          id: 'khutbah',
          titleEn: 'Friday Khutbah',
          titleAr: 'الخطب بالحرمين',
          icon: '🎙️',
          url: 'https://prh.gov.sa/الخطب-بالحرمين',
        ),
        SubCategory(
          id: 'lessons',
          titleEn: 'Scientific Lessons',
          titleAr: 'الدروس العلمية',
          icon: '🎓',
          url: 'https://prh.gov.sa/الدروس-العلمية',
        ),
        SubCategory(
          id: 'scholars',
          titleEn: 'Scholars & Sheikhs',
          titleAr: 'علماء ومشائخ الحرمين',
          icon: '👨‍🏫',
          url: 'https://prh.gov.sa/علماء-ومشائخ-الحرمين',
        ),
        SubCategory(
          id: 'recitations',
          titleEn: 'Quran Recitations',
          titleAr: 'تلاوات الحرمين',
          icon: '🎵',
          url: 'https://prh.gov.sa/تلاوات-الحرمين',
        ),
        SubCategory(
          id: 'quran',
          titleEn: 'Holy Quran',
          titleAr: 'القرآن الكريم',
          icon: '📖',
          url: '',
        ),
        SubCategory(
          id: 'qanda',
          titleEn: 'Q&A (Fatawa)',
          titleAr: 'إجابة السائلين',
          icon: '❓',
          url: 'https://prh.gov.sa/إجابة-السائلين',
        ),
      ],
    ),
    HomeCategory(
      id: 'prayer_times',
      titleEn: 'Prayer Times',
      titleAr: 'مواقيت الصلوات',
      icon: '🕐',
      color: 0xFFD4AF37,
      subcategories: [
        SubCategory(
          id: 'prayer_makkah',
          titleEn: 'Makkah Prayer Times',
          titleAr: 'مواقيت مكة المكرمة',
          icon: '🕋',
          url: '',
        ),
        SubCategory(
          id: 'prayer_madinah',
          titleEn: 'Madinah Prayer Times',
          titleAr: 'مواقيت المدينة المنورة',
          icon: '🕌',
          url: '',
        ),
      ],
    ),
    HomeCategory(
      id: 'media',
      titleEn: 'Media & Gallery',
      titleAr: 'الإعلام والصور',
      icon: '📸',
      color: 0xFF1ABC9C,
      subcategories: [
        SubCategory(
          id: 'photos',
          titleEn: 'Photo Gallery',
          titleAr: 'معرض الصور',
          icon: '🖼️',
          url: 'https://prh.gov.sa/معرض-الصور',
        ),
        SubCategory(
          id: 'magazine',
          titleEn: 'Haramain Magazine',
          titleAr: 'مجلة حرمين',
          icon: '📰',
          url: 'https://prh.gov.sa/مجلة-حرمين',
        ),
        SubCategory(
          id: 'risala',
          titleEn: 'Risala Al-Haramain',
          titleAr: 'رسالة الحرمين',
          icon: '📜',
          url: 'https://risala.prh.gov.sa/ar',
        ),
      ],
    ),
  ];

  // Content sections kept for Quran
  static const List<ContentSection> contentSections = [
    ContentSection(
      id: 'quran',
      titleKey: 'quran',
      icon: '📖',
      fileName: 'quran',
    ),
  ];
}

// ── Language Config ────────────────────────────────────

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

// ── Home Category ──────────────────────────────────────

class HomeCategory {
  final String id;
  final String titleEn;
  final String titleAr;
  final String icon;
  final int color;
  final List<SubCategory> subcategories;

  const HomeCategory({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.color,
    required this.subcategories,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar') return titleAr;
    return titleEn;
  }
}

class SubCategory {
  final String id;
  final String titleEn;
  final String titleAr;
  final String icon;
  final String url;

  const SubCategory({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.url,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar') return titleAr;
    return titleEn;
  }
}

// ── Content Section (kept for Quran) ──────────────────

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

  String getDownloadUrl(String languageCode) {
    return 'https://github.com/yousafjamil/pilgrims-companion-pdfs/releases/download/v1.0/${fileName}_$languageCode.pdf';
  }
}


// class AppConstants {
//   // ── App Info ───────────────────────────────────────────────────────────
//   static const String appName = 'Pilgrim\'s Companion';
//   static const String appVersion = '1.0.0';

//   // ── GitHub Release Base URL ────────────────────────────────────────────
//   // UPDATE THIS with your actual GitHub username and repo
//   static const String githubReleaseBaseUrl =
//       'https://github.com/yousafjamil/pilgrims-companion-pdfs/releases/download/v1.0';

//   // ── Storage Keys ───────────────────────────────────────────────────────
//   static const String keySelectedLanguage = 'selected_language';
//   static const String keyFirstLaunch = 'first_launch';
//   static const String keyThemeMode = 'theme_mode';
//   static const String keyContentDownloaded = 'content_downloaded';

//   // ── Supported Languages ────────────────────────────────────────────────
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

//   // ── Content Sections (EXCLUDING QURAN) ────────────────────────────────
//   // Quran is handled separately by QuranDownloader
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
//     // ⚠️ Quran section kept here ONLY for reference
//     // actual download handled by QuranDownloader
//     ContentSection(
//       id: 'quran',
//       titleKey: 'quran',
//       icon: '📖',
//       fileName: 'quran',
//     ),
//   ];
// }

// // ── Language Config Model ──────────────────────────────────────────────────

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

// // ── Content Section Model ──────────────────────────────────────────────────

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

//   // Generate download URL
//   String getDownloadUrl(String languageCode) {
//     return '${AppConstants.githubReleaseBaseUrl}/${fileName}_$languageCode.pdf';
//   }
// }
