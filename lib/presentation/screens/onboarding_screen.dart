
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../../core/services/storage_service.dart';

// ── Language Data ─────────────────────────────────────────────────────────────

class _Language {
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;
  final bool isRTL;

  const _Language({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.flag,
    this.isRTL = false,
  });
}

const List<_Language> kAllLanguages = [
  _Language(code: 'en', nativeName: 'English', englishName: 'English', flag: '🇬🇧'),
  _Language(code: 'ar', nativeName: 'العربية', englishName: 'Arabic', flag: '🇸🇦', isRTL: true),
  _Language(code: 'ur', nativeName: 'اردو', englishName: 'Urdu', flag: '🇵🇰', isRTL: true),
  _Language(code: 'fa', nativeName: 'فارسی', englishName: 'Persian', flag: '🇮🇷', isRTL: true),
  _Language(code: 'ps', nativeName: 'پښتو', englishName: 'Pashto', flag: '🇦🇫', isRTL: true),
  _Language(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi', flag: '🇮🇳'),
  _Language(code: 'bn', nativeName: 'বাংলা', englishName: 'Bengali', flag: '🇧🇩'),
  _Language(code: 'id', nativeName: 'Indonesia', englishName: 'Indonesian', flag: '🇮🇩'),
  _Language(code: 'ms', nativeName: 'Melayu', englishName: 'Malay', flag: '🇲🇾'),
  _Language(code: 'tr', nativeName: 'Türkçe', englishName: 'Turkish', flag: '🇹🇷'),
  _Language(code: 'fr', nativeName: 'Français', englishName: 'French', flag: '🇫🇷'),
  _Language(code: 'ru', nativeName: 'Русский', englishName: 'Russian', flag: '🇷🇺'),
  _Language(code: 'zh', nativeName: '中文', englishName: 'Chinese', flag: '🇨🇳'),
  _Language(code: 'ha', nativeName: 'Hausa', englishName: 'Hausa', flag: '🇳🇬'),
  _Language(code: 'so', nativeName: 'Soomaali', englishName: 'Somali', flag: '🇸🇴'),
  _Language(code: 'sw', nativeName: 'Kiswahili', englishName: 'Swahili', flag: '🇰🇪'),
  _Language(code: 'es', nativeName: 'Español', englishName: 'Spanish', flag: '🇪🇸'),
  _Language(code: 'ta', nativeName: 'தமிழ்', englishName: 'Tamil', flag: '🇮🇳'),
  _Language(code: 'te', nativeName: 'తెలుగు', englishName: 'Telugu', flag: '🇮🇳'),
  _Language(code: 'ml', nativeName: 'മലയാളം', englishName: 'Malayalam', flag: '🇮🇳'),
  _Language(code: 'kn', nativeName: 'ಕನ್ನಡ', englishName: 'Kannada', flag: '🇮🇳'),
  _Language(code: 'gu', nativeName: 'ગુજરાતી', englishName: 'Gujarati', flag: '🇮🇳'),
  _Language(code: 'ne', nativeName: 'नेपाली', englishName: 'Nepali', flag: '🇳🇵'),
  _Language(code: 'si', nativeName: 'සිංහල', englishName: 'Sinhala', flag: '🇱🇰'),
  _Language(code: 'am', nativeName: 'አማርኛ', englishName: 'Amharic', flag: '🇪🇹'),
  _Language(code: 'om', nativeName: 'Oromoo', englishName: 'Oromo', flag: '🇪🇹'),
  _Language(code: 'uz', nativeName: 'Oʻzbekcha', englishName: 'Uzbek', flag: '🇺🇿'),
  _Language(code: 'az', nativeName: 'Azərbaycan', englishName: 'Azerbaijani', flag: '🇦🇿'),
  _Language(code: 'tg', nativeName: 'Тоҷикӣ', englishName: 'Tajik', flag: '🇹🇯'),
  _Language(code: 'ky', nativeName: 'Кыргызча', englishName: 'Kyrgyz', flag: '🇰🇬'),
  _Language(code: 'tl', nativeName: 'Filipino', englishName: 'Filipino', flag: '🇵🇭'),
  _Language(code: 'vi', nativeName: 'Tiếng Việt', englishName: 'Vietnamese', flag: '🇻🇳'),
  _Language(code: 'rw', nativeName: 'Kinyarwanda', englishName: 'Kinyarwanda', flag: '🇷🇼'),
  _Language(code: 'wo', nativeName: 'Wolof', englishName: 'Wolof', flag: '🇸🇳'),
  _Language(code: 'yo', nativeName: 'Yorùbá', englishName: 'Yoruba', flag: '🇳🇬'),
  _Language(code: 'mg', nativeName: 'Malagasy', englishName: 'Malagasy', flag: '🇲🇬'),
  _Language(code: 'bs', nativeName: 'Bosanski', englishName: 'Bosnian', flag: '🇧🇦'),
  _Language(code: 'sr', nativeName: 'Српски', englishName: 'Serbian', flag: '🇷🇸'),
  _Language(code: 'ro', nativeName: 'Română', englishName: 'Romanian', flag: '🇷🇴'),
  _Language(code: 'pl', nativeName: 'Polski', englishName: 'Polish', flag: '🇵🇱'),
  _Language(code: 'cs', nativeName: 'Čeština', englishName: 'Czech', flag: '🇨🇿'),
  _Language(code: 'hu', nativeName: 'Magyar', englishName: 'Hungarian', flag: '🇭🇺'),
  _Language(code: 'lt', nativeName: 'Lietuvių', englishName: 'Lithuanian', flag: '🇱🇹'),
  _Language(code: 'da', nativeName: 'Dansk', englishName: 'Danish', flag: '🇩🇰'),
  _Language(code: 'de', nativeName: 'Deutsch', englishName: 'German', flag: '🇩🇪'),
  _Language(code: 'it', nativeName: 'Italiano', englishName: 'Italian', flag: '🇮🇹'),
  _Language(code: 'nl', nativeName: 'Nederlands', englishName: 'Dutch', flag: '🇳🇱'),
  _Language(code: 'pt', nativeName: 'Português', englishName: 'Portuguese', flag: '🇵🇹'),
  _Language(code: 'km', nativeName: 'ភាសាខ្មែរ', englishName: 'Khmer', flag: '🇰🇭'),
  _Language(code: 'lo', nativeName: 'ລາວ', englishName: 'Lao', flag: '🇱🇦'),
  _Language(code: 'my', nativeName: 'မြန်မာ', englishName: 'Burmese', flag: '🇲🇲'),
  _Language(code: 'ku', nativeName: 'Kurdî', englishName: 'Kurdish', flag: '🏳️'),
];

// ── Translations ──────────────────────────────────────────────────────────────

class _T {
  static String get(String langCode, String key) {
    final map = _translations[langCode] ?? _translations['en']!;
    return map[key] ?? _translations['en']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'selectLang': 'Choose Your Language',
      'selectLangSub': 'Select your preferred language to continue',
      'search': 'Search language...',
      'continue': 'Continue',
      'welcome_title': "Welcome to\nPilgrim's Companion",
      'welcome_desc': 'Your complete offline guide for Hajj and Umrah. Everything you need for a blessed journey.',
      'offline_title': 'Works 100%\nOffline',
      'offline_desc': 'Download once and use forever. No internet needed after setup. Perfect for when you\'re in Saudi Arabia.',
      'lang_title': '52 Languages\nSupported',
      'lang_desc': 'Content available in 52 languages including Arabic, Urdu, Indonesian, Swahili, Hausa, and many more.',
      'quran_title': 'Full Quran\nIncluded',
      'quran_desc': 'The complete Holy Quran with translation downloads in the background while you explore the app.',
      'ready_title': 'Ready to Begin\nYour Journey',
      'ready_desc': 'May Allah accept your Hajj and Umrah. Let\'s start exploring your complete guide.',
      'next': 'Next',
      'getStarted': 'Get Started',
      'skip': 'Skip',
    },
    'ar': {
      'selectLang': 'اختر لغتك',
      'selectLangSub': 'اختر لغتك المفضلة للمتابعة',
      'search': 'ابحث عن لغة...',
      'continue': 'متابعة',
      'welcome_title': 'مرحباً بك في\nدليل الحاج',
      'welcome_desc': 'دليلك الشامل للحج والعمرة بدون إنترنت. كل ما تحتاجه لرحلة مباركة.',
      'offline_title': 'يعمل\nبدون إنترنت',
      'offline_desc': 'حمّل مرة واحدة واستخدمه للأبد. لا تحتاج إنترنت بعد الإعداد.',
      'lang_title': '٥٢ لغة\nمدعومة',
      'lang_desc': 'المحتوى متاح بـ52 لغة منها العربية والأردية والإندونيسية والسواحيلية والهوسا وغيرها.',
      'quran_title': 'القرآن الكريم\nكاملاً',
      'quran_desc': 'القرآن الكريم كاملاً مع الترجمة يتحمل في الخلفية أثناء تصفحك للتطبيق.',
      'ready_title': 'مستعد لبدء\nرحلتك',
      'ready_desc': 'تقبل الله حجك وعمرتك. لنبدأ في استكشاف دليلك الشامل.',
      'next': 'التالي',
      'getStarted': 'ابدأ الآن',
      'skip': 'تخطي',
    },
    'ur': {
      'selectLang': 'اپنی زبان منتخب کریں',
      'selectLangSub': 'جاری رکھنے کے لیے اپنی پسندیدہ زبان منتخب کریں',
      'search': 'زبان تلاش کریں...',
      'continue': 'جاری رکھیں',
      'welcome_title': 'خوش آمدید\nحاجی کے ساتھی میں',
      'welcome_desc': 'حج اور عمرہ کے لیے آپ کی مکمل آف لائن رہنما۔ ایک بابرکت سفر کے لیے سب کچھ۔',
      'offline_title': '100%\nآف لائن کام کرتا ہے',
      'offline_desc': 'ایک بار ڈاؤن لوڈ کریں اور ہمیشہ استعمال کریں۔ سیٹ اپ کے بعد انٹرنیٹ کی ضرورت نہیں۔',
      'lang_title': '52 زبانیں\nسپورٹ ہیں',
      'lang_desc': 'مواد 52 زبانوں میں دستیاب ہے جن میں عربی، اردو، انڈونیشیائی، سواحیلی، ہوسا اور بہت کچھ شامل ہے۔',
      'quran_title': 'مکمل قرآن\nشامل ہے',
      'quran_desc': 'مکمل قرآن مجید ترجمے کے ساتھ پس منظر میں ڈاؤن لوڈ ہوتا ہے۔',
      'ready_title': 'اپنا سفر شروع\nکرنے کے لیے تیار',
      'ready_desc': 'اللہ آپ کا حج اور عمرہ قبول فرمائے۔ اپنی مکمل رہنما دریافت کریں۔',
      'next': 'اگلا',
      'getStarted': 'شروع کریں',
      'skip': 'چھوڑیں',
    },
    'fa': {
      'selectLang': 'زبان خود را انتخاب کنید',
      'selectLangSub': 'زبان مورد نظر خود را برای ادامه انتخاب کنید',
      'search': 'جستجوی زبان...',
      'continue': 'ادامه',
      'welcome_title': 'به راهنمای\nحاجی خوش آمدید',
      'welcome_desc': 'راهنمای کامل آفلاین برای حج و عمره. همه چیزی که برای سفری مبارک نیاز دارید.',
      'offline_title': '100%\nآفلاین کار می‌کند',
      'offline_desc': 'یک بار دانلود کنید و برای همیشه استفاده کنید. بعد از راه‌اندازی به اینترنت نیازی نیست.',
      'lang_title': '52 زبان\nپشتیبانی می‌شود',
      'lang_desc': 'محتوا به 52 زبان در دسترس است.',
      'quran_title': 'قرآن کامل\nگنجانده شده',
      'quran_desc': 'قرآن کریم کامل با ترجمه در پس‌زمینه دانلود می‌شود.',
      'ready_title': 'آماده شروع\nسفر خود هستید',
      'ready_desc': 'خداوند حج و عمره شما را قبول فرماید.',
      'next': 'بعدی',
      'getStarted': 'شروع کنید',
      'skip': 'رد کردن',
    },
    'hi': {
      'selectLang': 'अपनी भाषा चुनें',
      'selectLangSub': 'जारी रखने के लिए अपनी पसंदीदा भाषा चुनें',
      'search': 'भाषा खोजें...',
      'continue': 'जारी रखें',
      'welcome_title': 'पिलग्रिम के साथी में\nस्वागत है',
      'welcome_desc': 'हज और उमरा के लिए आपकी पूर्ण ऑफलाइन गाइड। एक धन्य यात्रा के लिए सब कुछ।',
      'offline_title': '100%\nऑफलाइन काम करता है',
      'offline_desc': 'एक बार डाउनलोड करें और हमेशा उपयोग करें। सेटअप के बाद इंटरनेट की जरूरत नहीं।',
      'lang_title': '52 भाषाएं\nसमर्थित हैं',
      'lang_desc': 'सामग्री 52 भाषाओं में उपलब्ध है।',
      'quran_title': 'पूरा कुरान\nशामिल है',
      'quran_desc': 'अनुवाद के साथ पूरा पवित्र कुरान पृष्ठभूमि में डाउनलोड होता है।',
      'ready_title': 'अपनी यात्रा शुरू\nकरने के लिए तैयार',
      'ready_desc': 'अल्लाह आपके हज और उमरा को कबूल करे।',
      'next': 'अगला',
      'getStarted': 'शुरू करें',
      'skip': 'छोड़ें',
    },
    'tr': {
      'selectLang': 'Dilinizi Seçin',
      'selectLangSub': 'Devam etmek için tercih ettiğiniz dili seçin',
      'search': 'Dil ara...',
      'continue': 'Devam Et',
      'welcome_title': "Hacı Rehberine\nHoş Geldiniz",
      'welcome_desc': 'Hac ve Umre için eksiksiz çevrimdışı rehberiniz. Mübarek bir yolculuk için ihtiyacınız olan her şey.',
      'offline_title': '100%\nÇevrimdışı Çalışır',
      'offline_desc': 'Bir kez indirin ve sonsuza kadar kullanın. Kurulumdan sonra internete gerek yok.',
      'lang_title': '52 Dil\nDestekleniyor',
      'lang_desc': 'İçerik 52 dilde mevcuttur.',
      'quran_title': 'Tam Kuran\nDahil',
      'quran_desc': 'Tercümeli tam Kuran-ı Kerim arka planda indirilir.',
      'ready_title': 'Yolculuğunuza\nHazır mısınız',
      'ready_desc': 'Allah haccınızı ve umrenizi kabul etsin.',
      'next': 'İleri',
      'getStarted': 'Başla',
      'skip': 'Geç',
    },
    'id': {
      'selectLang': 'Pilih Bahasa Anda',
      'selectLangSub': 'Pilih bahasa yang Anda inginkan untuk melanjutkan',
      'search': 'Cari bahasa...',
      'continue': 'Lanjutkan',
      'welcome_title': 'Selamat Datang di\nPanduan Haji',
      'welcome_desc': 'Panduan offline lengkap untuk Haji dan Umrah. Semua yang Anda butuhkan untuk perjalanan yang berkah.',
      'offline_title': 'Bekerja 100%\nOffline',
      'offline_desc': 'Unduh sekali dan gunakan selamanya. Tidak perlu internet setelah pengaturan.',
      'lang_title': '52 Bahasa\nDidukung',
      'lang_desc': 'Konten tersedia dalam 52 bahasa.',
      'quran_title': 'Al-Quran Lengkap\nTersedia',
      'quran_desc': 'Al-Quran lengkap dengan terjemahan diunduh di latar belakang.',
      'ready_title': 'Siap Memulai\nPerjalanan Anda',
      'ready_desc': 'Semoga Allah menerima haji dan umrah Anda.',
      'next': 'Berikutnya',
      'getStarted': 'Mulai',
      'skip': 'Lewati',
    },
    'fr': {
      'selectLang': 'Choisissez votre langue',
      'selectLangSub': 'Sélectionnez votre langue préférée pour continuer',
      'search': 'Rechercher une langue...',
      'continue': 'Continuer',
      'welcome_title': 'Bienvenue dans le\nGuide du Pèlerin',
      'welcome_desc': 'Votre guide hors ligne complet pour le Hajj et la Omra. Tout ce dont vous avez besoin.',
      'offline_title': 'Fonctionne à 100%\nhors ligne',
      'offline_desc': 'Téléchargez une fois et utilisez pour toujours. Pas besoin d\'internet après la configuration.',
      'lang_title': '52 Langues\nSupportées',
      'lang_desc': 'Le contenu est disponible en 52 langues.',
      'quran_title': 'Coran Complet\nInclus',
      'quran_desc': 'Le Saint Coran complet avec traduction se télécharge en arrière-plan.',
      'ready_title': 'Prêt à Commencer\nVotre Voyage',
      'ready_desc': 'Qu\'Allah accepte votre Hajj et votre Omra.',
      'next': 'Suivant',
      'getStarted': 'Commencer',
      'skip': 'Passer',
    },
    'bn': {
      'selectLang': 'আপনার ভাষা বেছে নিন',
      'selectLangSub': 'চালিয়ে যেতে আপনার পছন্দের ভাষা নির্বাচন করুন',
      'search': 'ভাষা খুঁজুন...',
      'continue': 'চালিয়ে যান',
      'welcome_title': 'পিলগ্রিমের সঙ্গীতে\nস্বাগতম',
      'welcome_desc': 'হজ ও উমরার জন্য আপনার সম্পূর্ণ অফলাইন গাইড।',
      'offline_title': '100%\nঅফলাইনে কাজ করে',
      'offline_desc': 'একবার ডাউনলোড করুন এবং সবসময় ব্যবহার করুন।',
      'lang_title': '52টি ভাষা\nসমর্থিত',
      'lang_desc': '52টি ভাষায় কনটেন্ট পাওয়া যায়।',
      'quran_title': 'সম্পূর্ণ কুরআন\nঅন্তর্ভুক্ত',
      'quran_desc': 'অনুবাদ সহ সম্পূর্ণ কুরআন পটভূমিতে ডাউনলোড হয়।',
      'ready_title': 'আপনার যাত্রা শুরু\nকরতে প্রস্তুত',
      'ready_desc': 'আল্লাহ আপনার হজ ও উমরা কবুল করুন।',
      'next': 'পরবর্তী',
      'getStarted': 'শুরু করুন',
      'skip': 'এড়িয়ে যান',
    },
    'ru': {
      'selectLang': 'Выберите язык',
      'selectLangSub': 'Выберите предпочитаемый язык для продолжения',
      'search': 'Поиск языка...',
      'continue': 'Продолжить',
      'welcome_title': 'Добро пожаловать в\nПутеводитель паломника',
      'welcome_desc': 'Ваш полный офлайн-путеводитель по Хаджу и Умре.',
      'offline_title': 'Работает 100%\nбез интернета',
      'offline_desc': 'Скачайте один раз и используйте вечно. Интернет не нужен.',
      'lang_title': '52 языка\nподдерживается',
      'lang_desc': 'Контент доступен на 52 языках.',
      'quran_title': 'Полный Коран\nвключён',
      'quran_desc': 'Полный Коран с переводом загружается в фоновом режиме.',
      'ready_title': 'Готовы начать\nваше путешествие',
      'ready_desc': 'Да примет Аллах ваш Хадж и Умру.',
      'next': 'Далее',
      'getStarted': 'Начать',
      'skip': 'Пропустить',
    },
    'ha': {
      'selectLang': 'Zaɓi Yaren ku',
      'selectLangSub': 'Zaɓi yaren da kuke so don ci gaba',
      'search': 'Nemi harshe...',
      'continue': 'Ci gaba',
      'welcome_title': "Barka da zuwa\nGidin Mahajjaci",
      'welcome_desc': 'Cikakken jagoran naku na offline don Hajji da Umra.',
      'offline_title': 'Yana aiki\nbanda Intanet',
      'offline_desc': 'Zazzage sau ɗaya kuma yi amfani da shi har abada.',
      'lang_title': 'Harsunan 52\nana Goyan baya',
      'lang_desc': 'Abun ciki yana samuwa cikin harsuna 52.',
      'quran_title': "Cikakken Al'ƙur'ani\nyana ciki",
      'quran_desc': "Cikakken Alƙur'ani Mai Tsarki yana zazzagewa a bango.",
      'ready_title': 'Shirye don fara\nTafiyarku',
      'ready_desc': 'Allah ya karɓi Hajjinku da Umrarku.',
      'next': 'Na gaba',
      'getStarted': 'Fara',
      'skip': 'Tsallake',
    },
    'so': {
      'selectLang': 'Dooro Luqaddaada',
      'selectLangSub': 'Dooro luqadda aad doorbidayso si aad u sii wadato',
      'search': 'Raadi luqad...',
      'continue': 'Sii wad',
      'welcome_title': 'Ku soo dhowow\nGalka Xaajiga',
      'welcome_desc': 'Hagaha dhamaystiran ee offline-ka ee Xajiga iyo Umrada.',
      'offline_title': '100%\nOffline ayuu ku shaqeeyaa',
      'offline_desc': 'Hal mar soo daji oo had iyo jeer isticmaal.',
      'lang_title': '52 Luqadood\nayaa La Taageero',
      'lang_desc': 'Waxa ku jira 52 luqadood.',
      'quran_title': "Qur'aanka Oo Dhan\nWaa ku jiraa",
      'quran_desc': "Qur'aanka kariimka ah oo dhan wuxuu ka soo degayaa gadaashiisa.",
      'ready_title': 'Diyaar u ah\nSafarkaaga',
      'ready_desc': 'Alle ha aqbalo Xajigaaga iyo Umradaada.',
      'next': 'Xiga',
      'getStarted': 'Bilow',
      'skip': 'Dhaafo',
    },
    'sw': {
      'selectLang': 'Chagua Lugha Yako',
      'selectLangSub': 'Chagua lugha unayoipenda kuendelea',
      'search': 'Tafuta lugha...',
      'continue': 'Endelea',
      'welcome_title': 'Karibu katika\nMwongozo wa Hija',
      'welcome_desc': 'Mwongozo wako kamili wa nje ya mtandao wa Hija na Umra.',
      'offline_title': 'Inafanya kazi\n100% Bila Mtandao',
      'offline_desc': 'Pakua mara moja na utumie milele.',
      'lang_title': 'Lugha 52\nZinazotumika',
      'lang_desc': 'Maudhui yanapatikana katika lugha 52.',
      'quran_title': 'Quran Kamili\nImejumuishwa',
      'quran_desc': 'Quran Tukufu kamili na tafsiri inapakuliwa chinichini.',
      'ready_title': 'Tayari Kuanza\nSafari Yako',
      'ready_desc': 'Allah akubali Hija na Umra yako.',
      'next': 'Ijayo',
      'getStarted': 'Anza',
      'skip': 'Ruka',
    },
  };
}

// ── Onboarding Screen ─────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animController;
  int _currentPage = 0;

  // Step 0 = language selection, Steps 1-5 = onboarding pages
  bool _languageSelected = false;
  String _selectedLangCode = 'en';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  List<_PageData> get _pages => [
        _PageData(
          emoji: '🕋',
          titleKey: 'welcome_title',
          descKey: 'welcome_desc',
          primaryColor: const Color(0xFF2D5F3F),
          secondaryColor: const Color(0xFF5E9B76),
        ),
        _PageData(
          emoji: '📴',
          titleKey: 'offline_title',
          descKey: 'offline_desc',
          primaryColor: const Color(0xFF1A5276),
          secondaryColor: const Color(0xFF2E86C1),
        ),
        _PageData(
          emoji: '🌍',
          titleKey: 'lang_title',
          descKey: 'lang_desc',
          primaryColor: const Color(0xFF6C3483),
          secondaryColor: const Color(0xFF9B59B6),
        ),
        _PageData(
          emoji: '📖',
          titleKey: 'quran_title',
          descKey: 'quran_desc',
          primaryColor: const Color(0xFF784212),
          secondaryColor: const Color(0xFFD4AF37),
        ),
        _PageData(
          emoji: '✨',
          titleKey: 'ready_title',
          descKey: 'ready_desc',
          primaryColor: const Color(0xFF2D5F3F),
          secondaryColor: const Color(0xFFD4AF37),
        ),
      ];

  String t(String key) => _T.get(_selectedLangCode, key);

  bool get _isRTL =>
      kAllLanguages.firstWhere((l) => l.code == _selectedLangCode,
          orElse: () => kAllLanguages.first).isRTL;

  void _onLanguageConfirmed(String code) async {
    _selectedLangCode = code;
    await StorageService.instance.saveLanguage(code);
    setState(() => _languageSelected = true);
    _animController.reset();
    _animController.forward();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animController.reset();
    _animController.forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await StorageService.instance.setOnboardingComplete();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_languageSelected) {
      return _LanguageSelectionScreen(
        onConfirmed: _onLanguageConfirmed,
      );
    }

    final current = _pages[_currentPage];

    return Directionality(
      textDirection: _isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [current.primaryColor, current.secondaryColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_currentPage + 1} / ${_pages.length}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            t('skip'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Page View ────────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) =>
                        _buildPage(_pages[index]),
                  ),
                ),

                // ── Bottom Section ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => _buildDot(i),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: current.primaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? t('getStarted')
                                    : t('next'),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: current.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.check_rounded
                                    : Icons.arrow_forward_rounded,
                                color: current.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_PageData page) {
    return FadeTransition(
      opacity: _animController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(page.emoji, style: const TextStyle(fontSize: 70)),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              t(page.titleKey),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              t(page.descKey),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ── Language Selection Screen ─────────────────────────────────────────────────

class _LanguageSelectionScreen extends StatefulWidget {
  final void Function(String code) onConfirmed;

  const _LanguageSelectionScreen({required this.onConfirmed});

  @override
  State<_LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<_LanguageSelectionScreen> {
  String _selected = 'en';
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<_Language> get _filtered {
    if (_search.isEmpty) return kAllLanguages;
    final q = _search.toLowerCase();
    return kAllLanguages.where((l) =>
        l.nativeName.toLowerCase().contains(q) ||
        l.englishName.toLowerCase().contains(q) ||
        l.code.contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A3D28), Color(0xFF2D5F3F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: Column(
                  children: [
                    const Text('🕋', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    const Text(
                      'Choose Your Language',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${kAllLanguages.length} languages supported',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white60,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _search = v),
                        decoration: InputDecoration(
                          hintText: 'Search language...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: Colors.white54),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded,
                                      color: Colors.white54),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _search = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Language Grid ───────────────────────────────────────────
              Expanded(
                child: _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No language found',
                          style: TextStyle(color: Colors.white60),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final lang = _filtered[index];
                          final isSelected = _selected == lang.code;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selected = lang.code);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  Text(lang.flag,
                                      style: const TextStyle(fontSize: 22)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.nativeName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? const Color(0xFF2D5F3F)
                                                : Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          lang.englishName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isSelected
                                                ? const Color(0xFF2D5F3F)
                                                    .withOpacity(0.7)
                                                : Colors.white54,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Color(0xFF2D5F3F),
                                        size: 18,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Continue Button ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => widget.onConfirmed(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2D5F3F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _T.get(_selected, 'continue'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5F3F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xFF2D5F3F)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class _PageData {
  final String emoji;
  final String titleKey;
  final String descKey;
  final Color primaryColor;
  final Color secondaryColor;

  const _PageData({
    required this.emoji,
    required this.titleKey,
    required this.descKey,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
// import 'package:flutter/material.dart';
// import 'home_screen.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen>
//     with SingleTickerProviderStateMixin {
//   final PageController _pageController = PageController();
//   late AnimationController _animController;
//   int _currentPage = 0;

//   final List<_OnboardingData> _pages = [
//     _OnboardingData(
//       emoji: '🕋',
//       title: 'Welcome to\nPilgrim\'s Companion',
//       description:
//           'Your complete offline guide for Hajj and Umrah. '
//           'Everything you need for a blessed journey.',
//       primaryColor: const Color(0xFF2D5F3F),
//       secondaryColor: const Color(0xFF5E9B76),
//     ),
//     _OnboardingData(
//       emoji: '📴',
//       title: 'Works 100%\nOffline',
//       description:
//           'Download once and use forever. No internet needed '
//           'after setup. Perfect for when you\'re in Saudi Arabia.',
//       primaryColor: const Color(0xFF1A5276),
//       secondaryColor: const Color(0xFF2E86C1),
//     ),
//     _OnboardingData(
//       emoji: '🌍',
//       title: '12 Languages\nSupported',
//       description:
//           'Arabic, English, Urdu, Turkish, Indonesian, French, '
//           'Bengali, Russian, Persian, Hindi, Hausa & Somali.',
//       primaryColor: const Color(0xFF6C3483),
//       secondaryColor: const Color(0xFF9B59B6),
//     ),
//     _OnboardingData(
//       emoji: '📖',
//       title: 'Full Quran\nIncluded',
//       description:
//           'The complete Holy Quran with translation downloads '
//           'in the background while you explore the app.',
//       primaryColor: const Color(0xFF784212),
//       secondaryColor: const Color(0xFFD4AF37),
//     ),
//     _OnboardingData(
//       emoji: '✨',
//       title: 'Ready to Begin\nYour Journey',
//       description:
//           'May Allah accept your Hajj and Umrah. '
//           'Let\'s start exploring your complete guide.',
//       primaryColor: const Color(0xFF2D5F3F),
//       secondaryColor: const Color(0xFFD4AF37),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   void _onPageChanged(int page) {
//     setState(() => _currentPage = page);
//     _animController.reset();
//     _animController.forward();
//   }

//   void _nextPage() {
//     if (_currentPage < _pages.length - 1) {
//       _pageController.nextPage(
//         duration: const Duration(milliseconds: 400),
//         curve: Curves.easeInOutCubic,
//       );
//     } else {
//       _finish();
//     }
//   }

//   void _finish() {
//     Navigator.of(context).pushReplacement(
//       PageRouteBuilder(
//         pageBuilder: (_, __, ___) => const HomeScreen(),
//         transitionsBuilder: (_, animation, __, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }


// // Auto advance timer (optional)
//   void _startAutoAdvance() {
//     Future.delayed(const Duration(seconds: 8), () {
//       if (mounted && _currentPage < _pages.length - 1) {
//         _nextPage();
//         _startAutoAdvance();
//       }
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final current = _pages[_currentPage];

//     return Scaffold(
//       body: AnimatedContainer(
//         duration: const Duration(milliseconds: 500),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               current.primaryColor,
//               current.secondaryColor,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // ── Top Bar ────────────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Page indicator text
//                     Text(
//                       '${_currentPage + 1} / ${_pages.length}',
//                       style: const TextStyle(
//                         color: Colors.white60,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),

//                     // Skip button
//                     if (_currentPage < _pages.length - 1)
//                       TextButton(
//                         onPressed: _finish,
//                         child: const Text(
//                           'Skip',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               // ── Page View ──────────────────────────────────────────────
//               Expanded(
//                 child: PageView.builder(
//                   controller: _pageController,
//                   onPageChanged: _onPageChanged,
//                   itemCount: _pages.length,
//                   itemBuilder: (context, index) {
//                     return _buildPage(_pages[index]);
//                   },
//                 ),
//               ),

//               // ── Bottom Section ─────────────────────────────────────────
//               Padding(
//                 padding: const EdgeInsets.all(32.0),
//                 child: Column(
//                   children: [
//                     // Page Indicators
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         _pages.length,
//                         (i) => _buildDot(i),
//                       ),
//                     ),

//                     const SizedBox(height: 32),

//                     // Next / Get Started Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: _nextPage,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: current.primaryColor,
//                           elevation: 0,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               _currentPage == _pages.length - 1
//                                   ? 'Get Started'
//                                   : 'Next',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: current.primaryColor,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Icon(
//                               _currentPage == _pages.length - 1
//                                   ? Icons.check_rounded
//                                   : Icons.arrow_forward_rounded,
//                               color: current.primaryColor,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPage(_OnboardingData page) {
//     return FadeTransition(
//       opacity: _animController,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 40),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Emoji Icon
//             Container(
//               width: 140,
//               height: 140,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.15),
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(
//                   page.emoji,
//                   style: const TextStyle(fontSize: 70),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 48),

//             // Title
//             Text(
//               page.title,
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 height: 1.2,
//               ),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 20),

//             // Description
//             Text(
//               page.description,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.white70,
//                 height: 1.6,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDot(int index) {
//     final isActive = index == _currentPage;
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       width: isActive ? 28 : 8,
//       height: 8,
//       decoration: BoxDecoration(
//         color: isActive ? Colors.white : Colors.white38,
//         borderRadius: BorderRadius.circular(4),
//       ),
//     );
//   }
// }

// class _OnboardingData {
//   final String emoji;
//   final String title;
//   final String description;
//   final Color primaryColor;
//   final Color secondaryColor;

//   _OnboardingData({
//     required this.emoji,
//     required this.title,
//     required this.description,
//     required this.primaryColor,
//     required this.secondaryColor,
//   });
// }