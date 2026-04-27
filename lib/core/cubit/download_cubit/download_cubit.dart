import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/download_service.dart';
import '../../services/storage_service.dart';
import '../../../data/models/download_progress_model.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadService downloadService;
  final StorageService storageService;

  DownloadCubit({
    required this.downloadService,
    required this.storageService,
  }) : super(DownloadInitial());

  Future<void> startDownload(String languageCode) async {
    try {
      emit(DownloadInProgress(
        const DownloadProgressModel(
          fileName: '',
          totalFiles: 9, // 9 files (excluding Quran)
          currentFileIndex: 0,
          progress: 0.0,
          bytesReceived: 0,
          totalBytes: 0,
          status: DownloadStatus.downloading,
        ),
      ));

      await downloadService.downloadLanguageContent(
        languageCode: languageCode,
        onProgress: (fileName, current, total, progress) {
          if (isClosed) return;
          emit(DownloadInProgress(
            DownloadProgressModel(
              fileName: fileName,
              totalFiles: total,
              currentFileIndex: current - 1,
              progress: progress,
              bytesReceived: 0,
              totalBytes: 0,
              status: DownloadStatus.downloading,
            ),
          ));
        },
        onComplete: () async {
          if (isClosed) return;
          // Mark content as downloaded
          await storageService.setContentDownloaded(languageCode, true);
          emit(DownloadCompleted(languageCode));
        },
        onError: (error) {
          if (isClosed) return;
          emit(DownloadError(error));
        },
      );
    } catch (e) {
      if (isClosed) return;
      emit(DownloadError(e.toString()));
    }
  }

  void pauseDownload() {
    if (state is DownloadInProgress) {
      final currentProgress = (state as DownloadInProgress).progress;
      downloadService.pauseDownload();
      emit(DownloadPaused(currentProgress));
    }
  }

  void resumeDownload(String languageCode) {
    startDownload(languageCode);
  }

  Future<void> retryDownload(String languageCode) async {
    emit(DownloadInitial());
    await Future.delayed(const Duration(milliseconds: 500));
    await startDownload(languageCode);
  }
}