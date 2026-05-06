import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// ── Risala PDF Model ───────────────────────────────────────────────────────

class RisalaPdf {
  final String id;
  final String title;
  final String pdfUrl;
  final String? coverUrl;
  final String category;
  final String languageCode;

  RisalaPdf({
    required this.id,
    required this.title,
    required this.pdfUrl,
    this.coverUrl,
    required this.category,
    required this.languageCode,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'pdfUrl': pdfUrl,
        'coverUrl': coverUrl,
        'category': category,
        'languageCode': languageCode,
      };

  factory RisalaPdf.fromJson(Map<String, dynamic> json) => RisalaPdf(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        pdfUrl: json['pdfUrl'] ?? '',
        coverUrl: json['coverUrl'],
        category: json['category'] ?? 'general',
        languageCode: json['languageCode'] ?? 'en',
      );

  // Local file name for saving
  String get fileName =>
      'risala_${languageCode}_$id.pdf';
}

// ── Risala Category ────────────────────────────────────────────────────────

class RisalaCategory {
  final String id;
  final String title;
  final String icon;
  final List<RisalaPdf> pdfs;

  RisalaCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.pdfs,
  });
}

// ── Risala PDF Service ─────────────────────────────────────────────────────

class RisalaPdfService {
  // Singleton
  static final RisalaPdfService _instance =
      RisalaPdfService._internal();
  factory RisalaPdfService() => _instance;
  RisalaPdfService._internal();

  static const String _baseUrl = 'https://risala.prh.gov.sa';
  static const String _cacheKeyPrefix = 'risala_pdfs_';
  static const Duration _cacheMaxAge = Duration(days: 7);

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    followRedirects: true,
    maxRedirects: 10,
    validateStatus: (s) => s != null && s < 500,
  ));

  // ── Category icons mapping ─────────────────────────────────────────────
  static const Map<String, String> _categoryIcons = {
    'hajj': '🕋',
    'umrah': '🕋',
    'prayer': '🙏',
    'fasting': '🌙',
    'zakat': '💰',
    'quran': '📖',
    'belief': '☪️',
    'duas': '🤲',
    'ethics': '✨',
    'general': '📚',
    'eid': '🎉',
    'default': '📄',
  };

  // ── Fetch PDF list for a language ──────────────────────────────────────

  Future<List<RisalaPdf>> fetchPdfs(
    String languageCode,
  ) async {
    // Try cache first
    final cached = await _getCached(languageCode);
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    // Fetch from web
    return await _fetchFromWeb(languageCode);
  }

  Future<List<RisalaPdf>> _fetchFromWeb(
    String languageCode,
  ) async {
    try {
      final url =
          '$_baseUrl/$languageCode/main-content';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final pdfs = _parseHtml(
          response.body,
          languageCode,
        );

        // Save to cache
        if (pdfs.isNotEmpty) {
          await _saveCache(languageCode, pdfs);
        }

        return pdfs;
      }
    } catch (e) {
      print('❌ Risala fetch error: $e');
    }

    return [];
  }

  List<RisalaPdf> _parseHtml(
    String html,
    String languageCode,
  ) {
    final pdfs = <RisalaPdf>[];

    try {
      // Match PDF links: storage/contents/.../something.pdf
      final pdfPattern = RegExp(
        r'href="(https://risala\.prh\.gov\.sa/storage/contents/[^"]+\.pdf)"',
      );

      // Match cover images
      final coverPattern = RegExp(
        r'src="(https://risala\.prh\.gov\.sa/storage/contents/[^"]+\.(png|jpg|jpeg))"',
      );

      // Match titles (h3 tags near PDF links)
      final titlePattern = RegExp(
        r'###?\s*\[([^\]]{5,200})\]',
      );

      final pdfMatches =
          pdfPattern.allMatches(html).toList();
      final coverMatches =
          coverPattern.allMatches(html).toList();
      final titleMatches =
          titlePattern.allMatches(html).toList();

      for (int i = 0; i < pdfMatches.length; i++) {
        final pdfUrl = pdfMatches[i].group(1) ?? '';
        if (pdfUrl.isEmpty) continue;

        // Extract ID from URL
        final idMatch = RegExp(
          r'/contents/(\d+)/',
        ).firstMatch(pdfUrl);
        final id = idMatch?.group(1) ?? '$i';

        // Get title
        String title = 'Document ${i + 1}';
        if (i < titleMatches.length) {
          title = titleMatches[i]
                  .group(1)
                  ?.trim() ??
              title;
        }

        // Get cover image
        String? coverUrl;
        if (i < coverMatches.length) {
          coverUrl = coverMatches[i].group(1);
        }

        // Determine category from URL
        final category = _getCategoryFromUrl(pdfUrl);

        pdfs.add(RisalaPdf(
          id: id,
          title: title,
          pdfUrl: pdfUrl,
          coverUrl: coverUrl,
          category: category,
          languageCode: languageCode,
        ));
      }
    } catch (e) {
      print('❌ Parse error: $e');
    }

    return pdfs;
  }

  String _getCategoryFromUrl(String url) {
    final fileName =
        url.split('/').last.toLowerCase();

    if (fileName.contains('haj') ||
        fileName.contains('umr') ||
        fileName.contains('omr') ||
        fileName.contains('ziyar') ||
        fileName.contains('waliid')) {
      return 'hajj_umrah';
    } else if (fileName.contains('salat') ||
        fileName.contains('solat') ||
        fileName.contains('prayer') ||
        fileName.contains('wudu') ||
        fileName.contains('ablut')) {
      return 'prayer';
    } else if (fileName.contains('fast') ||
        fileName.contains('siyam') ||
        fileName.contains('ramad')) {
      return 'fasting';
    } else if (fileName.contains('zakat') ||
        fileName.contains('zakah')) {
      return 'zakat';
    } else if (fileName.contains('dua') ||
        fileName.contains('adhkar') ||
        fileName.contains('ruqya')) {
      return 'duas';
    } else if (fileName.contains('aqidah') ||
        fileName.contains('tauhid') ||
        fileName.contains('iman') ||
        fileName.contains('usul')) {
      return 'belief';
    } else if (fileName.contains('eid') ||
        fileName.contains('adha') ||
        fileName.contains('zulhijjah')) {
      return 'eid';
    } else if (fileName.contains('quran')) {
      return 'quran';
    }
    return 'general';
  }

  // ── Get categories from PDF list ───────────────────────────────────────

  List<RisalaCategory> groupByCategory(
    List<RisalaPdf> pdfs,
    String languageCode,
  ) {
    final Map<String, List<RisalaPdf>> grouped = {};

    for (final pdf in pdfs) {
      grouped
          .putIfAbsent(pdf.category, () => [])
          .add(pdf);
    }

    final categoryTitles = {
      'hajj_umrah': _getCategoryTitle(
        'hajj_umrah',
        languageCode,
      ),
      'prayer': _getCategoryTitle(
        'prayer',
        languageCode,
      ),
      'fasting': _getCategoryTitle(
        'fasting',
        languageCode,
      ),
      'zakat': _getCategoryTitle(
        'zakat',
        languageCode,
      ),
      'duas': _getCategoryTitle(
        'duas',
        languageCode,
      ),
      'belief': _getCategoryTitle(
        'belief',
        languageCode,
      ),
      'eid': _getCategoryTitle('eid', languageCode),
      'general': _getCategoryTitle(
        'general',
        languageCode,
      ),
    };

    return grouped.entries
        .map(
          (e) => RisalaCategory(
            id: e.key,
            title: categoryTitles[e.key] ?? e.key,
            icon: _getCategoryIcon(e.key),
            pdfs: e.value,
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            _categoryOrder(a.id).compareTo(
              _categoryOrder(b.id),
            ),
      );
  }

  String _getCategoryTitle(
    String category,
    String langCode,
  ) {
    final titles = <String, Map<String, String>>{
      'hajj_umrah': {
        'en': 'Hajj, Umrah & Ziyarah',
        'ar': 'الحج والعمرة والزيارة',
        'ur': 'حج، عمرہ اور زیارت',
        'hi': 'हज, उमरा और ज़ियारत',
        'fr': 'Hajj, Umrah et Visite',
        'tr': 'Hac, Umre ve Ziyaret',
        'id': 'Haji, Umrah & Ziarah',
        'bn': 'হজ, উমরা ও যিয়ারত',
      },
      'prayer': {
        'en': 'Prayer & Purification',
        'ar': 'الصلاة والطهارة',
        'ur': 'نماز اور طہارت',
        'hi': 'नमाज़ और पवित्रता',
        'fr': 'Prière et Purification',
        'tr': 'Namaz ve Temizlik',
        'id': 'Shalat & Thaharah',
        'bn': 'নামাজ ও পবিত্রতা',
      },
      'fasting': {
        'en': 'Fasting & Zakat',
        'ar': 'الصيام والزكاة',
        'ur': 'روزہ اور زکوٰۃ',
        'hi': 'रोज़ा और ज़कात',
        'fr': 'Jeûne et Zakat',
        'tr': 'Oruç ve Zekat',
        'id': 'Puasa & Zakat',
        'bn': 'রোজা ও যাকাত',
      },
      'duas': {
        'en': 'Duas & Adhkar',
        'ar': 'الأدعية والأذكار',
        'ur': 'دعائیں اور اذکار',
        'hi': 'दुआएं और अज़कार',
        'fr': 'Douaa et Dhikr',
        'tr': 'Dualar ve Zikirler',
        'id': 'Doa & Dzikir',
        'bn': 'দোয়া ও যিকির',
      },
      'belief': {
        'en': 'Belief & Faith',
        'ar': 'العقيدة والإيمان',
        'ur': 'عقیدہ و ایمان',
        'hi': 'अक़ीदा और ईमान',
        'fr': 'Croyance et Foi',
        'tr': 'İnanç ve İman',
        'id': 'Aqidah & Iman',
        'bn': 'আকীদা ও ঈমান',
      },
      'eid': {
        'en': 'Eid & Occasions',
        'ar': 'الأعياد والمناسبات',
        'ur': 'عیدیں اور مواقع',
        'hi': 'ईद और मौके',
        'fr': 'Aïd et Occasions',
        'tr': 'Bayramlar ve Vesileler',
        'id': 'Hari Raya & Acara',
        'bn': 'ঈদ ও উপলক্ষ',
      },
      'general': {
        'en': 'General Books',
        'ar': 'الكتب العامة',
        'ur': 'عام کتب',
        'hi': 'सामान्य किताबें',
        'fr': 'Livres Généraux',
        'tr': 'Genel Kitaplar',
        'id': 'Buku Umum',
        'bn': 'সাধারণ বই',
      },
    };

    return titles[category]?[langCode] ??
        titles[category]?['en'] ??
        category;
  }

  String _getCategoryIcon(String category) {
    const icons = {
      'hajj_umrah': '🕋',
      'prayer': '🙏',
      'fasting': '🌙',
      'zakat': '💰',
      'duas': '🤲',
      'belief': '☪️',
      'eid': '🎉',
      'quran': '📖',
      'general': '📚',
    };
    return icons[category] ?? '📄';
  }

  int _categoryOrder(String category) {
    const order = {
      'hajj_umrah': 0,
      'prayer': 1,
      'fasting': 2,
      'zakat': 3,
      'duas': 4,
      'belief': 5,
      'eid': 6,
      'quran': 7,
      'general': 8,
    };
    return order[category] ?? 99;
  }

  // ── Download PDF locally ───────────────────────────────────────────────

  Future<String?> downloadPdf({
    required RisalaPdf pdf,
    required Function(double progress) onProgress,
  }) async {
    try {
      final dir = await _getPdfsDirectory(
        pdf.languageCode,
      );
      final savePath = '${dir.path}/${pdf.fileName}';
      final partPath = '$savePath.part';

      // Return cached if valid
      if (await _isValidPdf(savePath)) {
        return savePath;
      }

      // Clean up
      final partFile = File(partPath);
      if (await partFile.exists()) {
        await partFile.delete();
      }

      await _dio.download(
        pdf.pdfUrl,
        partPath,
        deleteOnError: true,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'User-Agent': 'Mozilla/5.0',
            'Accept': 'application/pdf,*/*',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          }
        },
      );

      // Validate
      if (!await _isValidPdf(partPath)) {
        await File(partPath).delete();
        throw Exception('Downloaded file is not a valid PDF');
      }

      // Rename
      await File(partPath).rename(savePath);
      return savePath;
    } catch (e) {
      print('❌ Download error: $e');
      return null;
    }
  }

  Future<bool> isPdfDownloaded(RisalaPdf pdf) async {
    try {
      final dir = await _getPdfsDirectory(
        pdf.languageCode,
      );
      final path = '${dir.path}/${pdf.fileName}';
      return await _isValidPdf(path);
    } catch (_) {
      return false;
    }
  }

  Future<String?> getLocalPath(RisalaPdf pdf) async {
    try {
      final dir = await _getPdfsDirectory(
        pdf.languageCode,
      );
      final path = '${dir.path}/${pdf.fileName}';
      if (await _isValidPdf(path)) return path;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Directory> _getPdfsDirectory(
    String languageCode,
  ) async {
    final base =
        await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${base.path}/risala_pdfs/$languageCode',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<bool> _isValidPdf(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      if (await file.length() < 1024) return false;

      final raf = await file.open();
      final header = await raf.read(4);
      await raf.close();

      return header.length == 4 &&
          header[0] == 0x25 && // %
          header[1] == 0x50 && // P
          header[2] == 0x44 && // D
          header[3] == 0x46; // F
    } catch (_) {
      return false;
    }
  }

  // ── Cache ──────────────────────────────────────────────────────────────

  Future<void> _saveCache(
    String languageCode,
    List<RisalaPdf> pdfs,
  ) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      await prefs.setString(
        '$_cacheKeyPrefix$languageCode',
        json.encode({
          'savedAt': DateTime.now().toIso8601String(),
          'data': pdfs.map((p) => p.toJson()).toList(),
        }),
      );
    } catch (e) {
      print('❌ Cache save error: $e');
    }
  }

  Future<List<RisalaPdf>?> _getCached(
    String languageCode,
  ) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      final raw = prefs.getString(
        '$_cacheKeyPrefix$languageCode',
      );
      if (raw == null) return null;

      final wrapper = json.decode(raw);
      final savedAt = DateTime.tryParse(
        wrapper['savedAt'] ?? '',
      );

      if (savedAt == null ||
          DateTime.now().difference(savedAt) >
              _cacheMaxAge) {
        return null;
      }

      return (wrapper['data'] as List)
          .map((e) => RisalaPdf.fromJson(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache(String languageCode) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      await prefs.remove(
        '$_cacheKeyPrefix$languageCode',
      );
    } catch (_) {}
  }
}