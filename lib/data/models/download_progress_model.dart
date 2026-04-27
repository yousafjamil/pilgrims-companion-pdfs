import 'package:equatable/equatable.dart';

enum DownloadStatus {
  idle,
  downloading,
  paused,
  completed,
  error,
}

class DownloadProgressModel extends Equatable {
  final String fileName;
  final int totalFiles;
  final int currentFileIndex;
  final double progress;
  final int bytesReceived;
  final int totalBytes;
  final DownloadStatus status;
  final String? errorMessage;

  const DownloadProgressModel({
    required this.fileName,
    required this.totalFiles,
    required this.currentFileIndex,
    required this.progress,
    required this.bytesReceived,
    required this.totalBytes,
    required this.status,
    this.errorMessage,
  });

  // Overall progress across all files
  double get overallProgress {
    if (totalFiles == 0) return 0.0;
    return (currentFileIndex + progress) / totalFiles;
  }

  // Current file percentage
  String get progressPercentage {
    return '${(progress * 100).toStringAsFixed(0)}%';
  }

  // Overall percentage
  String get overallProgressPercentage {
    return '${(overallProgress * 100).toStringAsFixed(0)}%';
  }

  DownloadProgressModel copyWith({
    String? fileName,
    int? totalFiles,
    int? currentFileIndex,
    double? progress,
    int? bytesReceived,
    int? totalBytes,
    DownloadStatus? status,
    String? errorMessage,
  }) {
    return DownloadProgressModel(
      fileName: fileName ?? this.fileName,
      totalFiles: totalFiles ?? this.totalFiles,
      currentFileIndex: currentFileIndex ?? this.currentFileIndex,
      progress: progress ?? this.progress,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        fileName,
        totalFiles,
        currentFileIndex,
        progress,
        bytesReceived,
        totalBytes,
        status,
        errorMessage,
      ];
}