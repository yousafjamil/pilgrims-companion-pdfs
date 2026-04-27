import 'package:equatable/equatable.dart';
import '../../../data/models/download_progress_model.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();

  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadInProgress extends DownloadState {
  final DownloadProgressModel progress;

  const DownloadInProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DownloadPaused extends DownloadState {
  final DownloadProgressModel progress;

  const DownloadPaused(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DownloadCompleted extends DownloadState {
  final String languageCode;

  const DownloadCompleted(this.languageCode);

  @override
  List<Object?> get props => [languageCode];
}

class DownloadError extends DownloadState {
  final String message;
  final DownloadProgressModel? progress;

  const DownloadError(this.message, {this.progress});

  @override
  List<Object?> get props => [message, progress];
}