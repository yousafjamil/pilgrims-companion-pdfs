import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/cubit/quran_download_cubit/quran_download_cubit.dart';
import '../../core/cubit/quran_download_cubit/quran_download_state.dart';
import '../../core/services/quran_downloader.dart';
import '../../core/services/storage_service.dart';
import '../screens/pdf_viewer_screen.dart';
import '../../app/app_constants.dart';

class QuranDownloadTile extends StatelessWidget {
  const QuranDownloadTile({super.key});

  @override
  Widget build(BuildContext context) {
    final languageCode = StorageService.instance.getLanguage() ?? 'en';

    return BlocProvider(
      create: (_) => QuranDownloadCubit(
        quranDownloader: QuranDownloader(),
        languageCode: languageCode,
      ),
      child: BlocBuilder<QuranDownloadCubit, QuranDownloadState>(
        builder: (context, state) {
          return GestureDetector(
            onTap: () => _handleTap(context, state, languageCode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: _getTileColor(context, state),
                borderRadius: BorderRadius.circular(20),
                border: _getTileBorder(context, state),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildTileContent(context, state),
            ),
          );
        },
      ),
    );
  }

  // ── Tile Content ─────────────────────────────────────────────────────────

  Widget _buildTileContent(BuildContext context, QuranDownloadState state) {
    if (state is QuranDownloadChecking || state is QuranDownloadInitial) {
      return _buildCheckingState(context);
    }

    if (state is QuranDownloadAvailable || state is QuranDownloadCompleted) {
      return _buildAvailableState(context, state);
    }

    if (state is QuranDownloadInProgress) {
      return _buildDownloadingState(context, state);
    }

    if (state is QuranDownloadNotAvailable) {
      return _buildNotAvailableState(context);
    }

    if (state is QuranDownloadError) {
      return _buildErrorState(context, state);
    }

    return _buildCheckingState(context);
  }

  // ── State Widgets ────────────────────────────────────────────────────────

  Widget _buildCheckingState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📖', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Quran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableState(
      BuildContext context, QuranDownloadState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Quran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: Colors.green.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Ready',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingState(
      BuildContext context, QuranDownloadInProgress state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 3,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    const Color(0xFFD4AF37),
                  ),
                ),
              ),
              const Text('📖', style: TextStyle(fontSize: 32)),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Quran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '${state.progressPercentage}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 4,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotAvailableState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.download_rounded, size: 12, color: Colors.orange),
                SizedBox(width: 4),
                Text(
                  'Tap to Download',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, QuranDownloadError state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📖', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Quran',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.refresh_rounded, size: 12, color: Colors.red),
                SizedBox(width: 4),
                Text(
                  'Tap to Retry',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tap Handler ──────────────────────────────────────────────────────────

  void _handleTap(BuildContext context, QuranDownloadState state,
      String languageCode) {
    if (state is QuranDownloadAvailable || state is QuranDownloadCompleted) {
      // Open PDF Viewer
      final filePath = state is QuranDownloadAvailable
          ? state.filePath
          : (state as QuranDownloadCompleted).filePath;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            section: AppConstants.contentSections.firstWhere(
              (s) => s.id == 'quran',
            ),
            customFilePath: filePath,
          ),
        ),
      );
      return;
    }

    if (state is QuranDownloadInProgress) {
      // Show progress dialog
      _showProgressDialog(context, state);
      return;
    }

    if (state is QuranDownloadNotAvailable ||
        state is QuranDownloadError) {
      // Start download
      context.read<QuranDownloadCubit>().startDownload();
      return;
    }
  }

  // ── Progress Dialog ──────────────────────────────────────────────────────

  void _showProgressDialog(
      BuildContext context, QuranDownloadInProgress state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('📖'),
            SizedBox(width: 8),
            Text('Quran Downloading'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'The Holy Quran is downloading in the background.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFD4AF37),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.progressPercentage} Complete',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can continue using other guides\nwhile Quran downloads.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue Exploring'),
          ),
        ],
      ),
    );
  }

  // ── Style Helpers ────────────────────────────────────────────────────────

  Color _getTileColor(BuildContext context, QuranDownloadState state) {
    if (state is QuranDownloadAvailable || state is QuranDownloadCompleted) {
      return Theme.of(context).cardTheme.color ?? Colors.white;
    }
    if (state is QuranDownloadInProgress) {
      return const Color(0xFFD4AF37).withOpacity(0.05);
    }
    if (state is QuranDownloadError) {
      return Colors.red.withOpacity(0.05);
    }
    return Theme.of(context).cardTheme.color ?? Colors.white;
  }

  Border? _getTileBorder(BuildContext context, QuranDownloadState state) {
    if (state is QuranDownloadInProgress) {
      return Border.all(
        color: const Color(0xFFD4AF37).withOpacity(0.5),
        width: 1.5,
      );
    }
    if (state is QuranDownloadError) {
      return Border.all(
        color: Colors.red.withOpacity(0.3),
        width: 1.5,
      );
    }
    return null;
  }
}