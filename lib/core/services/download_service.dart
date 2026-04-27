import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../app/app_constants.dart';

class DownloadService {
  final Dio _dio;
  CancelToken? _cancelToken;
  
  DownloadService() : _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(minutes: 5),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(minutes: 5),
      followRedirects: true,
      maxRedirects: 10,
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  // ── Directory Helpers ────────────────────────────────────────────────────

  Future<String> getAppDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final appDir = Directory('${directory.path}/pilgrim_app');
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir.path;
  }

  Future<String> getPdfsDirectory(String languageCode) async {
    final appDir = await getAppDirectory();
    final pdfsDir = Directory('$appDir/pdfs/$languageCode');
    
    if (!await pdfsDir.exists()) {
      await pdfsDir.create(recursive: true);
    }
    
    return pdfsDir.path;
  }

  // ── PDF Validation ───────────────────────────────────────────────────────

  Future<bool> _isValidPdf(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      
      final size = await file.length();
      if (size < 1024) return false;

      // Check PDF magic bytes
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

  // ── Download Single File ─────────────────────────────────────────────────

  Future<void> downloadFile({
    required String url,
    required String savePath,
    required Function(int received, int total) onProgress,
  }) async {
    _cancelToken = CancelToken();
    final partPath = '$savePath.part';
    final partFile = File(partPath);
    
    // Clean up partial file
    if (await partFile.exists()) await partFile.delete();

    try {
      print('📥 Downloading: $url');
      
      await _dio.download(
        url,
        partPath,
        cancelToken: _cancelToken,
        deleteOnError: true,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 12) '
                'AppleWebKit/537.36 Chrome/124.0 Mobile Safari/537.36',
            'Accept': 'application/octet-stream,application/pdf,*/*',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total > 0) {
            if (received % (2 * 1024 * 1024) < 65536) {
              print('📊 ${(received / total * 100).toStringAsFixed(1)}% '
                  '(${(received / (1024 * 1024)).toStringAsFixed(1)} / '
                  '${(total / (1024 * 1024)).toStringAsFixed(1)} MB)');
            }
          }
          onProgress(received, total);
        },
      );

      // Verify PDF
      if (!await _isValidPdf(partPath)) {
        await partFile.delete();
        throw Exception('Downloaded file is not a valid PDF');
      }

      // Rename to final path
      await partFile.rename(savePath);
      final size = await File(savePath).length();
      print('✅ Complete: ${(size / (1024 * 1024)).toStringAsFixed(2)} MB');

    } on DioException catch (e) {
      if (await partFile.exists()) await partFile.delete();
      
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Download cancelled');
      }
      if (e.response?.statusCode == 404) {
        throw Exception('File not found (404)');
      }
      throw Exception('Download failed: ${e.message}');
    } catch (e) {
      if (await partFile.exists()) await partFile.delete();
      rethrow;
    }
  }

  // ── Download Language Content (EXCLUDING QURAN) ──────────────────────────

  Future<void> downloadLanguageContent({
    required String languageCode,
    required Function(String fileName, int current, int total, double progress) onProgress,
    required Function() onComplete,
    required Function(String error) onError,
  }) async {
    try {
      final pdfsDir = await getPdfsDirectory(languageCode);
      
      // Filter out Quran section - it's handled by QuranDownloader
      final sections = AppConstants.contentSections
          .where((s) => s.id != 'quran')
          .toList();
      
      final totalFiles = sections.length;
      print('📦 Downloading $totalFiles files (excluding Quran)');

      for (int i = 0; i < totalFiles; i++) {
        final section = sections[i];
        final fileName = '${section.fileName}_$languageCode.pdf';
        final url = section.getDownloadUrl(languageCode);
        final savePath = '$pdfsDir/$fileName';

        print('\n📄 [${i + 1}/$totalFiles] $fileName');

        // Skip if valid file exists
        if (await _isValidPdf(savePath)) {
          final size = await File(savePath).length();
          print('✅ Already exists (${(size / (1024 * 1024)).toStringAsFixed(1)} MB)');
          onProgress(fileName, i + 1, totalFiles, 1.0);
          continue;
        }

        // Delete corrupt file
        final existing = File(savePath);
        if (await existing.exists()) {
          print('🗑️ Deleting corrupt file');
          await existing.delete();
        }

        // Download
        try {
          await downloadFile(
            url: url,
            savePath: savePath,
            onProgress: (received, total) {
              final progress = total > 0 ? received / total : 0.0;
              onProgress(fileName, i + 1, totalFiles, progress);
            },
          );
        } catch (e) {
          print('❌ Failed: $fileName - $e');
          onError('Failed to download "$fileName":\n$e');
          return;
        }
      }

      print('\n🎉 All files downloaded!');
      onComplete();
    } catch (e) {
      print('❌ Error: $e');
      onError(e.toString());
    }
  }

  // ── Controls ─────────────────────────────────────────────────────────────

  void pauseDownload() {
    _cancelToken?.cancel('Download paused');
  }

  // ── Status Methods ───────────────────────────────────────────────────────

  Future<bool> isLanguageContentDownloaded(String languageCode) async {
    try {
      final pdfsDir = await getPdfsDirectory(languageCode);
      
      // Check all sections EXCEPT Quran
      for (final section in AppConstants.contentSections) {
        if (section.id == 'quran') continue; // Skip Quran
        
        final path = '$pdfsDir/${section.fileName}_$languageCode.pdf';
        if (!await _isValidPdf(path)) return false;
      }
      
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> getDownloadedSize(String languageCode) async {
    try {
      final pdfsDir = await getPdfsDirectory(languageCode);
      final dir = Directory(pdfsDir);
      
      if (!await dir.exists()) return '0 MB';
      
      int total = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      
      return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '0 MB';
    }
  }

  Future<void> deleteLanguageContent(String languageCode) async {
    try {
      final pdfsDir = await getPdfsDirectory(languageCode);
      final dir = Directory(pdfsDir);
      
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
      
      print('🗑️ Deleted content: $languageCode');
    } catch (e) {
      throw Exception('Failed to delete: $e');
    }
  }
}

// // lib/core/services/download_service.dart
// // FIXED for large GitHub-hosted PDFs:
// // - GitHub raw URLs redirect to CDN — must follow redirects
// // - Single streaming download (no chunking) — GitHub doesn't support Range headers on raw files
// // - Correct timeouts for large files
// // - Magic-byte PDF verification
// // - Resume detection (skip already-complete files)

// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:path_provider/path_provider.dart';
// import '../../app/app_constants.dart';

// class DownloadService {
//   // Singleton — one instance, one Dio, downloads survive navigation
//   static final DownloadService _instance = DownloadService._internal();
//   factory DownloadService() => _instance;
//   DownloadService._internal();

//   late final Dio _dio = Dio(
//     BaseOptions(
//       // GitHub CDN is fast but large files need generous timeouts
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(minutes: 30), // up to 500 MB
//       sendTimeout: const Duration(seconds: 30),
//       followRedirects: true,   // REQUIRED — GitHub raw URLs redirect to CDN
//       maxRedirects: 10,
//       validateStatus: (s) => s != null && s < 500,
//     ),
//   );

//   CancelToken? _cancelToken;

//   // ── Directory helpers ───────────────────────────────────────────────────────

//   Future<String> getAppDirectory() async {
//     final base = await getApplicationDocumentsDirectory();
//     final dir = Directory('${base.path}/pilgrim_app');
//     if (!await dir.exists()) await dir.create(recursive: true);
//     return dir.path;
//   }

//   Future<String> getPdfsDirectory(String languageCode) async {
//     final appDir = await getAppDirectory();
//     final dir = Directory('$appDir/pdfs/$languageCode');
//     if (!await dir.exists()) await dir.create(recursive: true);
//     return dir.path;
//   }

//   // ── PDF validation ──────────────────────────────────────────────────────────

//   Future<bool> _isValidPdf(String path) async {
//     try {
//       final file = File(path);
//       if (!await file.exists()) return false;
//       if (await file.length() < 1024) return false; // too small

//       // Check %PDF magic bytes
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

//   // ── Core download ───────────────────────────────────────────────────────────
//   //
//   // WHY no chunking for GitHub:
//   // GitHub's raw CDN (objects.githubusercontent.com) does NOT support
//   // Range headers on most files — it returns the full file regardless,
//   // which breaks chunk reassembly. Use a single streaming download instead.
//   //
//   Future<void> downloadFile({
//     required String url,
//     required String savePath,
//     required void Function(int received, int total) onProgress,
//   }) async {
//     _cancelToken = CancelToken();
//     final file = File(savePath);
//     final partPath = '$savePath.part'; // write to .part, rename when done

//     // Clean up any previous partial file
//     final partFile = File(partPath);
//     if (await partFile.exists()) await partFile.delete();

//     try {
//       print('📥 Downloading: $url');
//       print('💾 Save path: $savePath');

//       await _dio.download(
//         url,
//         partPath,
//         cancelToken: _cancelToken,
//         deleteOnError: true, // Dio cleans up .part on failure
//         options: Options(
//           responseType: ResponseType.bytes,
//           followRedirects: true,
//           headers: {
//             // Required for GitHub to serve raw bytes instead of HTML
//             'User-Agent': 'Mozilla/5.0 (Linux; Android 12) '
//                 'AppleWebKit/537.36 Chrome/124.0 Mobile Safari/537.36',
//             'Accept': 'application/octet-stream,application/pdf,*/*',
//           },
//         ),
//         onReceiveProgress: (received, total) {
//           if (total > 0) {
//             final pct = (received / total * 100).toStringAsFixed(1);
//             if (received % (5 * 1024 * 1024) < 65536) {
//               print('📊 ${pct}% '
//                   '(${(received / (1024 * 1024)).toStringAsFixed(1)} / '
//                   '${(total / (1024 * 1024)).toStringAsFixed(1)} MB)');
//             }
//           }
//           onProgress(received, total);
//         },
//       );

//       // Verify the downloaded file is actually a PDF
//       if (!await _isValidPdf(partPath)) {
//         await partFile.delete();
//         throw Exception(
//             'Downloaded file is not a valid PDF. '
//             'Check the GitHub URL is a raw file link, not an HTML page.');
//       }

//       // Atomic rename: .part → final path
//       await partFile.rename(savePath);
//       final finalSize = await file.length();
//       print('✅ Download complete: ${(finalSize / (1024 * 1024)).toStringAsFixed(2)} MB');

//     } on DioException catch (e) {
//       if (await partFile.exists()) await partFile.delete();

//       if (e.type == DioExceptionType.cancel) {
//         throw Exception('Download cancelled');
//       }
//       if (e.response?.statusCode == 404) {
//         throw Exception(
//             'File not found (404). Make sure the GitHub URL uses '
//             'raw.githubusercontent.com, not github.com.');
//       }
//       if (e.type == DioExceptionType.receiveTimeout) {
//         throw Exception(
//             'Download timed out. The file may be too large for your '
//             'current connection speed. Please try again on Wi-Fi.');
//       }
//       if (e.type == DioExceptionType.connectionError) {
//         throw Exception('No internet connection. Please connect and retry.');
//       }
//       throw Exception('Download failed: ${e.message ?? e.type.name}');
//     } catch (e) {
//       if (await partFile.exists()) await partFile.delete();
//       rethrow;
//     }
//   }

//   // ── GitHub URL helper ───────────────────────────────────────────────────────
//   // Converts a regular GitHub file URL to the raw CDN URL automatically.
//   // Example:
//   //   https://github.com/user/repo/blob/main/file.pdf
//   //   → https://raw.githubusercontent.com/user/repo/main/file.pdf
//   static String toRawGitHubUrl(String githubUrl) {
//     return githubUrl
//         .replaceFirst('github.com', 'raw.githubusercontent.com')
//         .replaceFirst('/blob/', '/');
//   }

//   // ── Batch download (all sections for a language) ────────────────────────────

//   Future<void> downloadLanguageContent({
//     required String languageCode,
//     required void Function(
//             String fileName, int current, int total, double progress)
//         onProgress,
//     required void Function() onComplete,
//     required void Function(String error) onError,
//   }) async {
//     try {
//       final pdfsDir = await getPdfsDirectory(languageCode);
//       final sections = AppConstants.contentSections;
//       final totalFiles = sections.length;

//       for (int i = 0; i < totalFiles; i++) {
//         final section = sections[i];
//         final fileName = '${section.fileName}_$languageCode.pdf';
//         final savePath = '$pdfsDir/$fileName';

//         print('\n📄 [${ i + 1}/$totalFiles] $fileName');

//         // Skip if already valid
//         if (await _isValidPdf(savePath)) {
//           final size = await File(savePath).length();
//           print('✅ Already downloaded (${(size / (1024 * 1024)).toStringAsFixed(1)} MB)');
//           onProgress(fileName, i + 1, totalFiles, 1.0);
//           continue;
//         }

//         // Delete any corrupt existing file
//         final existing = File(savePath);
//         if (await existing.exists()) {
//           print('🗑️ Deleting corrupt/incomplete file');
//           await existing.delete();
//         }

//         // Get the download URL — convert github.com URLs automatically
//         String url = section.getDownloadUrl(languageCode);
//         if (url.contains('github.com') && url.contains('/blob/')) {
//           url = toRawGitHubUrl(url);
//           print('🔗 Converted to raw URL: $url');
//         }

//         try {
//           await downloadFile(
//             url: url,
//             savePath: savePath,
//             onProgress: (received, total) {
//               final progress = total > 0 ? received / total : 0.0;
//               onProgress(fileName, i + 1, totalFiles, progress);
//             },
//           );
//         } catch (e) {
//           print('❌ Failed: $fileName — $e');
//           onError('Failed to download "$fileName":\n$e');
//           return; // stop batch on first failure
//         }
//       }

//       print('\n🎉 All files downloaded successfully!');
//       onComplete();
//     } catch (e) {
//       print('❌ Batch error: $e');
//       onError(e.toString());
//     }
//   }

//   // ── Controls ────────────────────────────────────────────────────────────────

//   void cancelDownload() {
//     _cancelToken?.cancel('Cancelled by user');
//     print('⏹️ Download cancelled');
//   }

//   // kept for API compatibility
//   void pauseDownload() => cancelDownload();

//   // ── Status helpers ──────────────────────────────────────────────────────────

//   Future<bool> isLanguageContentDownloaded(String languageCode) async {
//     try {
//       final pdfsDir = await getPdfsDirectory(languageCode);
//       for (final section in AppConstants.contentSections) {
//         final path = '$pdfsDir/${section.fileName}_$languageCode.pdf';
//         if (!await _isValidPdf(path)) return false;
//       }
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }

//   Future<String> getDownloadedSize(String languageCode) async {
//     try {
//       final pdfsDir = await getPdfsDirectory(languageCode);
//       final dir = Directory(pdfsDir);
//       if (!await dir.exists()) return '0 MB';
//       int total = 0;
//       await for (final e in dir.list(recursive: true)) {
//         if (e is File) total += await e.length();
//       }
//       return '${(total / (1024 * 1024)).toStringAsFixed(1)} MB';
//     } catch (_) {
//       return '0 MB';
//     }
//   }

//   Future<void> deleteLanguageContent(String languageCode) async {
//     try {
//       final pdfsDir = await getPdfsDirectory(languageCode);
//       final dir = Directory(pdfsDir);
//       if (await dir.exists()) await dir.delete(recursive: true);
//       print('🗑️ Deleted content for: $languageCode');
//     } catch (e) {
//       throw Exception('Failed to delete: $e');
//     }
//   }
// }

// // import 'dart:io';
// // import 'package:dio/dio.dart';
// // import 'package:path_provider/path_provider.dart';
// // import '../../app/app_constants.dart';

// // class DownloadService {
// //   final Dio _dio;
// //   CancelToken? _cancelToken;
  
// //   DownloadService() : _dio = Dio(
// //     BaseOptions(
// //       connectTimeout: const Duration(minutes: 10), // For large files
// //       receiveTimeout: const Duration(minutes: 10),
// //       sendTimeout: const Duration(minutes: 10),
// //     ),
// //   );
  
// //   Future<String> getAppDirectory() async {
// //     final directory = await getApplicationDocumentsDirectory();
// //     final appDir = Directory('${directory.path}/pilgrim_app');
    
// //     if (!await appDir.exists()) {
// //       await appDir.create(recursive: true);
// //     }
    
// //     return appDir.path;
// //   }
  
// //   Future<String> getPdfsDirectory(String languageCode) async {
// //     final appDir = await getAppDirectory();
// //     final pdfsDir = Directory('$appDir/pdfs/$languageCode');
    
// //     if (!await pdfsDir.exists()) {
// //       await pdfsDir.create(recursive: true);
// //     }
    
// //     return pdfsDir.path;
// //   }
  
// //   // CHUNKED DOWNLOAD for large files
// //   Future<void> downloadFileWithChunks({
// //     required String url,
// //     required String savePath,
// //     required Function(int received, int total) onProgress,
// //     int chunkSize = 1024 * 1024, // 1 MB chunks
// //   }) async {
// //     try {
// //       _cancelToken = CancelToken();
      
// //       // Get file size first
// //       final response = await _dio.head(url);
// //       final totalSize = int.parse(response.headers.value('content-length') ?? '0');
      
// //       print('📊 Total file size: ${totalSize / 1024 / 1024} MB');
      
// //       // Check if file already partially downloaded
// //       final file = File(savePath);
// //       int downloadedBytes = 0;
      
// //       if (await file.exists()) {
// //         downloadedBytes = await file.length();
// //         print('📂 Resuming from ${downloadedBytes / 1024 / 1024} MB');
// //       }
      
// //       // Download in chunks
// //       final randomAccessFile = await file.open(mode: FileMode.append);
      
// //       try {
// //         while (downloadedBytes < totalSize) {
// //           final start = downloadedBytes;
// //           final end = (downloadedBytes + chunkSize - 1 < totalSize) 
// //               ? downloadedBytes + chunkSize - 1 
// //               : totalSize - 1;
          
// //           print('📥 Downloading chunk: $start - $end');
          
// //           final chunkResponse = await _dio.get<List<int>>(
// //             url,
// //             options: Options(
// //               headers: {'Range': 'bytes=$start-$end'},
// //               responseType: ResponseType.bytes,
// //             ),
// //             cancelToken: _cancelToken,
// //           );
          
// //           if (chunkResponse.data != null) {
// //             await randomAccessFile.writeFrom(chunkResponse.data!);
// //             downloadedBytes += chunkResponse.data!.length;
// //             onProgress(downloadedBytes, totalSize);
// //           }
// //         }
        
// //         print('✅ Download complete!');
// //       } finally {
// //         await randomAccessFile.close();
// //       }
      
// //       // Verify file integrity
// //       final finalSize = await file.length();
// //       if (finalSize != totalSize) {
// //         await file.delete();
// //         throw Exception('File size mismatch. Expected $totalSize, got $finalSize');
// //       }
      
// //     } catch (e) {
// //       print('❌ Download error: $e');
      
// //       if (e is DioException) {
// //         if (e.type == DioExceptionType.cancel) {
// //           throw Exception('Download cancelled');
// //         }
// //         if (e.response?.statusCode == 404) {
// //           throw Exception('File not found (404)');
// //         }
// //         throw Exception('Download failed: ${e.message}');
// //       }
// //       rethrow;
// //     }
// //   }
  
// //   // STANDARD DOWNLOAD for small files
// //   Future<void> downloadFile({
// //     required String url,
// //     required String savePath,
// //     required Function(int received, int total) onProgress,
// //   }) async {
// //     _cancelToken = CancelToken();
    
// //     try {
// //       print('📥 Downloading: $url');
      
// //       await _dio.download(
// //         url,
// //         savePath,
// //         onReceiveProgress: (received, total) {
// //           onProgress(received, total);
// //         },
// //         cancelToken: _cancelToken,
// //         options: Options(
// //           responseType: ResponseType.bytes,
// //           followRedirects: true,
// //           validateStatus: (status) => status! < 500,
// //         ),
// //       );
      
// //       // Verify file
// //       final file = File(savePath);
// //       if (await file.exists()) {
// //         final size = await file.length();
// //         print('✅ Downloaded: ${size / 1024 / 1024} MB');
        
// //         if (size < 1000) {
// //           await file.delete();
// //           throw Exception('File too small (corrupt)');
// //         }
// //       }
      
// //     } catch (e) {
// //       print('❌ Error: $e');
      
// //       if (e is DioException && e.type == DioExceptionType.cancel) {
// //         throw Exception('Download cancelled');
// //       }
// //       rethrow;
// //     }
// //   }
  
// //   // SMART DOWNLOAD - chooses method based on file size
// //   Future<void> smartDownload({
// //     required String url,
// //     required String savePath,
// //     required Function(int received, int total) onProgress,
// //   }) async {
// //     try {
// //       // Check file size
// //       final response = await _dio.head(url);
// //       final fileSize = int.parse(response.headers.value('content-length') ?? '0');
      
// //       print('📊 File size: ${fileSize / 1024 / 1024} MB');
      
// //       // Use chunked download for files > 10 MB
// //       if (fileSize > 10 * 1024 * 1024) {
// //         print('📦 Using chunked download (large file)');
// //         await downloadFileWithChunks(
// //           url: url,
// //           savePath: savePath,
// //           onProgress: onProgress,
// //         );
// //       } else {
// //         print('📄 Using standard download (small file)');
// //         await downloadFile(
// //           url: url,
// //           savePath: savePath,
// //           onProgress: onProgress,
// //         );
// //       }
// //     } catch (e) {
// //       print('❌ Smart download failed: $e');
// //       rethrow;
// //     }
// //   }
  
// //   Future<void> downloadLanguageContent({
// //     required String languageCode,
// //     required Function(String fileName, int current, int total, double progress) onProgress,
// //     required Function() onComplete,
// //     required Function(String error) onError,
// //   }) async {
// //     try {
// //       final pdfsDir = await getPdfsDirectory(languageCode);
// //       final totalFiles = AppConstants.contentSections.length;
      
// //       for (int i = 0; i < totalFiles; i++) {
// //         final section = AppConstants.contentSections[i];
// //         final fileName = '${section.fileName}_$languageCode.pdf';
// //         final url = section.getDownloadUrl(languageCode);
// //         final savePath = '$pdfsDir/$fileName';
        
// //         print('📄 Processing: $fileName');
        
// //         // Check if file exists and is valid
// //         final file = File(savePath);
// //         if (await file.exists()) {
// //           final fileSize = await file.length();
          
// //           if (fileSize > 1000) {
// //             print('✅ Already downloaded: $fileName');
// //             onProgress(fileName, i + 1, totalFiles, 1.0);
// //             continue;
// //           } else {
// //             print('🗑️ Deleting corrupt file');
// //             await file.delete();
// //           }
// //         }
        
// //         // Download using smart method
// //         try {
// //           await smartDownload(
// //             url: url,
// //             savePath: savePath,
// //             onProgress: (received, total) {
// //               if (total != -1) {
// //                 final progress = received / total;
// //                 onProgress(fileName, i + 1, totalFiles, progress);
// //               }
// //             },
// //           );
// //         } catch (e) {
// //           print('❌ Failed: $fileName - $e');
// //           onError('Failed to download $fileName: $e');
// //           return;
// //         }
// //       }
      
// //       onComplete();
// //     } catch (e) {
// //       print('❌ Error: $e');
// //       onError(e.toString());
// //     }
// //   }
  
// //   void pauseDownload() {
// //     _cancelToken?.cancel('Download paused by user');
// //   }
  
// //   Future<void> deleteLanguageContent(String languageCode) async {
// //     try {
// //       final pdfsDir = await getPdfsDirectory(languageCode);
// //       final directory = Directory(pdfsDir);
      
// //       if (await directory.exists()) {
// //         await directory.delete(recursive: true);
// //       }
// //     } catch (e) {
// //       throw Exception('Failed to delete: $e');
// //     }
// //   }
  
// //   Future<bool> isLanguageContentDownloaded(String languageCode) async {
// //     try {
// //       final pdfsDir = await getPdfsDirectory(languageCode);
// //       final directory = Directory(pdfsDir);
      
// //       if (!await directory.exists()) {
// //         return false;
// //       }
      
// //       for (final section in AppConstants.contentSections) {
// //         final fileName = '${section.fileName}_$languageCode.pdf';
// //         final file = File('$pdfsDir/$fileName');
        
// //         if (!await file.exists()) {
// //           return false;
// //         }
        
// //         final fileSize = await file.length();
// //         if (fileSize < 1000) {
// //           return false;
// //         }
// //       }
      
// //       return true;
// //     } catch (e) {
// //       return false;
// //     }
// //   }
  
// //   Future<String> getDownloadedSize(String languageCode) async {
// //     try {
// //       final pdfsDir = await getPdfsDirectory(languageCode);
// //       final directory = Directory(pdfsDir);
      
// //       if (!await directory.exists()) {
// //         return '0 MB';
// //       }
      
// //       int totalBytes = 0;
// //       await for (final entity in directory.list(recursive: true)) {
// //         if (entity is File) {
// //           totalBytes += await entity.length();
// //         }
// //       }
      
// //       final totalMB = totalBytes / (1024 * 1024);
// //       return '${totalMB.toStringAsFixed(1)} MB';
// //     } catch (e) {
// //       return '0 MB';
// //     }
// //   }
// // }

// // // //////////////  for small  files 

// // // import 'dart:io';
// // // import 'package:dio/dio.dart';
// // // import 'package:path_provider/path_provider.dart';
// // // import '../../app/app_constants.dart';

// // // class DownloadService {
// // //   final Dio _dio;
// // //   CancelToken? _cancelToken;
  
// // //   DownloadService() : _dio = Dio(
// // //     BaseOptions(
// // //       connectTimeout: const Duration(seconds: 30),
// // //       receiveTimeout: const Duration(seconds: 30),
// // //     ),
// // //   );
  
// // //   // Get app documents directory
// // //   Future<String> getAppDirectory() async {
// // //     final directory = await getApplicationDocumentsDirectory();
// // //     final appDir = Directory('${directory.path}/pilgrim_app');
    
// // //     if (!await appDir.exists()) {
// // //       await appDir.create(recursive: true);
// // //     }
    
// // //     return appDir.path;
// // //   }
  

// // //   //   // Get total downloaded size
// // //   Future<String> getDownloadedSize(String languageCode) async {
// // //     try {
// // //       final pdfsDir = await getPdfsDirectory(languageCode);
// // //       final directory = Directory(pdfsDir);
      
// // //       if (!await directory.exists()) {
// // //         return '0 MB';
// // //       }
      
// // //       int totalBytes = 0;
// // //       await for (final entity in directory.list(recursive: true)) {
// // //         if (entity is File) {
// // //           totalBytes += await entity.length();
// // //         }
// // //       }
      
// // //       final totalMB = totalBytes / (1024 * 1024);
// // //       return '${totalMB.toStringAsFixed(1)} MB';
// // //     } catch (e) {
// // //       return '0 MB';
// // //     }
// // //   }
// // //   // Get PDFs directory for specific language
// // //   Future<String> getPdfsDirectory(String languageCode) async {
// // //     final appDir = await getAppDirectory();
// // //     final pdfsDir = Directory('$appDir/pdfs/$languageCode');
    
// // //     if (!await pdfsDir.exists()) {
// // //       await pdfsDir.create(recursive: true);
// // //     }
    
// // //     return pdfsDir.path;
// // //   }
  
// // //   // Download a single file
// // //   Future<void> downloadFile({
// // //     required String url,
// // //     required String savePath,
// // //     required Function(int received, int total) onProgress,
// // //   }) async {
// // //     _cancelToken = CancelToken();
    
// // //     try {
// // //       await _dio.download(
// // //         url,
// // //         savePath,
// // //         onReceiveProgress: onProgress,
// // //         cancelToken: _cancelToken,
// // //       );
// // //     } catch (e) {
// // //       if (e is DioException) {
// // //         if (e.type == DioExceptionType.cancel) {
// // //           throw Exception('Download cancelled');
// // //         }
// // //         throw Exception('Download failed: ${e.message}');
// // //       }
// // //       rethrow;
// // //     }
// // //   }
  
// // //   // Download all PDFs for a language
// // //   Future<void> downloadLanguageContent({
// // //     required String languageCode,
// // //     required Function(String fileName, int current, int total, double progress) onProgress,
// // //     required Function() onComplete,
// // //     required Function(String error) onError,
// // //   }) async {
// // //     try {
// // //       final pdfsDir = await getPdfsDirectory(languageCode);
// // //       final totalFiles = AppConstants.contentSections.length;
      
// // //       for (int i = 0; i < totalFiles; i++) {
// // //         final section = AppConstants.contentSections[i];
// // //         final fileName = '${section.fileName}_$languageCode.pdf';
// // //         final url = section.getDownloadUrl(languageCode);
// // //         final savePath = '$pdfsDir/$fileName';
        
// // //         // Check if file already exists
// // //         final file = File(savePath);
// // //         if (await file.exists()) {
// // //           // Skip already downloaded files
// // //           onProgress(fileName, i + 1, totalFiles, 1.0);
// // //           continue;
// // //         }
        
// // //         // Download file
// // //         await downloadFile(
// // //           url: url,
// // //           savePath: savePath,
// // //           onProgress: (received, total) {
// // //             if (total != -1) {
// // //               final progress = received / total;
// // //               onProgress(fileName, i + 1, totalFiles, progress);
// // //             }
// // //           },
// // //         );
// // //       }
      
// // //       onComplete();
// // //     } catch (e) {
// // //       onError(e.toString());
// // //     }
// // //   }
  
// // //   // Pause download
// // //   void pauseDownload() {
// // //     _cancelToken?.cancel('Download paused by user');
// // //   }
  
// // //   // Delete language content
// // //   Future<void> deleteLanguageContent(String languageCode) async {
// // //     try {
// // //       final pdfsDir = await getPdfsDirectory(languageCode);
// // //       final directory = Directory(pdfsDir);
      
// // //       if (await directory.exists()) {
// // //         await directory.delete(recursive: true);
// // //       }
// // //     } catch (e) {
// // //       throw Exception('Failed to delete content: $e');
// // //     }
// // //   }
  
// // //   // Check if language content exists
// // //   Future<bool> isLanguageContentDownloaded(String languageCode) async {
// // //     try {
// // //       final pdfsDir = await getPdfsDirectory(languageCode);
// // //       final directory = Directory(pdfsDir);
      
// // //       if (!await directory.exists()) {
// // //         return false;
// // //       }
      
// // //       // Check if all required PDFs exist
// // //       for (final section in AppConstants.contentSections) {
// // //         final fileName = '${section.fileName}_$languageCode.pdf';
// // //         final file = File('$pdfsDir/$fileName');
        
// // //         if (!await file.exists()) {
// // //           return false;
// // //         }
// // //       }
      
// // //       return true;
// // //     } catch (e) {
// // //       return false;
// // //     }
// // //   }
// // // }