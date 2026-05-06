import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/risala_pdf_service.dart';
import '../../core/services/storage_service.dart';
import '../../app/app_constants.dart';
import 'package:pdfx/pdfx.dart';

// ── A lightweight ContentSection wrapper so we can reuse PdfViewerScreen ──

class _RisalaSection {
  final String id;
  final String titleKey;
  final String icon;
  final String fileName;
  final String localPath;

  const _RisalaSection({
    required this.id,
    required this.titleKey,
    required this.icon,
    required this.fileName,
    required this.localPath,
  });
}

// ── Risala Library Screen ──────────────────────────────────────────────────

class RisalaLibraryScreen extends StatefulWidget {
  const RisalaLibraryScreen({super.key});

  @override
  State<RisalaLibraryScreen> createState() =>
      _RisalaLibraryScreenState();
}

class _RisalaLibraryScreenState
    extends State<RisalaLibraryScreen> {
  final RisalaPdfService _service = RisalaPdfService();

  String _languageCode = 'en';
  bool _isLoading = true;
  bool _hasError = false;
  List<RisalaCategory> _categories = [];

  // Track download state per PDF id
  final Map<String, double> _downloadProgress = {};
  final Map<String, bool> _downloadedMap = {};

  @override
  void initState() {
    super.initState();
    _languageCode =
        StorageService.instance.getLanguage() ?? 'en';
    _loadPdfs();
  }

  Future<void> _loadPdfs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final pdfs =
          await _service.fetchPdfs(_languageCode);
      final categories = _service.groupByCategory(
        pdfs,
        _languageCode,
      );

      // Check which are already downloaded
      for (final cat in categories) {
        for (final pdf in cat.pdfs) {
          _downloadedMap[pdf.id] =
              await _service.isPdfDownloaded(pdf);
        }
      }

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // ── Download a single PDF ──────────────────────────────────────────────

  Future<void> _downloadPdf(RisalaPdf pdf) async {
    if (_downloadProgress.containsKey(pdf.id)) return;

    HapticFeedback.lightImpact();

    setState(() {
      _downloadProgress[pdf.id] = 0.0;
    });

    final path = await _service.downloadPdf(
      pdf: pdf,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[pdf.id] = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _downloadProgress.remove(pdf.id);
        _downloadedMap[pdf.id] = path != null;
      });

      if (path != null) {
        _showSnackBar(
          '✅ Downloaded successfully!',
          isSuccess: true,
        );
      } else {
        _showSnackBar(
          '❌ Download failed. Check internet.',
          isSuccess: false,
        );
      }
    }
  }

  // ── Open a downloaded PDF ──────────────────────────────────────────────

  Future<void> _openPdf(RisalaPdf pdf) async {
    final path = await _service.getLocalPath(pdf);
    if (path == null) {
      _showSnackBar(
        'File not found. Please download first.',
        isSuccess: false,
      );
      return;
    }

    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _RisalaPdfViewer(
          title: pdf.title,
          icon: _getCategoryIcon(pdf.category),
          filePath: path,
        ),
      ),
    );
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

  void _showSnackBar(
    String message, {
    bool isSuccess = true,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess
              ? Colors.green.shade700
              : Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📜', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Islamic Guides'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () {
              _service.clearCache(_languageCode);
              _loadPdfs();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Islamic guides...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Could not load guides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your internet connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdfs,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📚',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'No guides available for this language yet.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        bottom: 24,
        top: 8,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        return _buildCategorySection(
          _categories[index],
        );
      },
    );
  }

  Widget _buildCategorySection(
    RisalaCategory category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            10,
          ),
          child: Row(
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Text(
                  '${category.pdfs.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // PDF list
        ...category.pdfs.map(
          (pdf) => _buildPdfTile(pdf),
        ),
      ],
    );
  }

  Widget _buildPdfTile(RisalaPdf pdf) {
    final isDownloaded =
        _downloadedMap[pdf.id] ?? false;
    final progress = _downloadProgress[pdf.id];
    final isDownloading = progress != null;
    final color =
        Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDownloaded
            ? color.withOpacity(0.05)
            : Theme.of(context)
                .cardTheme
                .color
                ?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDownloaded
              ? color.withOpacity(0.25)
              : Colors.grey.withOpacity(0.15),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getCategoryIcon(pdf.category),
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            title: Text(
              pdf.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                isDownloaded
                    ? '✅ Downloaded • Tap to read'
                    : isDownloading
                        ? 'Downloading...'
                        : '📥 Tap to download',
                style: TextStyle(
                  fontSize: 12,
                  color: isDownloaded
                      ? Colors.green
                      : isDownloading
                          ? color
                          : Colors.grey,
                ),
              ),
            ),
            trailing: isDownloading
                ? SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          color: color,
                        ),
                        Center(
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight:
                                  FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : isDownloaded
                    ? Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons
                                  .menu_book_rounded,
                              color: color,
                              size: 22,
                            ),
                            tooltip: 'Read',
                            onPressed: () =>
                                _openPdf(pdf),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: Icon(
                          Icons
                              .download_rounded,
                          color: color,
                          size: 22,
                        ),
                        tooltip: 'Download',
                        onPressed: () =>
                            _downloadPdf(pdf),
                      ),
            onTap: isDownloaded
                ? () => _openPdf(pdf)
                : isDownloading
                    ? null
                    : () => _downloadPdf(pdf),
          ),

          // Progress bar during download
          if (isDownloading)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                10,
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor:
                      Colors.grey.shade200,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(
                    color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Simple PDF Viewer for Risala PDFs ─────────────────────────────────────

class _RisalaPdfViewer extends StatefulWidget {
  final String title;
  final String icon;
  final String filePath;

  const _RisalaPdfViewer({
    required this.title,
    required this.icon,
    required this.filePath,
  });

  @override
  State<_RisalaPdfViewer> createState() =>
      _RisalaPdfViewerState();
}

class _RisalaPdfViewerState
    extends State<_RisalaPdfViewer> {
  PdfControllerPinch? _controller;
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final file = File(widget.filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found.');
      }

      final doc = PdfDocument.openFile(
        widget.filePath,
      );

      setState(() {
        _controller = PdfControllerPinch(
          document: doc,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.grey.shade900,
              foregroundColor: Colors.white,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.icon,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.title,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          _buildBody(),
          if (_controller != null &&
              _totalPages > 0)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black
                      .withOpacity(0.7),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_controller != null && _showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(context),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade900,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Text(
            _error!,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (_controller == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () =>
          setState(() => _showControls = !_showControls),
      child: PdfViewPinch(
        controller: _controller!,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          if (_totalPages == 0 &&
              _controller != null) {
            Future.microtask(() async {
              final count =
                  await _controller?.pagesCount;
              if (mounted && count != null) {
                setState(() => _totalPages = count);
              }
            });
          }
        },
        builders: PdfViewPinchBuilders<
            DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
          pageLoaderBuilder: (_) => Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            ),
          ),
          errorBuilder: (_, error) => Center(
            child: Text(
              'Error: $error',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      color: Colors.grey.shade900.withOpacity(0.95),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Row(
        children: [
          _navButton(
            Icons.first_page_rounded,
            _currentPage > 1
                ? () => _controller?.jumpToPage(1)
                : null,
          ),
          const SizedBox(width: 8),
          _navButton(
            Icons.chevron_left_rounded,
            _currentPage > 1
                ? () => _controller?.previousPage(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      curve: Curves.easeInOut,
                    )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color:
                    Colors.white.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _totalPages > 0
                      ? 'Page $_currentPage of $_totalPages'
                      : 'Page $_currentPage',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _navButton(
            Icons.chevron_right_rounded,
            _currentPage < _totalPages
                ? () => _controller?.nextPage(
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      curve: Curves.easeInOut,
                    )
                : null,
          ),
          const SizedBox(width: 8),
          _navButton(
            Icons.last_page_rounded,
            _currentPage < _totalPages
                ? () => _controller
                    ?.jumpToPage(_totalPages)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _navButton(
    IconData icon,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: Colors.white.withOpacity(
          onPressed != null ? 0.15 : 0.05,
        ),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 22,
            color: onPressed != null
                ? Colors.white
                : Colors.white24,
          ),
        ),
      ),
    );
  }
}