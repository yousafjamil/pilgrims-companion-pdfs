import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/cubit/download_cubit/download_cubit.dart';
import '../../core/cubit/download_cubit/download_state.dart';
import '../../core/services/download_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/quran_downloader.dart';
import '../../data/models/download_progress_model.dart';
import 'onboarding_screen.dart';

class DownloadScreen extends StatefulWidget {
  final String languageCode;

  const DownloadScreen({
    super.key,
    required this.languageCode,
  });

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  // Quran background progress tracking
  double _quranProgress = 0.0;
  bool _quranComplete = false;
  bool _quranError = false;
  bool _quranStarted = false;

  @override
  void initState() {
    super.initState();

    // Setup fade animation
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));
    _animController.forward();

    // Listen to Quran background download
    _listenToQuranDownload();
  }

  void _listenToQuranDownload() {
    final downloader = QuranDownloader();

    // Check if already downloading
    final currentProgress =
        downloader.getProgress(widget.languageCode);
    if (currentProgress != null) {
      setState(() {
        _quranProgress = currentProgress;
        _quranStarted = true;
      });
    }

    // Add progress listener
    downloader.addProgressListener(widget.languageCode, (progress) {
      if (mounted) {
        setState(() {
          _quranProgress = progress;
          _quranStarted = true;
        });
      }
    });

    // Add complete listener
    downloader.addCompleteListener(widget.languageCode, (path) {
      if (mounted) {
        setState(() {
          _quranComplete = true;
          _quranProgress = 1.0;
        });
      }
    });

    // Add error listener
    downloader.addErrorListener(widget.languageCode, (error) {
      if (mounted) {
        setState(() {
          _quranError = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DownloadCubit(
        downloadService: DownloadService(),
        storageService: StorageService.instance,
      )..startDownload(widget.languageCode),
      child: WillPopScope(
        // Prevent back button during download
        onWillPop: () async {
          return await _showExitDialog(context);
        },
        child: Scaffold(
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocConsumer<DownloadCubit, DownloadState>(
                listener: (context, state) {
                  if (state is DownloadCompleted) {
                    // Small PDFs done → go to onboarding
                    Future.delayed(
                      const Duration(seconds: 1),
                      () {
                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const OnboardingScreen(),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // ── Top Section ──────────────────────────────
                        const Spacer(),

                        // App Icon
                        _buildAppIcon(context),

                        const SizedBox(height: 40),

                        // Title
                        _buildTitle(context, state),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          state is DownloadInProgress
                              ? 'Please keep the app open'
                              : state is DownloadCompleted
                                  ? 'All guides are ready!'
                                  : state is DownloadError
                                      ? 'Something went wrong'
                                      : 'Preparing download...',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium,
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Main Progress Section
                        if (state is DownloadInProgress ||
                            state is DownloadPaused)
                          _buildProgressSection(context, state),

                        // Error Section
                        if (state is DownloadError)
                          _buildErrorSection(context, state),

                        // Success Section
                        if (state is DownloadCompleted)
                          _buildSuccessSection(context),

                        const SizedBox(height: 24),

                        // Quran Background Status
                        _buildQuranStatus(context),

                        // ── Bottom Section ───────────────────────────
                        const Spacer(),

                        // Action Buttons
                        _buildActionButtons(context, state),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── App Icon ──────────────────────────────────────────────────────────

  Widget _buildAppIcon(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Center(
        child: Text('🕋', style: TextStyle(fontSize: 54)),
      ),
    );
  }

  // ── Title ─────────────────────────────────────────────────────────────

  Widget _buildTitle(BuildContext context, DownloadState state) {
    String title;

    if (state is DownloadInProgress) {
      title = 'Preparing Your Guides';
    } else if (state is DownloadPaused) {
      title = 'Download Paused';
    } else if (state is DownloadCompleted) {
      title = 'Guides Ready! ✅';
    } else if (state is DownloadError) {
      title = 'Download Failed';
    } else {
      title = 'Starting Download...';
    }

    return Text(
      title,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ── Progress Section ──────────────────────────────────────────────────

  Widget _buildProgressSection(
    BuildContext context,
    DownloadState state,
  ) {
    DownloadProgressModel? progress;

    if (state is DownloadInProgress) {
      progress = state.progress;
    } else if (state is DownloadPaused) {
      progress = state.progress;
    }

    if (progress == null) return const SizedBox();

    return Column(
      children: [
        // File Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.15),
            ),
          ),
          child: Column(
            children: [
              // File Counter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Downloading Guide',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${progress.currentFileIndex + 1}'
                      ' / ${progress.totalFiles}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Current File Name
              Text(
                progress.fileName.isNotEmpty
                    ? _formatFileName(progress.fileName)
                    : 'Preparing files...',
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Progress Bar Section
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  progress.overallProgressPercentage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Animated Progress Bar
            TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: progress.overallProgress,
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 14,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ── Error Section ─────────────────────────────────────────────────────

  Widget _buildErrorSection(
    BuildContext context,
    DownloadState state,
  ) {
    final error = state as DownloadError;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 56,
            color: Colors.red,
          ),
          const SizedBox(height: 12),
          Text(
            'Download Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Success Section ───────────────────────────────────────────────────

  Widget _buildSuccessSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 56,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          Text(
            'All Guides Downloaded!',
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Redirecting to app...',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  // ── Quran Background Status ───────────────────────────────────────────

  Widget _buildQuranStatus(BuildContext context) {
    // Quran not started yet
    if (!_quranStarted && !_quranComplete && !_quranError) {
      return _buildQuranCard(
        context,
        icon: '📖',
        title: 'Holy Quran',
        subtitle: 'Starting background download...',
        color: const Color(0xFFD4AF37),
        showSpinner: true,
      );
    }

    // Quran complete
    if (_quranComplete) {
      return _buildQuranCard(
        context,
        icon: '✅',
        title: 'Holy Quran Ready!',
        subtitle: 'Full Quran available offline',
        color: Colors.green,
        progress: 1.0,
      );
    }

    // Quran error
    if (_quranError) {
      return _buildQuranCard(
        context,
        icon: '⚠️',
        title: 'Quran Download Issue',
        subtitle: 'Will retry when you open Quran section',
        color: Colors.orange,
      );
    }

    // Quran downloading
    return _buildQuranCard(
      context,
      icon: '📖',
      title: 'Holy Quran',
      subtitle: 'Downloading silently in background',
      color: const Color(0xFFD4AF37),
      progress: _quranProgress,
      percentage:
          '${(_quranProgress * 100).toStringAsFixed(0)}%',
    );
  }

  Widget _buildQuranCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    double? progress,
    String? percentage,
    bool showSpinner = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Right side: percentage or spinner
              if (percentage != null)
                Text(
                  percentage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                )
              else if (showSpinner)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
            ],
          ),

          // Progress bar
          if (progress != null) ...[
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, _) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor:
                        Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      color,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // ── Action Buttons ────────────────────────────────────────────────────

  Widget _buildActionButtons(
    BuildContext context,
    DownloadState state,
  ) {
    if (state is DownloadInProgress) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton.icon(
          onPressed: () {
            context.read<DownloadCubit>().pauseDownload();
          },
          icon: const Icon(Icons.pause_rounded),
          label: const Text(
            'Pause Download',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (state is DownloadPaused) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            context
                .read<DownloadCubit>()
                .resumeDownload(widget.languageCode);
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'Resume Download',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    if (state is DownloadError) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                context
                    .read<DownloadCubit>()
                    .retryDownload(widget.languageCode);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Retry Download',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text(
                'Continue Without Guides',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  // ── Exit Dialog ───────────────────────────────────────────────────────

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('⚠️'),
            SizedBox(width: 8),
            Text('Cancel Download?'),
          ],
        ),
        content: const Text(
          'Download is in progress.\n\n'
          'If you exit now, you will need to '
          'download the guides again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Downloading'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Exit Anyway',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  String _formatFileName(String fileName) {
    return fileName
        .replaceAll('_', ' ')
        .replaceAll('.pdf', '')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}