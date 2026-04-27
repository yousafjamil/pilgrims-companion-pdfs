import 'package:equatable/equatable.dart';

abstract class QuranDownloadState extends Equatable {
  const QuranDownloadState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state - not checked yet
class QuranDownloadInitial extends QuranDownloadState {}

/// Checking if Quran is cached
class QuranDownloadChecking extends QuranDownloadState {}

/// Quran is available (cached)
class QuranDownloadAvailable extends QuranDownloadState {
  final String filePath;
  final String sizeMB;
  
  const QuranDownloadAvailable({
    required this.filePath,
    required this.sizeMB,
  });
  
  @override
  List<Object?> get props => [filePath, sizeMB];
}

/// Quran is downloading
class QuranDownloadInProgress extends QuranDownloadState {
  final double progress; // 0.0 to 1.0
  final String progressPercentage;
  
  const QuranDownloadInProgress({
    required this.progress,
    required this.progressPercentage,
  });
  
  @override
  List<Object?> get props => [progress, progressPercentage];
}

/// Quran download completed
class QuranDownloadCompleted extends QuranDownloadState {
  final String filePath;
  final String sizeMB;
  
  const QuranDownloadCompleted({
    required this.filePath,
    required this.sizeMB,
  });
  
  @override
  List<Object?> get props => [filePath, sizeMB];
}

/// Quran not available (needs download)
class QuranDownloadNotAvailable extends QuranDownloadState {}

/// Download failed
class QuranDownloadError extends QuranDownloadState {
  final String message;
  
  const QuranDownloadError(this.message);
  
  @override
  List<Object?> get props => [message];
}