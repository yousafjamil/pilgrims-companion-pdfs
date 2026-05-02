import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/quran_downloader.dart';
import 'quran_download_state.dart';

class QuranDownloadCubit extends Cubit<QuranDownloadState> {
  final QuranDownloader quranDownloader;
  final String languageCode;
  
  QuranDownloadCubit({
    required this.quranDownloader,
    required this.languageCode,
  }) : super(QuranDownloadInitial()) {
    _initialize();
  }

  /// Initialize - check if Quran is cached
  Future<void> _initialize() async {
    emit(QuranDownloadChecking());
    
    try {
      final cachedPath = await quranDownloader.getCachedPath(languageCode);
      
      if (cachedPath != null) {
        // Quran is already cached
        final info = await quranDownloader.getDownloadInfo(languageCode);
        emit(QuranDownloadAvailable(
          filePath: cachedPath,
          sizeMB: info?['sizeMB'] ?? 'Unknown',
        ));
        return;
      }
      
      // Check if download is already in progress
      if (quranDownloader.isDownloading(languageCode)) {
        final currentProgress = quranDownloader.getProgress(languageCode) ?? 0.0;
        emit(QuranDownloadInProgress(
          progress: currentProgress,
          progressPercentage: '${(currentProgress * 100).toStringAsFixed(0)}%',
        ));
        
        // Attach to existing download
        _attachToExistingDownload();
        return;
      }
      
      // Not cached and not downloading
      emit(QuranDownloadNotAvailable());
      
    } catch (e) {
      emit(QuranDownloadError(e.toString()));
    }
  }

  /// Attach to existing download (if any)
  void _attachToExistingDownload() {
    quranDownloader.addProgressListener(languageCode, (progress) {
      if (state is! QuranDownloadInProgress) return;
      
      emit(QuranDownloadInProgress(
        progress: progress,
        progressPercentage: '${(progress * 100).toStringAsFixed(0)}%',
      ));
    });
    
    quranDownloader.addCompleteListener(languageCode, (path) async {
      final info = await quranDownloader.getDownloadInfo(languageCode);
      emit(QuranDownloadCompleted(
        filePath: path,
        sizeMB: info?['sizeMB'] ?? 'Unknown',
      ));
    });
    
    quranDownloader.addErrorListener(languageCode, (error) {
      emit(QuranDownloadError(error));
    });
  }

  /// Start manual download (when user taps Download button)
  Future<void> startDownload() async {
    try {
      emit(const QuranDownloadInProgress(
        progress: 0.0,
        progressPercentage: '0%',
      ));
      
      await quranDownloader.downloadQuran(
        langCode: languageCode,
        onProgress: (progress) {
          emit(QuranDownloadInProgress(
            progress: progress,
            progressPercentage: '${(progress * 100).toStringAsFixed(0)}%',
          ));
        },
        onSuccess: (path) async {
          final info = await quranDownloader.getDownloadInfo(languageCode);
          emit(QuranDownloadCompleted(
            filePath: path,
            sizeMB: info?['sizeMB'] ?? 'Unknown',
          ));
        },
        onError: (error) {
          emit(QuranDownloadError(error));
        },
      );
    } catch (e) {
      emit(QuranDownloadError(e.toString()));
    }
  }

  /// Retry download after error
  Future<void> retryDownload() async {
    await startDownload();
  }

  /// Refresh state (check cache again)
  Future<void> refresh() async {
    await _initialize();
  }

  /// Delete cached Quran
  Future<void> deleteCached() async {
    try {
      final success = await quranDownloader.deleteCached(languageCode);
      if (success) {
        emit(QuranDownloadNotAvailable());
      }
    } catch (e) {
      emit(QuranDownloadError('Failed to delete: $e'));
    }
  }

  @override
  Future<void> close() {
    quranDownloader.removeListeners(languageCode);
    return super.close();
  }
}