import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RisalaService {
  static final RisalaService _instance = RisalaService._internal();
  factory RisalaService() => _instance;
  RisalaService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 5),
    followRedirects: true,
    maxRedirects: 15,
    validateStatus: (s) => s != null && s < 500,
    headers: {
      'User-Agent':
          'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
          'AppleWebKit/605.1.15 (KHTML, like Gecko) '
          'Mobile/15E148',
      'Accept': 'application/pdf,application/octet-stream,*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Referer': 'https://risala.prh.gov.sa/',
    },
  ));

  CancelToken? _cancelToken;

  // ── REAL PDF URLs (extracted from website) ────────
  static const Map<String, List<RisalaBook>> booksByLanguage = {
  // ── ENGLISH ───────────────────────────────────────
  'en': [
    RisalaBook(id: 'fasting_en', title: 'Some Rulings on Fasting', description: 'Rulings related to fasting in Islam', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/415/en_minahkam_assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/415'),
    RisalaBook(id: 'creed_en', title: 'The Sound Creed', description: 'Explanation of correct Islamic creed', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/483/en_alaqida_alhsahihah_new.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/483'),
    RisalaBook(id: 'must_know_en', title: 'What A Muslim Must Know', description: 'Essential knowledge for every Muslim', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/511/en_malaa_yasaa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/511'),
    RisalaBook(id: 'umrah_en', title: 'How to do Umrah', description: 'Step by step guide for Umrah', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/940/en_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/940'),
    RisalaBook(id: 'tawhid_en', title: 'Safeguarding Tawhid', description: 'Protecting the oneness of Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/en-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/en/content/397'),
  ],

  // ── URDU ──────────────────────────────────────────
  'ur': [
    RisalaBook(id: 'fasting_ur', title: 'روزے کے بعض احکام', description: 'روزے سے متعلق اسلامی احکام', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/231/ur-min_ahkam_siyam-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/231'),
    RisalaBook(id: 'creed_ur', title: 'تحقیق والی عقیدہ', description: 'صحیح اسلامی عقیدہ کی تشریح', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/178/ur_tahqiq_waliidohv3.1.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/178'),
    RisalaBook(id: 'must_know_ur', title: 'مسلمان کو جاننا چاہیے', description: 'ہر مسلمان کے لیے ضروری معلومات', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/211/ur-risalatan_mujizatan-2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/211'),
    RisalaBook(id: 'umrah_ur', title: 'عمرے کا طریقہ', description: 'عمرہ کرنے کا طریقہ', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/ur_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/933'),
    RisalaBook(id: 'tawhid_ur', title: 'حفاظت توحید', description: 'توحید کی حفاظت', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/ur-hirasah_tauhid-4.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ur/content/173'),
  ],

  // ── ARABIC ────────────────────────────────────────
  'ar': [
    RisalaBook(id: 'fasting_ar', title: 'من أحكام الصيام', description: 'أحكام الصيام في الإسلام', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/ar_minahkamsiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/252'),
    RisalaBook(id: 'creed_ar', title: 'نبذة في العقيدة الإسلامية', description: 'شرح العقيدة الصحيحة', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/ar-nubzah_fil_aqidah-1.2.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/381'),
    RisalaBook(id: 'must_know_ar', title: 'ما يجب على المسلم معرفته', description: 'المعرفة الأساسية لكل مسلم', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/244/ar_ahkamhadyi.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/244'),
    RisalaBook(id: 'umrah_ar', title: 'صفة العمرة', description: 'دليل العمرة خطوة بخطوة', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/939/ar_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/939'),
    RisalaBook(id: 'tawhid_ar', title: 'حراسة التوحيد', description: 'حماية التوحيد', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/ar-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/ar/content/397'),
  ],

  // ── TURKISH (tr) ──────────────────────────────────
  'tr': [
    RisalaBook(id: 'fasting_tr', title: 'Zekât ve Oruç Hakkında Veciz İki Risale', description: 'Oruç ile ilgili hükümler', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/475/tr-risalatan_mujizatan.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/475'),
    RisalaBook(id: 'creed_tr', title: 'İslam Akidesinin Temel İlkeleri', description: 'İslam inancının temelleri', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/795/tr-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/795'),
    RisalaBook(id: 'must_know_tr', title: 'Müslümanın Kesin Olarak Bilmesi Gereken Konular', description: 'Her Müslümanın bilmesi gerekenler', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/tr-ma_la_yasa-3.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/858'),
    RisalaBook(id: 'umrah_tr', title: 'Umre Nasıl Yapılır', description: 'Umre rehberi', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/tr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/933'),
    RisalaBook(id: 'tawhid_tr', title: 'Tevhidi Koruma', description: 'Allah’ın birliğini koruma', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/tr-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/tr/content/173'),
  ],

  // ── FRENCH (fr) ───────────────────────────────────
  'fr': [
    RisalaBook(id: 'fasting_fr', title: 'Parmi les jugements religieux relatifs au jeûne', description: 'Règles relatives au jeûne', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/818/fr_minahkam_Assiyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/818'),
    RisalaBook(id: 'creed_fr', title: 'Résumé de la Croyance Islamique', description: 'Explication de la croyance correcte', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/fr-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/381'),
    RisalaBook(id: 'must_know_fr', title: 'Ce que tout Musulman doit savoir', description: 'Connaissances essentielles', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/fr-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/858'),
    RisalaBook(id: 'umrah_fr', title: 'Description de la Oumra', description: 'Guide étape par étape', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/946/fr_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/946'),
    RisalaBook(id: 'tawhid_fr', title: 'Protection du Tawhid', description: 'Protection de l’unicité d’Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/fr-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/fr/content/397'),
  ],

  // ── INDONESIAN (id) ───────────────────────────────
  'id': [
    RisalaBook(id: 'fasting_id', title: 'Beberapa Hukum Terkait Puasa', description: 'Hukum-hukum puasa dalam Islam', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/id_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/252'),
    RisalaBook(id: 'creed_id', title: 'Ringkasan Akidah Islam', description: 'Penjelasan akidah yang benar', category: 'Aqeedah', icon: '📖', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/381/id-nubzah_fil_aqidah.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/381'),
    RisalaBook(id: 'must_know_id', title: 'Hal yang Harus Diketahui Muslim', description: 'Pengetahuan penting bagi Muslim', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/858/id-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/858'),
    RisalaBook(id: 'umrah_id', title: 'Tata Cara Umrah', description: 'Panduan Umrah langkah demi langkah', category: 'Hajj & Umrah', icon: '🕋', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/933/id_sifat_alomrah_harmain.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/933'),
    RisalaBook(id: 'tawhid_id', title: 'Menjaga Tauhid', description: 'Melindungi Tauhid Allah', category: 'Aqeedah', icon: '☝️', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/173/id-hirasah_tauhid.pdf', bookPageUrl: 'https://risala.prh.gov.sa/id/content/173'),
  ],

  // ── BENGALI (bn) ──────────────────────────────────
  'bn': [
    RisalaBook(id: 'fasting_bn', title: 'রোজার বিধি-বিধান', description: 'রোজা সম্পর্কিত ইসলামী বিধান', category: 'Fiqh', icon: '🌙', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/252/bn_minahkam_siyam.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/252'),
    RisalaBook(id: 'must_know_bn', title: 'একজন মুসলিমের জানা উচিত', description: 'প্রত্যেক মুসলিমের জন্য অপরিহার্য জ্ঞান', category: 'Education', icon: '📚', pdfUrl: 'https://risala.prh.gov.sa/storage/contents/348/bn-ma_la_yasa.pdf', bookPageUrl: 'https://risala.prh.gov.sa/bn/content/348'),
  ],
};
  // static const Map<String, List<RisalaBook>> booksByLanguage = {
  //   // ── ENGLISH (5 books) ────────────────────────────
  //   'en': [
  //     RisalaBook(
  //       id: 'fasting_en',
  //       title: 'Some Rulings on Fasting',
  //       description: 'Rulings related to fasting in Islam',
  //       category: 'Fiqh',
  //       icon: '🌙',
  //       pdfUrl: 'https://risala.prh.gov.sa/storage/contents/415/en_minahkam_assiyam.pdf',
  //       bookPageUrl: 'https://risala.prh.gov.sa/en/content/415',
  //     ),
  //     RisalaBook(
  //       id: 'creed_en',
  //       title: 'The Sound Creed',
  //       description: 'Explanation of correct Islamic creed',
  //       category: 'Aqeedah',
  //       icon: '📖',
  //       pdfUrl: 'https://risala.prh.gov.sa/storage/contents/483/en_alaqida_alhsahihah_new.pdf',
  //       bookPageUrl: 'https://risala.prh.gov.sa/en/content/483',
  //     ),
  //     RisalaBook(
  //       id: 'must_know_en',
  //       title: 'What A Muslim Must Know',
  //       description: 'Essential knowledge for every Muslim',
  //       category: 'Education',
  //       icon: '📚',
  //       pdfUrl: 'https://risala.prh.gov.sa/storage/contents/511/en_malaa_yasaa.pdf',
  //       bookPageUrl: 'https://risala.prh.gov.sa/en/content/511',
  //     ),
  //     RisalaBook(
  //       id: 'umrah_en',
  //       title: 'How to do Umrah',
  //       description: 'Step by step guide for Umrah',
  //       category: 'Hajj & Umrah',
  //       icon: '🕋',
  //       pdfUrl: 'https://risala.prh.gov.sa/storage/contents/940/en_sifat_alomrah_harmain.pdf',
  //       bookPageUrl: 'https://risala.prh.gov.sa/en/content/940',
  //     ),
  //     RisalaBook(
  //       id: 'tawhid_en',
  //       title: 'Safeguarding Tawhid',
  //       description: 'Protecting the oneness of Allah',
  //       category: 'Aqeedah',
  //       icon: '☝️',
  //       pdfUrl: 'https://risala.prh.gov.sa/storage/contents/397/en-hirasah_tauhid-4.pdf',
  //       bookPageUrl: 'https://risala.prh.gov.sa/en/content/397',
  //     ),
  //   ],

  //   // ── URDU (you need to collect these) ─────────────
  //   'ur': [
  //     // TODO: Go to https://risala.prh.gov.sa/ur
  //     // Run the same script to get PDF URLs
  //     // Then add them here
  //   ],

  //   // Add more languages as you collect them...
  // };

  // ── Get Books for Language ────────────────────────
  static List<RisalaBook> getBooksForLanguage(String langCode) {
    return booksByLanguage[langCode] ?? booksByLanguage['en'] ?? [];
  }

  // ── Get All Categories ────────────────────────────
  static List<String> getCategoriesForLanguage(String langCode) {
    final books = getBooksForLanguage(langCode);
    return books.map((b) => b.category).toSet().toList();
  }

  // ── Download Directory ────────────────────────────
  Future<String> getRisalaDirectory(String langCode) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/risala/$langCode');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  // ── PDF File Path ─────────────────────────────────
  Future<String> getBookPath(String langCode, String bookId) async {
    final dir = await getRisalaDirectory(langCode);
    return '$dir/$bookId.pdf';
  }

  // ── Check if Downloaded ───────────────────────────
  Future<bool> isBookDownloaded(String langCode, String bookId) async {
    try {
      final path = await getBookPath(langCode, bookId);
      final file = File(path);
      if (!await file.exists()) return false;
      final size = await file.length();
      return size > 10 * 1024;
    } catch (_) {
      return false;
    }
  }

  Future<int> getDownloadedCount(String langCode) async {
    final books = getBooksForLanguage(langCode);
    int count = 0;
    for (final book in books) {
      if (await isBookDownloaded(langCode, book.id)) {
        count++;
      }
    }
    return count;
  }

  // ── Download Single Book ──────────────────────────
  Future<bool> downloadBook({
    required String langCode,
    required RisalaBook book,
    required void Function(double) onProgress,
  }) async {
    try {
      final path = await getBookPath(langCode, book.id);
      final partPath = '$path.part';
      _cancelToken = CancelToken();

      print('📥 Downloading: ${book.title}');

      // Use direct PDF URL
      final pdfUrl = book.pdfUrl;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        print('❌ No PDF URL for: ${book.title}');
        return false;
      }

      print('🔗 Downloading from: $pdfUrl');

      try {
        final response = await _dio.download(
          pdfUrl,
          partPath,
          cancelToken: _cancelToken,
          deleteOnError: true,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 '
                  'like Mac OS X) AppleWebKit/605.1.15',
              'Accept': 'application/pdf,application/octet-stream,*/*',
              'Referer': book.bookPageUrl ?? 'https://risala.prh.gov.sa/',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              onProgress((received / total).clamp(0.0, 1.0));
            } else {
              onProgress((received / (5 * 1024 * 1024)).clamp(0.0, 0.9));
            }
          },
        );

        // Verify it's a real PDF
        final partFile = File(partPath);
        if (await partFile.exists()) {
          final size = await partFile.length();
          final isValidPdf = await _verifyPdf(partPath);

          if (size > 10 * 1024 && isValidPdf) {
            await partFile.rename(path);
            print('✅ Downloaded: ${book.title} (${(size / 1024).toStringAsFixed(0)} KB)');
            return true;
          } else {
            print('⚠️ Invalid PDF, deleting...');
            await partFile.delete().catchError((_) {});
          }
        }
      } catch (urlError) {
        print('❌ Download failed: $urlError');
        File(partPath).delete().catchError((_) {});
      }

      print('⚠️ Failed to download: ${book.title}');
      return false;
    } catch (e) {
      print('❌ Download error: ${book.title} - $e');
      return false;
    }
  }

  // ── Verify PDF is real ────────────────────────────
  Future<bool> _verifyPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.openRead(0, 5).first;
      if (bytes.length >= 4) {
        return bytes[0] == 0x25 && // %
            bytes[1] == 0x50 &&    // P
            bytes[2] == 0x44 &&    // D
            bytes[3] == 0x46;      // F
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ── Download ALL Books for Language ───────────────
  Future<void> downloadAllBooks({
    required String langCode,
    required void Function(String bookTitle, int current, int total, double progress) onProgress,
    required void Function() onComplete,
    required void Function(String error) onError,
  }) async {
    final books = getBooksForLanguage(langCode);
    final total = books.length;

    for (int i = 0; i < total; i++) {
      final book = books[i];

      if (await isBookDownloaded(langCode, book.id)) {
        onProgress(book.title, i + 1, total, 1.0);
        continue;
      }

      onProgress(book.title, i + 1, total, 0.0);

      await downloadBook(
        langCode: langCode,
        book: book,
        onProgress: (progress) {
          onProgress(book.title, i + 1, total, progress);
        },
      );
    }

    onComplete();
  }

  void cancelDownload() {
    _cancelToken?.cancel('Cancelled');
  }

  // ── Delete All Books ──────────────────────────────
  Future<void> deleteAllBooks(String langCode) async {
    try {
      final dir = Directory(await getRisalaDirectory(langCode));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (e) {
      print('❌ Delete error: $e');
    }
  }

  // ── Get total size ────────────────────────────────
  Future<String> getTotalSize(String langCode) async {
    try {
      final dirPath = await getRisalaDirectory(langCode);
      final dir = Directory(dirPath);
      if (!await dir.exists()) return '0 MB';

      int total = 0;
      await for (final f in dir.list()) {
        if (f is File) total += await f.length();
      }
      return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }
}

// ── Risala Book Model ──────────────────────────────────
class RisalaBook {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final String? pdfUrl;       // Direct PDF download URL
  final String? bookPageUrl;  // Webpage URL for "Read Online"

  const RisalaBook({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.pdfUrl,
    this.bookPageUrl,
  });

  // Backward compatibility - so old code still works
  String get fallbackUrl => bookPageUrl ?? '';
  String get primaryUrl => pdfUrl ?? bookPageUrl ?? '';
  String get mirrorUrl => pdfUrl ?? '';
  List<String> get allUrls => [
    if (pdfUrl != null && pdfUrl!.isNotEmpty) pdfUrl!,
    if (bookPageUrl != null && bookPageUrl!.isNotEmpty) bookPageUrl!,
  ];
}
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class RisalaService {
//   // Singleton
//   static final RisalaService _instance =
//       RisalaService._internal();
//   factory RisalaService() => _instance;
//   RisalaService._internal();

// final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(minutes: 5),
//     receiveTimeout: const Duration(minutes: 10),
//     sendTimeout: const Duration(minutes: 5),
//     followRedirects: true,
//     maxRedirects: 15,
//     validateStatus: (s) => s != null && s < 500,
//     headers: {
//       'User-Agent':
//           'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
//           'AppleWebKit/605.1.15 (KHTML, like Gecko) '
//           'Mobile/15E148',
//       'Accept': 'application/pdf,*/*',
//       'Accept-Language': 'en-US,en;q=0.9',
//       'Referer': 'https://risala.prh.gov.sa/',
//     },
//   ));

//   CancelToken? _cancelToken;

//   // ── Base URLs ─────────────────────────────────────
//  // ── ALL PDFs per language ─────────────────────────
//   static const Map<String, List<RisalaBook>>
//       booksByLanguage = {
//     // ── ENGLISH ──────────────────────────────────
//     'en': [
//       RisalaBook(
//         id: 'umrah_en',
//         title: 'Umrah Procedure',
//         description: 'Step by step guide for Umrah',
//         category: 'Hajj & Umrah',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'hajj_en',
//         title: 'Hajj & Umrah Issues',
//         description: 'Many issues of Hajj and Umrah',
//         category: 'Hajj & Umrah',
//         icon: '🌙',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=2&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/2',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'faith_en',
//         title: 'Introduction to Islamic Faith',
//         description: 'Basics of Islamic belief',
//         category: 'Aqeedah',
//         icon: '📖',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=3&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/3',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_en',
//         title: 'The Prayer of the Prophet ﷺ',
//         description: 'How the Prophet prayed',
//         category: 'Prayer',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_en',
//         title: 'Method of Ablution',
//         description: 'How to perform Wudu',
//         category: 'Prayer',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_en',
//         title: 'Important Lessons for Muslims',
//         description: 'Essential Islamic lessons',
//         category: 'Education',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_en',
//         title: 'Rules of Sacrifice & Slaughter',
//         description: 'Islamic rulings on sacrifice',
//         category: 'Fiqh',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//       RisalaBook(
//         id: 'dhulhijjah_en',
//         title: 'Virtues of Ten Days of Dhul-Hijjah',
//         description: 'Virtues of the blessed ten days',
//         category: 'Hajj & Umrah',
//         icon: '🌟',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=8&lang=en',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/en/main-content/book/8',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/en/main-content',
//       ),
//     ],

//     // ── ARABIC ───────────────────────────────────
//     'ar': [
//       RisalaBook(
//         id: 'umrah_ar',
//         title: 'صفة العمرة',
//         description: 'دليل أداء العمرة',
//         category: 'الحج والعمرة',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'hajj_ar',
//         title: 'مسائل الحج والعمرة',
//         description: 'مسائل كثيرة في الحج والعمرة',
//         category: 'الحج والعمرة',
//         icon: '🌙',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=2&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/2',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'faith_ar',
//         title: 'مختصر في العقيدة',
//         description: 'أساسيات العقيدة الإسلامية',
//         category: 'العقيدة',
//         icon: '📖',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=3&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/3',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_ar',
//         title: 'صفة صلاة النبي ﷺ',
//         description: 'كيف صلى النبي',
//         category: 'الصلاة',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_ar',
//         title: 'طريقة الوضوء',
//         description: 'كيفية الوضوء الصحيح',
//         category: 'الصلاة',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_ar',
//         title: 'دروس مهمة لعامة الأمة',
//         description: 'دروس إسلامية أساسية',
//         category: 'التعليم',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_ar',
//         title: 'أحكام الأضحية والذبح',
//         description: 'أحكام إسلامية في الأضحية',
//         category: 'الفقه',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//       RisalaBook(
//         id: 'dhulhijjah_ar',
//         title: 'فضائل عشر ذي الحجة',
//         description: 'فضل أيام العشر',
//         category: 'الحج والعمرة',
//         icon: '🌟',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=8&lang=ar',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ar/main-content/book/8',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ar/main-content',
//       ),
//     ],

//     // ── URDU ─────────────────────────────────────
//     'ur': [
//       RisalaBook(
//         id: 'umrah_ur',
//         title: 'عمرہ کا طریقہ',
//         description: 'عمرہ ادا کرنے کا مکمل طریقہ',
//         category: 'حج و عمرہ',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'hajj_ur',
//         title: 'حج و عمرہ کے مسائل',
//         description: 'حج اور عمرہ کا مکمل رہنما',
//         category: 'حج و عمرہ',
//         icon: '🌙',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=2&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/2',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'faith_ur',
//         title: 'اسلامی عقیدہ کا تعارف',
//         description: 'اسلامی عقیدے کی بنیادیں',
//         category: 'عقیدہ',
//         icon: '📖',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=3&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/3',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_ur',
//         title: 'نبی ﷺ کی نماز',
//         description: 'نبی ﷺ نے کس طرح نماز پڑھی',
//         category: 'نماز',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_ur',
//         title: 'وضوء کا طریقہ',
//         description: 'صحیح طریقے سے وضو کرنا',
//         category: 'نماز',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_ur',
//         title: 'عام مسلمانوں کے لیے اہم دروس',
//         description: 'اسلامی تعلیمات کے اہم اسباق',
//         category: 'تعلیم',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_ur',
//         title: 'قربانی کے احکام',
//         description: 'قربانی کے اسلامی احکام',
//         category: 'فقہ',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//       RisalaBook(
//         id: 'dhulhijjah_ur',
//         title: 'ذوالحجہ کے دس دنوں کی فضیلت',
//         description: 'ذو الحجہ کے پہلے عشرے کی اہمیت',
//         category: 'حج و عمرہ',
//         icon: '🌟',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=8&lang=ur',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ur/main-content/book/8',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ur/main-content',
//       ),
//     ],

//     // ── TURKISH ──────────────────────────────────
//     'tr': [
//       RisalaBook(
//         id: 'umrah_tr',
//         title: 'Umre Yapmanın Yolu',
//         description: 'Umre adım adım rehberi',
//         category: 'Hac & Umre',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=tr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/tr/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/tr/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_tr',
//         title: 'Nebinin ﷺ Namazı',
//         description: 'Peygamber nasıl namaz kıldı',
//         category: 'Namaz',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=tr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/tr/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/tr/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_tr',
//         title: 'Abdest Alma Yöntemi',
//         description: 'Doğru abdest nasıl alınır',
//         category: 'Namaz',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=tr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/tr/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/tr/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_tr',
//         title: 'Müslümanlar için Önemli Dersler',
//         description: 'Temel İslami dersler',
//         category: 'Eğitim',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=tr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/tr/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/tr/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_tr',
//         title: 'Kurban ve Kesim Kuralları',
//         description: 'Kurban hakkında İslami hükümler',
//         category: 'Fıkıh',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=tr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/tr/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/tr/main-content',
//       ),
//     ],

//     // ── INDONESIAN ───────────────────────────────
//     'id': [
//       RisalaBook(
//         id: 'umrah_id',
//         title: 'Tata Cara Umrah',
//         description: 'Panduan langkah demi langkah',
//         category: 'Haji & Umrah',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=id',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/id/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/id/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_id',
//         title: 'Shalat Nabi ﷺ',
//         description: 'Bagaimana Nabi shalat',
//         category: 'Shalat',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=id',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/id/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/id/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_id',
//         title: 'Cara Berwudhu',
//         description: 'Tata cara wudhu yang benar',
//         category: 'Shalat',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=id',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/id/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/id/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_id',
//         title: 'Pelajaran Penting bagi Muslim',
//         description: 'Pelajaran Islam yang penting',
//         category: 'Pendidikan',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=id',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/id/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/id/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_id',
//         title: 'Hukum Qurban dan Sembelihan',
//         description: 'Hukum Islam tentang kurban',
//         category: 'Fiqih',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=id',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/id/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/id/main-content',
//       ),
//     ],

//     // ── FRENCH ───────────────────────────────────
//     'fr': [
//       RisalaBook(
//         id: 'umrah_fr',
//         title: 'La Procédure de la Omra',
//         description: 'Guide étape par étape',
//         category: 'Hajj & Omra',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=fr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fr/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fr/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_fr',
//         title: 'La Prière du Prophète ﷺ',
//         description: 'Comment le Prophète priait',
//         category: 'Prière',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=fr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fr/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fr/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_fr',
//         title: 'Méthode des Ablutions',
//         description: 'Comment effectuer le Wudu',
//         category: 'Prière',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=fr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fr/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fr/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_fr',
//         title: 'Leçons importantes pour les Musulmans',
//         description: 'Leçons islamiques essentielles',
//         category: 'Éducation',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=fr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fr/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fr/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_fr',
//         title: 'Règles du Sacrifice',
//         description: 'Règles islamiques du sacrifice',
//         category: 'Fiqh',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=fr',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fr/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fr/main-content',
//       ),
//     ],

//     // ── BENGALI ──────────────────────────────────
//     'bn': [
//       RisalaBook(
//         id: 'umrah_bn',
//         title: 'উমরাহ পালনের পদ্ধতি',
//         description: 'উমরাহ করার গাইড',
//         category: 'হজ ও উমরাহ',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=bn',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/bn/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/bn/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_bn',
//         title: 'নবীর ﷺ নামাজ',
//         description: 'নবী কিভাবে নামাজ পড়েছেন',
//         category: 'নামাজ',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=bn',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/bn/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/bn/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_bn',
//         title: 'ওযুর পদ্ধতি',
//         description: 'সঠিকভাবে ওযু করার নিয়ম',
//         category: 'নামাজ',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=bn',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/bn/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/bn/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_bn',
//         title: 'মুসলমানদের জন্য গুরুত্বপূর্ণ শিক্ষা',
//         description: 'প্রয়োজনীয় ইসলামী শিক্ষা',
//         category: 'শিক্ষা',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=bn',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/bn/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/bn/main-content',
//       ),
//     ],

//     // ── RUSSIAN ──────────────────────────────────
//     'ru': [
//       RisalaBook(
//         id: 'umrah_ru',
//         title: 'Порядок совершения Умры',
//         description: 'Пошаговое руководство',
//         category: 'Хадж и Умра',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=ru',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ru/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ru/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_ru',
//         title: 'Намаз Пророка ﷺ',
//         description: 'Как Пророк совершал намаз',
//         category: 'Намаз',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=ru',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ru/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ru/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_ru',
//         title: 'Способ омовения',
//         description: 'Как правильно совершать омовение',
//         category: 'Намаз',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=ru',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ru/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ru/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_ru',
//         title: 'Важные уроки для мусульман',
//         description: 'Основные исламские уроки',
//         category: 'Образование',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=ru',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ru/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ru/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_ru',
//         title: 'Правила жертвоприношения',
//         description: 'Исламские правила жертвоприношения',
//         category: 'Фикх',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=ru',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ru/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ru/main-content',
//       ),
//     ],

//     // ── PERSIAN ──────────────────────────────────
//     'fa': [
//       RisalaBook(
//         id: 'umrah_fa',
//         title: 'روش انجام عمره',
//         description: 'راهنمای گام به گام عمره',
//         category: 'حج و عمره',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=fa',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fa/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fa/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_fa',
//         title: 'نماز پیامبر ﷺ',
//         description: 'پیامبر چگونه نماز می‌خواند',
//         category: 'نماز',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=fa',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fa/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fa/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_fa',
//         title: 'روش وضو گرفتن',
//         description: 'نحوه صحیح وضو گرفتن',
//         category: 'نماز',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=fa',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fa/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fa/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_fa',
//         title: 'دروس مهم برای مسلمانان',
//         description: 'درس‌های اساسی اسلامی',
//         category: 'آموزش',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=fa',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fa/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fa/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_fa',
//         title: 'احکام قربانی و ذبح',
//         description: 'احکام اسلامی در مورد قربانی',
//         category: 'فقه',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=fa',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/fa/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/fa/main-content',
//       ),
//     ],

//     // ── HINDI ────────────────────────────────────
//     'hi': [
//       RisalaBook(
//         id: 'umrah_hi',
//         title: 'उमरा करने का तरीका',
//         description: 'उमरा करने की गाइड',
//         category: 'हज और उमरा',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=hi',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/hi/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/hi/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_hi',
//         title: 'नबी ﷺ की नमाज़',
//         description: 'नबी ने कैसे नमाज़ पढ़ी',
//         category: 'नमाज़',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=hi',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/hi/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/hi/main-content',
//       ),
//       RisalaBook(
//         id: 'wudu_hi',
//         title: 'वुज़ू का तरीका',
//         description: 'सही तरीके से वुज़ू करना',
//         category: 'नमाज़',
//         icon: '💧',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=5&lang=hi',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/hi/main-content/book/5',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/hi/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_hi',
//         title: 'मुसलमानों के लिए महत्वपूर्ण सबक',
//         description: 'आवश्यक इस्लामी सबक',
//         category: 'शिक्षा',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=hi',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/hi/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/hi/main-content',
//       ),
//       RisalaBook(
//         id: 'sacrifice_hi',
//         title: 'कुर्बानी के नियम',
//         description: 'कुर्बानी के इस्लामी नियम',
//         category: 'फ़िक़्ह',
//         icon: '🐑',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=7&lang=hi',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/hi/main-content/book/7',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/hi/main-content',
//       ),
//     ],

//     // ── HAUSA ────────────────────────────────────
//     'ha': [
//       RisalaBook(
//         id: 'umrah_ha',
//         title: 'Hanyar Yin Umrah',
//         description: 'Jagora don Umrah',
//         category: 'Hajji & Umrah',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=ha',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ha/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ha/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_ha',
//         title: 'Sallah ta Annabi ﷺ',
//         description: 'Yadda Annabi yayi sallah',
//         category: 'Sallah',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=ha',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ha/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ha/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_ha',
//         title: 'Muhimman Darussan Musulmi',
//         description: 'Muhimman darussan Musulunci',
//         category: 'Ilimi',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=ha',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/ha/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/ha/main-content',
//       ),
//     ],

//     // ── SOMALI ───────────────────────────────────
//     'so': [
//       RisalaBook(
//         id: 'umrah_so',
//         title: 'Habka Cimarada',
//         description: 'Tilmaamaha Cimarada',
//         category: 'Xajka & Cimarada',
//         icon: '🕋',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=1&lang=so',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/so/main-content/book/1',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/so/main-content',
//       ),
//       RisalaBook(
//         id: 'prayer_so',
//         title: 'Salaadda Nabiga ﷺ',
//         description: 'Sida Nabiga u tukado',
//         category: 'Salaad',
//         icon: '🤲',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=4&lang=so',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/so/main-content/book/4',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/so/main-content',
//       ),
//       RisalaBook(
//         id: 'lessons_so',
//         title: 'Casharro Muhiim ah Muslimka',
//         description: 'Casharro aasaasiga ah',
//         category: 'Waxbarashada',
//         icon: '📚',
//         primaryUrl:
//             'https://risala.prh.gov.sa/api/v1/books/download?id=6&lang=so',
//         mirrorUrl:
//             'https://risala.prh.gov.sa/so/main-content/book/6',
//         fallbackUrl:
//             'https://risala.prh.gov.sa/so/main-content',
//       ),
//     ],
//   };

//   // ── Get Books for Language ────────────────────────

//   static List<RisalaBook> getBooksForLanguage(
//     String langCode,
//   ) {
//     return booksByLanguage[langCode] ??
//         booksByLanguage['en'] ??
//         [];
//   }

//   // ── Get All Categories ────────────────────────────

//   static List<String> getCategoriesForLanguage(
//     String langCode,
//   ) {
//     final books = getBooksForLanguage(langCode);
//     return books.map((b) => b.category).toSet().toList();
//   }

//   // ── Download Directory ────────────────────────────

//   Future<String> getRisalaDirectory(
//     String langCode,
//   ) async {
//     final base = await getApplicationDocumentsDirectory();
//     final dir = Directory(
//       '${base.path}/risala/$langCode',
//     );
//     if (!await dir.exists()) {
//       await dir.create(recursive: true);
//     }
//     return dir.path;
//   }

//   // ── PDF File Path ─────────────────────────────────

//   Future<String> getBookPath(
//     String langCode,
//     String bookId,
//   ) async {
//     final dir = await getRisalaDirectory(langCode);
//     return '$dir/$bookId.pdf';
//   }

//   // ── Check if Downloaded ───────────────────────────

//   Future<bool> isBookDownloaded(
//     String langCode,
//     String bookId,
//   ) async {
//     try {
//       final path = await getBookPath(langCode, bookId);
//       final file = File(path);
//       if (!await file.exists()) return false;
//       final size = await file.length();
//       return size > 10 * 1024; // At least 10KB
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<int> getDownloadedCount(
//     String langCode,
//   ) async {
//     final books = getBooksForLanguage(langCode);
//     int count = 0;
//     for (final book in books) {
//       if (await isBookDownloaded(langCode, book.id)) {
//         count++;
//       }
//     }
//     return count;
//   }

//   // ── Download Single Book ──────────────────────────

// // ── Download Single Book ──────────────────────────

//   Future<bool> downloadBook({
//     required String langCode,
//     required RisalaBook book,
//     required void Function(double) onProgress,
//   }) async {
//     try {
//       final path = await getBookPath(langCode, book.id);
//       final partPath = '$path.part';
//       _cancelToken = CancelToken();

//       print('📥 Downloading: ${book.title}');

//       // Try all URLs
//       for (int i = 0; i < book.allUrls.length; i++) {
//         final url = book.allUrls[i];
//         print('🔗 Trying URL ${i + 1}/${book.allUrls.length}: $url');

//         try {
//           final response = await _dio.download(
//             url,
//             partPath,
//             cancelToken: _cancelToken,
//             deleteOnError: true,
//             options: Options(
//               responseType: ResponseType.bytes,
//               followRedirects: true,
//               headers: {
//                 'User-Agent':
//                     'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 '
//                     'like Mac OS X) AppleWebKit/605.1.15',
//                 'Accept': 'application/pdf,*/*',
//                 'Referer': 'https://risala.prh.gov.sa/',
//               },
//             ),
//             onReceiveProgress: (received, total) {
//               if (total > 0) {
//                 onProgress(
//                   (received / total).clamp(0.0, 1.0),
//                 );
//               } else {
//                 // Unknown size - show progress based on received
//                 onProgress(
//                   (received / (5 * 1024 * 1024)).clamp(0.0, 0.9),
//                 );
//               }
//             },
//           );

//           // Verify it's a real PDF
//           final partFile = File(partPath);
//           if (await partFile.exists()) {
//             final size = await partFile.length();
//             final isValidPdf =
//                 await _verifyPdf(partPath);

//             if (size > 10 * 1024 && isValidPdf) {
//               await partFile.rename(path);
//               print('✅ Downloaded: ${book.title} '
//                   '(${(size / 1024).toStringAsFixed(0)} KB)');
//               return true;
//             } else {
//               print('⚠️ Invalid PDF at URL $i, trying next...');
//               await partFile.delete().catchError((_) {});
//             }
//           }
//         } catch (urlError) {
//           print('❌ URL $i failed: $urlError');
//           File(partPath).delete().catchError((_) {});
//         }
//       }

//       // All URLs failed - save fallback
//       print('⚠️ All URLs failed for: ${book.title}');
//       await _saveFallbackNote(
//         langCode,
//         book.id,
//         book.fallbackUrl,
//       );
//       return false;
//     } catch (e) {
//       print('❌ Download error: ${book.title} - $e');
//       await _saveFallbackNote(
//         langCode,
//         book.id,
//         book.fallbackUrl,
//       );
//       return false;
//     }
//   }

//   // ── Verify PDF is real ────────────────────────────

//   Future<bool> _verifyPdf(String filePath) async {
//     try {
//       final file = File(filePath);
//       final bytes = await file.openRead(0, 5).first;

//       // PDF magic bytes: %PDF-
//       if (bytes.length >= 4) {
//         return bytes[0] == 0x25 && // %
//             bytes[1] == 0x50 &&    // P
//             bytes[2] == 0x44 &&    // D
//             bytes[3] == 0x46;      // F
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }


//   Future<void> _saveFallbackNote(
//     String langCode,
//     String bookId,
//     String url,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(
//       'risala_fallback_${langCode}_$bookId',
//       url,
//     );
//   }

//   Future<String?> getFallbackUrl(
//     String langCode,
//     String bookId,
//   ) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(
//       'risala_fallback_${langCode}_$bookId',
//     );
//   }

//   // ── Download ALL Books for Language ───────────────

//   Future<void> downloadAllBooks({
//     required String langCode,
//     required void Function(
//       String bookTitle,
//       int current,
//       int total,
//       double progress,
//     ) onProgress,
//     required void Function() onComplete,
//     required void Function(String error) onError,
//   }) async {
//     final books = getBooksForLanguage(langCode);
//     final total = books.length;

//     for (int i = 0; i < total; i++) {
//       final book = books[i];

//       // Skip if already downloaded
//       if (await isBookDownloaded(langCode, book.id)) {
//         onProgress(book.title, i + 1, total, 1.0);
//         continue;
//       }

//       onProgress(book.title, i + 1, total, 0.0);

//       await downloadBook(
//         langCode: langCode,
//         book: book,
//         onProgress: (progress) {
//           onProgress(
//             book.title,
//             i + 1,
//             total,
//             progress,
//           );
//         },
//       );
//     }

//     onComplete();
//   }

//   void cancelDownload() {
//     _cancelToken?.cancel('Cancelled');
//   }

//   // ── Delete All Books ──────────────────────────────

//   Future<void> deleteAllBooks(String langCode) async {
//     try {
//       final dir = Directory(
//         await getRisalaDirectory(langCode),
//       );
//       if (await dir.exists()) {
//         await dir.delete(recursive: true);
//       }
//     } catch (e) {
//       print('❌ Delete error: $e');
//     }
//   }

//   // ── Get total size ────────────────────────────────

//   Future<String> getTotalSize(String langCode) async {
//     try {
//       final dirPath =
//           await getRisalaDirectory(langCode);
//       final dir = Directory(dirPath);
//       if (!await dir.exists()) return '0 MB';

//       int total = 0;
//       await for (final f in dir.list()) {
//         if (f is File) total += await f.length();
//       }
//       return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
//     } catch (_) {
//       return '0 MB';
//     }
//   }
// }

// // ── Risala Book Model ──────────────────────────────────


// class RisalaBook {
//   final String id;
//   final String title;
//   final String description;
//   final String category;
//   final String icon;
//   final String primaryUrl;
//   final String mirrorUrl;
//   final String fallbackUrl;

//   const RisalaBook({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.icon,
//     required this.primaryUrl,
//     required this.mirrorUrl,
//     required this.fallbackUrl,
//   });

//   // All URLs to try in order
//   List<String> get allUrls => [
//         primaryUrl,
//         mirrorUrl,
//       ];
// }