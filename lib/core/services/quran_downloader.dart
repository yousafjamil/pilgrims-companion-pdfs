
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranDownloader {
  // Singleton
  static final QuranDownloader _instance =
      QuranDownloader._internal();
  factory QuranDownloader() => _instance;
  QuranDownloader._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 20),
    sendTimeout: const Duration(seconds: 30),
    followRedirects: true,
    maxRedirects: 10,
    validateStatus: (s) => s != null && s < 500,
  ));

  CancelToken? _cancelToken;

  // Progress tracking
  final Map<String, double> _progress = {};
  final Map<String, List<void Function(double)>>
      _progressListeners = {};
  final Map<String, List<void Function(String)>>
      _completeListeners = {};
  final Map<String, List<void Function(String)>>
      _errorListeners = {};

  // ── GitHub Base URL ──────────────────────────────────────
  static const String _githubBase =
      'https://github.com/yousafjamil/pilgrims-companion-pdfs'
      '/releases/download/v1.0';

  // ── Quran URLs Per Language ──────────────────────────────
  // Priority order:
  // 1. Your own GitHub (most reliable)
  // 2. quran-pdf.com (fallback)
  // 3. Arabic version (universal fallback)
  static Map<String, List<String>> get _quranUrls => {
    // ── English ──────────────────────────────────────────
    'en': [
      '$_githubBase/quran_en.pdf',
      'https://www.quran-pdf.com/english-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Arabic ───────────────────────────────────────────
    'ar': [
      '$_githubBase/quran_ar.pdf',
      'https://www.quran-pdf.com/arabic-quran.pdf',
    ],

    // ── Urdu ─────────────────────────────────────────────
    'ur': [
      'https://www.quran-pdf.com/urdu-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Turkish ──────────────────────────────────────────
    'tr': [
      'https://www.quran-pdf.com/turkish-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Indonesian ───────────────────────────────────────
    'id': [
      'https://www.quran-pdf.com/indonesian-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── French ───────────────────────────────────────────
    'fr': [
      'https://www.quran-pdf.com/french-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Bengali ──────────────────────────────────────────
    'bn': [
      'https://www.quran-pdf.com/bengali-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Russian ──────────────────────────────────────────
    'ru': [
      'https://www.quran-pdf.com/russian-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Persian ──────────────────────────────────────────
    'fa': [
      'https://www.quran-pdf.com/persian-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Hindi ────────────────────────────────────────────
    'hi': [
      'https://www.quran-pdf.com/hindi-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Hausa ────────────────────────────────────────────
    'ha': [
      'https://www.quran-pdf.com/hausa-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],

    // ── Somali ───────────────────────────────────────────
    'so': [
      'https://www.quran-pdf.com/somali-quran.pdf',
      '$_githubBase/quran_ar.pdf', // Arabic fallback
    ],
  };

  // ── Cache Helpers ─────────────────────────────────────────

  Future<Directory> _cacheDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/quran_pdfs');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileName(String langCode) =>
      'quran_${langCode.toLowerCase()}.pdf';

  Future<bool> _isValidPdf(File file) async {
    try {
      if (!await file.exists()) return false;
      final size = await file.length();
      if (size < 500 * 1024) return false; // Min 500KB

      // Check PDF magic bytes %PDF
      final raf = await file.open();
      final header = await raf.read(4);
      await raf.close();

      return header.length == 4 &&
          header[0] == 0x25 && // %
          header[1] == 0x50 && // P
          header[2] == 0x44 && // D
          header[3] == 0x46;   // F
    } catch (_) {
      return false;
    }
  }

  // ── Public API ────────────────────────────────────────────

  Future<String?> getCachedPath(String langCode) async {
    try {
      final dir = await _cacheDir();
      final file = File('${dir.path}/${_fileName(langCode)}');

      if (await _isValidPdf(file)) {
        debugPrint('✅ Quran cached: $langCode');
        return file.path;
      }

      // Delete invalid file
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted invalid Quran: $langCode');
      }

      return null;
    } catch (e) {
      debugPrint('❌ Cache check error: $e');
      return null;
    }
  }

  bool isDownloading(String langCode) =>
      _progress.containsKey(langCode);

  double? getProgress(String langCode) =>
      _progress[langCode];

  void addProgressListener(
    String langCode,
    void Function(double) callback,
  ) {
    _progressListeners
        .putIfAbsent(langCode, () => [])
        .add(callback);
  }

  void addCompleteListener(
    String langCode,
    void Function(String) callback,
  ) {
    _completeListeners
        .putIfAbsent(langCode, () => [])
        .add(callback);
  }

  void addErrorListener(
    String langCode,
    void Function(String) callback,
  ) {
    _errorListeners
        .putIfAbsent(langCode, () => [])
        .add(callback);
  }

  void removeListeners(String langCode) {
    _progressListeners.remove(langCode);
    _completeListeners.remove(langCode);
    _errorListeners.remove(langCode);
  }

  // ── Background Download ───────────────────────────────────

  Future<void> startBackgroundDownload(String langCode) async {
    // Skip if cached
    final cached = await getCachedPath(langCode);
    if (cached != null) {
      debugPrint('📖 Quran already cached: $langCode');
      return;
    }

    // Skip if downloading
    if (isDownloading(langCode)) {
      debugPrint('📥 Already downloading: $langCode');
      return;
    }

    debugPrint('🚀 Starting Quran download: $langCode');
    _progress[langCode] = 0.0;

    await _download(
      langCode: langCode,
      onProgress: (p) {
        _progress[langCode] = p;
        for (final l in List.of(
          _progressListeners[langCode] ?? [],
        )) {
          l(p);
        }
      },
      onSuccess: (path) {
        _progress.remove(langCode);
        debugPrint('✅ Quran downloaded: $langCode');
        for (final l in List.of(
          _completeListeners[langCode] ?? [],
        )) {
          l(path);
        }
        removeListeners(langCode);
      },
      onError: (error) {
        _progress.remove(langCode);
        debugPrint('❌ Quran failed: $langCode - $error');
        for (final l in List.of(
          _errorListeners[langCode] ?? [],
        )) {
          l(error);
        }
        removeListeners(langCode);
      },
    );
  }

  // ── Manual Download ───────────────────────────────────────

  Future<void> downloadQuran({
    required String langCode,
    required void Function(double) onProgress,
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    // Attach to existing download
    if (isDownloading(langCode)) {
      debugPrint('📥 Attaching to download: $langCode');
      addProgressListener(langCode, onProgress);
      addCompleteListener(langCode, onSuccess);
      addErrorListener(langCode, onError);
      onProgress(_progress[langCode] ?? 0.0);
      return;
    }

    _progress[langCode] = 0.0;
    await _download(
      langCode: langCode,
      onProgress: (p) {
        _progress[langCode] = p;
        onProgress(p);
      },
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  // ── Core Download ─────────────────────────────────────────

  Future<void> _download({
    required String langCode,
    required void Function(double) onProgress,
    required void Function(String) onSuccess,
    required void Function(String) onError,
  }) async {
    // Get URLs for this language
    // If no specific URLs, use Arabic as fallback
    final urls = _quranUrls[langCode.toLowerCase()] ??
        [
          '$_githubBase/quran_ar.pdf',
          'https://www.quran-pdf.com/arabic-quran.pdf',
        ];

    final dir = await _cacheDir();
    final savePath = '${dir.path}/${_fileName(langCode)}';
    final partPath = '$savePath.part';
    final file = File(savePath);
    final partFile = File(partPath);

    debugPrint('📥 Downloading Quran: $langCode');
    debugPrint('📍 Save path: $savePath');

    // Clean old files
    if (await file.exists()) await file.delete();
    if (await partFile.exists()) await partFile.delete();

    String? lastError;
    _cancelToken = CancelToken();

    // Try each URL
    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      debugPrint('🔗 Trying URL ${i + 1}/${urls.length}: $url');

      try {
        await _dio.download(
          url,
          partPath,
          cancelToken: _cancelToken,
          deleteOnError: true,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: true,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 12) '
                  'AppleWebKit/537.36 Chrome/124.0 '
                  'Mobile Safari/537.36',
              'Accept': 'application/pdf,*/*',
              'Referer': 'https://www.quran-pdf.com/',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total > 0) {
              final progress =
                  (received / total).clamp(0.0, 1.0);

              // Log every 5MB
              if (received % (5 * 1024 * 1024) < 65536) {
                debugPrint(
                  '📊 $langCode: '
                  '${(progress * 100).toStringAsFixed(1)}% '
                  '(${(received / (1024 * 1024)).toStringAsFixed(1)}'
                  ' / '
                  '${(total / (1024 * 1024)).toStringAsFixed(1)} MB)',
                );
              }
              onProgress(progress);
            } else {
              // Unknown size
              final estimated =
                  (received / (100 * 1024 * 1024))
                      .clamp(0.0, 0.99);
              onProgress(estimated);
            }
          },
        );

        // Verify download
        if (!await partFile.exists()) {
          lastError = 'File missing after download';
          debugPrint('❌ URL $i: $lastError');
          continue;
        }

        final size = await partFile.length();
        debugPrint(
          '📦 Downloaded: '
          '${(size / (1024 * 1024)).toStringAsFixed(1)} MB',
        );

        // Check minimum size 500KB
        if (size < 500 * 1024) {
          await partFile.delete();
          lastError =
              'File too small - server returned invalid data';
          debugPrint('❌ URL $i: $lastError ($size bytes)');
          continue;
        }

        // Verify PDF format
        if (!await _isValidPdf(partFile)) {
          await partFile.delete();
          lastError = 'Not a valid PDF file';
          debugPrint('❌ URL $i: $lastError');
          continue;
        }

        // ✅ Success! Rename .part → final
        await partFile.rename(savePath);
        debugPrint(
          '✅ Quran saved: $langCode '
          '(${(size / (1024 * 1024)).toStringAsFixed(1)} MB)',
        );

        // Save metadata
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('quran_path_$langCode', savePath);
        await prefs.setInt('quran_size_$langCode', size);
        await prefs.setInt(
          'quran_downloaded_at_$langCode',
          DateTime.now().millisecondsSinceEpoch,
        );

        onSuccess(savePath);
        return;

      } on DioException catch (e) {
        if (await partFile.exists()) await partFile.delete();
        lastError = _friendlyError(e);
        debugPrint('❌ DioException URL $i: $lastError');

        // Don't try more URLs if cancelled
        if (e.type == DioExceptionType.cancel) {
          onError('Download cancelled');
          return;
        }
      } catch (e) {
        if (await partFile.exists()) await partFile.delete();
        lastError = 'Unexpected error: $e';
        debugPrint('❌ Exception URL $i: $e');
      }
    }

    // All URLs failed
    debugPrint('❌ All URLs failed for: $langCode');
    onError(
      lastError ??
          'Download failed for all sources. '
          'Please check your internet and retry.',
    );
  }

  // ── Error Messages ────────────────────────────────────────

  String _friendlyError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Download timed out. Use Wi-Fi for large files.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please connect and retry.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}).';
      case DioExceptionType.cancel:
        return 'Download cancelled.';
      default:
        return 'Network error: ${e.message ?? e.type.name}';
    }
  }

  // ── Controls ──────────────────────────────────────────────

  void cancelDownload() {
    _cancelToken?.cancel('Cancelled by user');
    debugPrint('⏹️ Quran download cancelled');
  }

  // ── Utility Methods ───────────────────────────────────────

  Future<bool> deleteCached(String langCode) async {
    try {
      final path = await getCachedPath(langCode);
      if (path == null) return false;

      await File(path).delete();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('quran_path_$langCode');
      await prefs.remove('quran_size_$langCode');
      await prefs.remove('quran_downloaded_at_$langCode');

      debugPrint('🗑️ Deleted Quran cache: $langCode');
      return true;
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      return false;
    }
  }

  Future<int> getTotalCachedSize() async {
    try {
      final dir = await _cacheDir();
      int total = 0;
      await for (final entity in dir.list()) {
        if (entity is File &&
            entity.path.endsWith('.pdf')) {
          total += await entity.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearAllCache() async {
    try {
      final dir = await _cacheDir();
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs
          .getKeys()
          .where((k) => k.startsWith('quran_'))) {
        await prefs.remove(key);
      }

      debugPrint('🗑️ Cleared all Quran cache');
    } catch (e) {
      debugPrint('❌ Clear cache error: $e');
    }
  }

  Future<Map<String, dynamic>?> getDownloadInfo(
    String langCode,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('quran_path_$langCode');
      final size = prefs.getInt('quran_size_$langCode');
      final timestamp =
          prefs.getInt('quran_downloaded_at_$langCode');

      if (path == null || size == null) return null;

      return {
        'path': path,
        'size': size,
        'sizeMB':
            (size / (1024 * 1024)).toStringAsFixed(1),
        'downloadedAt': timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp)
            : null,
      };
    } catch (_) {
      return null;
    }
  }
}
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class QuranDownloader {
//   // Singleton - survives navigation
//   static final QuranDownloader _instance = QuranDownloader._internal();
//   factory QuranDownloader() => _instance;
//   QuranDownloader._internal();

//   final Dio _dio = Dio(BaseOptions(
//     connectTimeout: const Duration(seconds: 30),
//     receiveTimeout: const Duration(minutes: 20),
//     sendTimeout: const Duration(seconds: 30),
//     followRedirects: true,
//     maxRedirects: 5,
//     validateStatus: (s) => s != null && s < 500,
//   ));

//   CancelToken? _cancelToken;

//   // Track downloads: langCode → progress (0.0-1.0)
//   final Map<String, double> _progress = {};
  
//   // Listeners for UI updates
//   final Map<String, List<void Function(double)>> _progressListeners = {};
//   final Map<String, List<void Function(String)>> _completeListeners = {};
//   final Map<String, List<void Function(String)>> _errorListeners = {};

//   // Direct PDF URLs - quran-pdf.com (King Fahd Complex)
//   static const Map<String, List<String>> _quranUrls = {
//     'en': [
//       'https://www.quran-pdf.com/english-quran.pdf',
//       'https://d1.islamhouse.com/data/en/ih_books/single/en_Quran_Translation.pdf',
//     ],
//     'ar': [
//       'https://www.quran-pdf.com/arabic-quran.pdf',
//       'https://d1.islamhouse.com/data/ar/ih_books/single/ar_Quran.pdf',
//     ],
//     'ur': [
//       'https://www.quran-pdf.com/urdu-quran.pdf',
//     ],
//     'tr': [
//       'https://www.quran-pdf.com/turkish-quran.pdf',
//     ],
//     'id': [
//       'https://www.quran-pdf.com/indonesian-quran.pdf',
//     ],
//     'fr': [
//       'https://www.quran-pdf.com/french-quran.pdf',
//     ],
//     'bn': [
//       'https://www.quran-pdf.com/bengali-quran.pdf',
//     ],
//     'ru': [
//       'https://www.quran-pdf.com/russian-quran.pdf',
//     ],
//     'fa': [
//       'https://www.quran-pdf.com/persian-quran.pdf',
//     ],
//     'hi': [
//       'https://www.quran-pdf.com/hindi-quran.pdf',
//     ],
//     'ha': [
//       'https://www.quran-pdf.com/hausa-quran.pdf',
//     ],
//     'so': [
//       'https://www.quran-pdf.com/somali-quran.pdf',
//     ],
//   };

//   // ── Cache Helpers ────────────────────────────────────────────────────────

//   Future<Directory> _cacheDir() async {
//     final base = await getApplicationDocumentsDirectory();
//     final dir = Directory('${base.path}/quran_pdfs');
//     if (!await dir.exists()) await dir.create(recursive: true);
//     return dir;
//   }

//   String _fileName(String langCode) => 'quran_${langCode.toLowerCase()}.pdf';

//   Future<bool> _isValidPdf(File file) async {
//     try {
//       if (!await file.exists()) return false;
//       final size = await file.length();
//       if (size < 500 * 1024) return false; // Must be at least 500 KB
      
//       // Check PDF magic bytes
//       final raf = await file.open();
//       final header = await raf.read(4);
//       await raf.close();
      
//       return header.length == 4 &&
//           header[0] == 0x25 && // %
//           header[1] == 0x50 && // P
//           header[2] == 0x44 && // D
//           header[3] == 0x46;   // F
//     } catch (_) {
//       return false;
//     }
//   }

//   // ── Public API ───────────────────────────────────────────────────────────

//   /// Get cached Quran path if exists and valid
//   Future<String?> getCachedPath(String langCode) async {
//     try {
//       final dir = await _cacheDir();
//       final file = File('${dir.path}/${_fileName(langCode)}');
      
//       if (await _isValidPdf(file)) {
//         debugPrint('✅ Quran cached: ${langCode}');
//         return file.path;
//       }
      
//       // Delete invalid cache
//       if (await file.exists()) {
//         await file.delete();
//         debugPrint('🗑️ Deleted invalid Quran cache: ${langCode}');
//       }
      
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error checking cache: $e');
//       return null;
//     }
//   }

//   /// Is Quran currently downloading?
//   bool isDownloading(String langCode) => _progress.containsKey(langCode);

//   /// Get current download progress (0.0-1.0)
//   double? getProgress(String langCode) => _progress[langCode];

//   /// Add progress listener
//   void addProgressListener(String langCode, void Function(double) callback) {
//     _progressListeners.putIfAbsent(langCode, () => []).add(callback);
//   }

//   /// Add completion listener
//   void addCompleteListener(String langCode, void Function(String) callback) {
//     _completeListeners.putIfAbsent(langCode, () => []).add(callback);
//   }

//   /// Add error listener
//   void addErrorListener(String langCode, void Function(String) callback) {
//     _errorListeners.putIfAbsent(langCode, () => []).add(callback);
//   }

//   /// Remove all listeners
//   void removeListeners(String langCode) {
//     _progressListeners.remove(langCode);
//     _completeListeners.remove(langCode);
//     _errorListeners.remove(langCode);
//   }

//   // ── Background Download ──────────────────────────────────────────────────

//   /// Start silent background download
//   /// Called when user selects language - no UI blocking
//   Future<void> startBackgroundDownload(String langCode) async {
//     // Skip if already cached
//     final cached = await getCachedPath(langCode);
//     if (cached != null) {
//       debugPrint('📖 Quran already available: $langCode');
//       return;
//     }

//     // Skip if already downloading
//     if (isDownloading(langCode)) {
//       debugPrint('📥 Quran already downloading: $langCode');
//       return;
//     }

//     debugPrint('🚀 Starting background Quran download: $langCode');
//     _progress[langCode] = 0.0;

//     await _download(
//       langCode: langCode,
//       onProgress: (p) {
//         _progress[langCode] = p;
//         // Notify all listeners
//         for (final listener in List.of(_progressListeners[langCode] ?? [])) {
//           listener(p);
//         }
//       },
//       onSuccess: (path) {
//         _progress.remove(langCode);
//         debugPrint('✅ Quran download complete: $langCode');
//         // Notify all listeners
//         for (final listener in List.of(_completeListeners[langCode] ?? [])) {
//           listener(path);
//         }
//         removeListeners(langCode);
//       },
//       onError: (error) {
//         _progress.remove(langCode);
//         debugPrint('❌ Quran download failed: $langCode - $error');
//         // Notify all listeners
//         for (final listener in List.of(_errorListeners[langCode] ?? [])) {
//           listener(error);
//         }
//         removeListeners(langCode);
//       },
//     );
//   }

//   // ── Manual Download ──────────────────────────────────────────────────────

//   /// Manual download with progress callbacks
//   /// Used when user taps "Download Now" button
//   Future<void> downloadQuran({
//     required String langCode,
//     required void Function(double) onProgress,
//     required void Function(String) onSuccess,
//     required void Function(String) onError,
//   }) async {
//     // If already downloading, attach to existing download
//     if (isDownloading(langCode)) {
//       debugPrint('📥 Attaching to existing download: $langCode');
//       addProgressListener(langCode, onProgress);
//       addCompleteListener(langCode, onSuccess);
//       addErrorListener(langCode, onError);
//       // Send current progress immediately
//       onProgress(_progress[langCode] ?? 0.0);
//       return;
//     }

//     _progress[langCode] = 0.0;
//     await _download(
//       langCode: langCode,
//       onProgress: (p) {
//         _progress[langCode] = p;
//         onProgress(p);
//       },
//       onSuccess: onSuccess,
//       onError: onError,
//     );
//   }

//   // ── Core Download Logic ──────────────────────────────────────────────────

//   Future<void> _download({
//     required String langCode,
//     required void Function(double) onProgress,
//     required void Function(String) onSuccess,
//     required void Function(String) onError,
//   }) async {
//     final urls = _quranUrls[langCode.toLowerCase()] ?? _quranUrls['en']!;
//     final dir = await _cacheDir();
//     final savePath = '${dir.path}/${_fileName(langCode)}';
//     final file = File(savePath);
//     final partPath = '$savePath.part';

//     debugPrint('📥 Downloading Quran: $langCode');
    
//     // Clean up any existing files
//     if (await file.exists()) await file.delete();
//     final partFile = File(partPath);
//     if (await partFile.exists()) await partFile.delete();

//     String? lastError;
//     _cancelToken = CancelToken();

//     // Try each URL until success
//     for (int i = 0; i < urls.length; i++) {
//       final url = urls[i];
//       debugPrint('📡 Trying URL ${i + 1}/${urls.length}: $url');

//       try {
//         await _dio.download(
//           url,
//           partPath,
//           cancelToken: _cancelToken,
//           deleteOnError: true,
//           options: Options(
//             responseType: ResponseType.bytes,
//             followRedirects: true,
//             headers: {
//               'User-Agent': 'Mozilla/5.0 (Linux; Android 12) '
//                   'AppleWebKit/537.36 Chrome/124.0 Mobile Safari/537.36',
//               'Accept': 'application/pdf,*/*',
//               'Referer': 'https://www.quran-pdf.com/',
//             },
//           ),
//           onReceiveProgress: (received, total) {
//             if (total > 0) {
//               final progress = (received / total).clamp(0.0, 1.0);
              
//               // Log every 5 MB
//               if (received % (5 * 1024 * 1024) < 65536) {
//                 debugPrint('📊 Quran: ${(progress * 100).toStringAsFixed(1)}% '
//                     '(${(received / (1024 * 1024)).toStringAsFixed(1)} / '
//                     '${(total / (1024 * 1024)).toStringAsFixed(1)} MB)');
//               }
              
//               onProgress(progress);
//             } else {
//               // Unknown size - estimate based on typical 100 MB
//               final progress = (received / (100 * 1024 * 1024)).clamp(0.0, 0.99);
//               onProgress(progress);
//             }
//           },
//         );

//         // Verify downloaded file
//         if (!await partFile.exists()) {
//           lastError = 'File missing after download';
//           continue;
//         }

//         final size = await partFile.length();
//         debugPrint('📦 Downloaded size: ${size ~/ (1024 * 1024)} MB');

//         // Check minimum size (500 KB)
//         if (size < 500 * 1024) {
//           await partFile.delete();
//           lastError = 'Server returned invalid file (too small)';
//           continue;
//         }

//         // Verify it's a valid PDF
//         if (!await _isValidPdf(partFile)) {
//           await partFile.delete();
//           lastError = 'Downloaded file is not a valid PDF';
//           continue;
//         }

//         // Success! Rename .part to final file
//         await partFile.rename(savePath);
//         debugPrint('✅ Quran saved: ${size ~/ (1024 * 1024)} MB');

//         // Save metadata
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('quran_path_$langCode', savePath);
//         await prefs.setInt('quran_size_$langCode', size);
//         await prefs.setInt('quran_downloaded_at_$langCode', 
//             DateTime.now().millisecondsSinceEpoch);

//         onSuccess(savePath);
//         return;

//       } on DioException catch (e) {
//         if (await partFile.exists()) await partFile.delete();
//         lastError = _friendlyError(e);
//         debugPrint('❌ URL ${i + 1} failed: $lastError');
//       } catch (e) {
//         if (await partFile.exists()) await partFile.delete();
//         lastError = 'Error: $e';
//         debugPrint('❌ URL ${i + 1} error: $e');
//       }
//     }

//     // All URLs failed
//     onError(lastError ?? 'Download failed. Please check your internet and retry.');
//   }

//   String _friendlyError(DioException e) {
//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//         return 'Connection timed out. Please check your internet.';
//       case DioExceptionType.receiveTimeout:
//         return 'Download timed out. The file is very large - please use Wi-Fi.';
//       case DioExceptionType.connectionError:
//         return 'No internet connection. Please connect and retry.';
//       case DioExceptionType.badResponse:
//         return 'Server error (${e.response?.statusCode ?? "unknown"}).';
//       case DioExceptionType.cancel:
//         return 'Download cancelled.';
//       default:
//         return 'Network error: ${e.message ?? e.type.name}';
//     }
//   }

//   // ── Utility Methods ──────────────────────────────────────────────────────

//   /// Cancel active download
//   void cancelDownload() {
//     _cancelToken?.cancel('Cancelled by user');
//     debugPrint('⏹️ Quran download cancelled');
//   }

//   /// Delete cached Quran
//   Future<bool> deleteCached(String langCode) async {
//     try {
//       final path = await getCachedPath(langCode);
//       if (path == null) return false;
      
//       await File(path).delete();
      
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('quran_path_$langCode');
//       await prefs.remove('quran_size_$langCode');
//       await prefs.remove('quran_downloaded_at_$langCode');
      
//       debugPrint('🗑️ Deleted cached Quran: $langCode');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Error deleting cache: $e');
//       return false;
//     }
//   }

//   /// Get total size of all cached Qurans
//   Future<int> getTotalCachedSize() async {
//     try {
//       final dir = await _cacheDir();
//       int total = 0;
//       await for (final entity in dir.list()) {
//         if (entity is File && entity.path.endsWith('.pdf')) {
//           total += await entity.length();
//         }
//       }
//       return total;
//     } catch (_) {
//       return 0;
//     }
//   }

//   /// Clear all cached Qurans
//   Future<void> clearAllCache() async {
//     try {
//       final dir = await _cacheDir();
//       if (await dir.exists()) {
//         await dir.delete(recursive: true);
//       }
      
//       final prefs = await SharedPreferences.getInstance();
//       for (final key in prefs.getKeys().where((k) => k.startsWith('quran_'))) {
//         await prefs.remove(key);
//       }
      
//       debugPrint('🗑️ Cleared all Quran cache');
//     } catch (e) {
//       debugPrint('❌ Error clearing cache: $e');
//     }
//   }

//   /// Get download info for a language
//   Future<Map<String, dynamic>?> getDownloadInfo(String langCode) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final path = prefs.getString('quran_path_$langCode');
//       final size = prefs.getInt('quran_size_$langCode');
//       final timestamp = prefs.getInt('quran_downloaded_at_$langCode');
      
//       if (path == null || size == null) return null;
      
//       return {
//         'path': path,
//         'size': size,
//         'sizeMB': (size / (1024 * 1024)).toStringAsFixed(1),
//         'downloadedAt': timestamp != null 
//             ? DateTime.fromMillisecondsSinceEpoch(timestamp)
//             : null,
//       };
//     } catch (_) {
//       return null;
//     }
//   }
// }