
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pilgrims_companion/core/services/reading_progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_constants.dart';
import '../../core/services/download_service.dart';
import '../../core/services/storage_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final ContentSection section;
  final String? customFilePath;

  const PdfViewerScreen({
    super.key,
    required this.section,
    this.customFilePath,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen>
    with SingleTickerProviderStateMixin {
  // ── PDF Controller ─────────────────────────────────────────
  PdfControllerPinch? _pdfController;

  // ── State ──────────────────────────────────────────────────
// ── State ──────────────────────────────────────────────────
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _showControls = true;
  bool _isBookmarked = false;
  List<int> _bookmarkedPages = [];

  // ── Reading Progress ───────────────────────────────────────
  final ReadingProgressService _progressService =
      ReadingProgressService();
  int _savedPage = 1;

  // ── Animation ──────────────────────────────────────────────
  late AnimationController _controlsAnimController;
  late Animation<double> _controlsFadeAnimation;

  // ── Bookmark Key ───────────────────────────────────────────
  String get _bookmarkKey =>
      'bookmarks_${widget.section.id}';

  @override
  void initState() {
    super.initState();

    // Controls animation
    _controlsAnimController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _controlsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimController,
      curve: Curves.easeInOut,
    ));
    _controlsAnimController.forward();

    // Load PDF and bookmarks
  // Load PDF, bookmarks and progress
    _loadPdf();
    _loadBookmarks();
    _loadReadingProgress();
  }

  // ── Load PDF ──────────────────────────────────────────────

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Small delay for smooth transition
      await Future.delayed(const Duration(milliseconds: 100));
      String filePath;

      if (widget.customFilePath != null) {
        filePath = widget.customFilePath!;
      } else {
        final storageService = StorageService.instance;
        final languageCode =
            storageService.getLanguage() ?? 'en';
        final downloadService = DownloadService();
        final pdfsDir = await downloadService
            .getPdfsDirectory(languageCode);
        final fileName =
            '${widget.section.fileName}_$languageCode.pdf';
        filePath = '$pdfsDir/$fileName';
      }

      debugPrint('📄 Loading PDF: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception(
          'PDF file not found.\n'
          'Please re-download content from Settings.',
        );
      }

      final fileSize = await file.length();
      debugPrint(
        '📊 Size: '
        '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB',
      );

      // ✅ Pass Future directly - no await
      final document = PdfDocument.openFile(filePath);

      setState(() {
        _pdfController = PdfControllerPinch(
          document: document,
        );
        _isLoading = false;
      });

      debugPrint('✅ PDF loaded successfully');
    } catch (e) {
      debugPrint('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('PlatformException', 'Error');
      });
    }
  }


// ── Load Reading Progress ─────────────────────────────────
  Future<void> _loadReadingProgress() async {
    try {
      final progress = await _progressService.getProgress(
        widget.section.id,
      );
      if (progress != null && progress.currentPage > 1) {
        setState(() {
          _savedPage = progress.currentPage;
        });
        // Show resume dialog after PDF loads
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted && _pdfController != null) {
            _showResumeDialog(progress);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Load progress error: $e');
    }
  }

  // ── Show Resume Dialog ─────────────────────────────────────
  void _showResumeDialog(ReadingProgress progress) {
    if (!mounted) return;
    if (progress.currentPage <= 1) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('📖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text(
              'Resume Reading',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You left off at page ${progress.currentPage}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.progressPercentage,
                minHeight: 8,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.percentageText} completed',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Start from Beginning',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _pdfController?.jumpToPage(
                progress.currentPage,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Resume',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  // ── Bookmarks ─────────────────────────────────────────────

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_bookmarkKey) ?? [];
      setState(() {
        _bookmarkedPages =
            saved.map((e) => int.tryParse(e) ?? 0).toList();
        _isBookmarked =
            _bookmarkedPages.contains(_currentPage);
      });
    } catch (e) {
      debugPrint('❌ Load bookmarks error: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      HapticFeedback.mediumImpact();

      final prefs = await SharedPreferences.getInstance();

      setState(() {
        if (_bookmarkedPages.contains(_currentPage)) {
          _bookmarkedPages.remove(_currentPage);
          _isBookmarked = false;
          _showSnackBar(
            '🔖 Bookmark removed from page $_currentPage',
            isSuccess: false,
          );
        } else {
          _bookmarkedPages.add(_currentPage);
          _bookmarkedPages.sort();
          _isBookmarked = true;
          _showSnackBar(
            '🔖 Page $_currentPage bookmarked!',
            isSuccess: true,
          );
        }
      });

      await prefs.setStringList(
        _bookmarkKey,
        _bookmarkedPages.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      debugPrint('❌ Bookmark error: $e');
    }
  }

  Future<void> _clearAllBookmarks() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Clear All Bookmarks'),
        content: const Text(
          'Are you sure you want to remove all bookmarks?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarkKey);
      setState(() {
        _bookmarkedPages.clear();
        _isBookmarked = false;
      });
      _showSnackBar('All bookmarks cleared', isSuccess: false);
    }
  }

  // ── Toggle Controls ───────────────────────────────────────

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _controlsAnimController.forward();
    } else {
      _controlsAnimController.reverse();
    }
  }

  // ── Snackbar ──────────────────────────────────────────────

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green.shade700
            : Colors.grey.shade700,
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
  void dispose() {
    _pdfController?.dispose();
    _controlsAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: _showControls
          ? _buildAppBar(context, isTablet)
          : null,
      body: Stack(
        children: [
          // ── PDF Content ──────────────────────────────────
          _buildBody(context),

          // ── Page Overlay (top right) ─────────────────────
          if (_pdfController != null && _totalPages > 0)
            _buildPageOverlay(context),

          // ── Bottom Controls ──────────────────────────────
          if (_pdfController != null && _showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(context, isTablet),
            ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isTablet,
  ) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.section.icon,
            style: TextStyle(fontSize: isTablet ? 24 : 20),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _getSectionTitle(widget.section.titleKey),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 20 : 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Bookmark toggle
        if (_pdfController != null)
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                key: ValueKey(_isBookmarked),
                color: _isBookmarked
                    ? Colors.amber
                    : Colors.white,
                size: isTablet ? 28 : 24,
              ),
            ),
            tooltip: _isBookmarked
                ? 'Remove Bookmark'
                : 'Add Bookmark',
            onPressed: _toggleBookmark,
          ),

        // Bookmarks list
        if (_pdfController != null)
          IconButton(
            icon: Stack(
              children: [
                Icon(
                  Icons.bookmarks_rounded,
                  color: Colors.white,
                  size: isTablet ? 28 : 24,
                ),
                if (_bookmarkedPages.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${_bookmarkedPages.length}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'View Bookmarks',
            onPressed: () => _showBookmarksSheet(context),
          ),

        // Go to page
        if (_pdfController != null)
          IconButton(
            icon: Icon(
              Icons.find_in_page_rounded,
              color: Colors.white,
              size: isTablet ? 28 : 24,
            ),
            tooltip: 'Go to Page',
            onPressed: _showGoToPageDialog,
          ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ── Body ──────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    // Loading
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              Text(
                'Loading PDF...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Large files may take a moment',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Error
    if (_errorMessage != null) {
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.picture_as_pdf_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Error Loading PDF',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _loadPdf,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // No controller
    if (_pdfController == null) {
      return const Center(
        child: Text(
          'No PDF loaded',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // ✅ PDF Viewer
    return GestureDetector(
      onTap: _toggleControls,
      child: PdfViewPinch(
        controller: _pdfController!,
 onPageChanged: (page) {
  setState(() {
    _currentPage = page;
    _isBookmarked =
        _bookmarkedPages.contains(page);
  });
  // Save reading progress
  if (_totalPages > 0) {
    _progressService.saveProgress(
      sectionId: widget.section.id,
      currentPage: page,
      totalPages: _totalPages,
    );
  }
  // Get total pages safely
  if (_totalPages == 0 && _pdfController != null) {
    Future.microtask(() async {
      try {
        final count =
            await _pdfController?.pagesCount;
        if (mounted &&
            count != null &&
            _totalPages == 0) {
          setState(() {
            _totalPages = count;
          });
        }
      } catch (e) {
        debugPrint('❌ Pages count error: $e');
      }
    });
  }
},
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
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
          errorBuilder: (_, error) => Container(
            color: Colors.grey.shade900,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Page error: $error',
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Page Overlay ──────────────────────────────────────────

  Widget _buildPageOverlay(BuildContext context) {
    return Positioned(
      top: _showControls ? 16 : 60,
      right: 16,
      child: FadeTransition(
        opacity: _controlsFadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isBookmarked)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.bookmark_rounded,
                    color: Colors.amber,
                    size: 14,
                  ),
                ),
              Text(
                '$_currentPage / $_totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Controls ───────────────────────────────────────

  Widget _buildBottomControls(
    BuildContext context,
    bool isTablet,
  ) {
    final buttonSize = isTablet ? 48.0 : 40.0;
    final iconSize = isTablet ? 28.0 : 22.0;
    final fontSize = isTablet ? 16.0 : 14.0;

    return FadeTransition(
      opacity: _controlsFadeAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        child: Row(
          children: [
            // First Page
            _buildControlButton(
              icon: Icons.first_page_rounded,
              iconSize: iconSize,
              size: buttonSize,
              onPressed: _currentPage > 1
                  ? () => _pdfController?.jumpToPage(1)
                  : null,
            ),

            const SizedBox(width: 8),

            // Previous Page
            _buildControlButton(
              icon: Icons.chevron_left_rounded,
              iconSize: iconSize + 4,
              size: buttonSize,
              onPressed: _currentPage > 1
                  ? () => _pdfController?.previousPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),

            const SizedBox(width: 8),

            // Page Info - Tappable
            Expanded(
              child: GestureDetector(
                onTap: _showGoToPageDialog,
                child: Container(
                  height: buttonSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _totalPages > 0
                          ? 'Page $_currentPage of $_totalPages'
                          : 'Page $_currentPage',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Next Page
            _buildControlButton(
              icon: Icons.chevron_right_rounded,
              iconSize: iconSize + 4,
              size: buttonSize,
              onPressed: _currentPage < _totalPages
                  ? () => _pdfController?.nextPage(
                        duration:
                            const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                  : null,
            ),

            const SizedBox(width: 8),

            // Last Page
            _buildControlButton(
              icon: Icons.last_page_rounded,
              iconSize: iconSize,
              size: buttonSize,
              onPressed: _currentPage < _totalPages
                  ? () =>
                      _pdfController?.jumpToPage(_totalPages)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double iconSize,
    required double size,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: onPressed != null
            ? Colors.white.withOpacity(0.15)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed != null
                ? Colors.white
                : Colors.white24,
          ),
        ),
      ),
    );
  }

  // ── Bookmarks Bottom Sheet ────────────────────────────────

  void _showBookmarksSheet(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width > 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.bookmarks_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Bookmarked Pages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    if (_bookmarkedPages.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _clearAllBookmarks();
                        },
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Empty state
                if (_bookmarkedPages.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bookmark_border_rounded,
                          size: 60,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No bookmarks yet',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap the bookmark icon to save a page',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  // Bookmarks Grid
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const BouncingScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 5 : 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1,
                      ),
                      itemCount: _bookmarkedPages.length,
                      itemBuilder: (context, index) {
                        final page =
                            _bookmarkedPages[index];
                        final isCurrent =
                            page == _currentPage;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _pdfController?.jumpToPage(page);
                          },
                          onLongPress: () async {
                            HapticFeedback.mediumImpact();
                            // Remove bookmark on long press
                            final prefs =
                                await SharedPreferences
                                    .getInstance();
                            setState(() {
                              _bookmarkedPages.remove(page);
                              _isBookmarked =
                                  _bookmarkedPages
                                      .contains(_currentPage);
                            });
                            setSheetState(() {});
                            await prefs.setStringList(
                              _bookmarkKey,
                              _bookmarkedPages
                                  .map((e) => e.toString())
                                  .toList(),
                            );
                            _showSnackBar(
                              'Page $page removed',
                              isSuccess: false,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 200,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? Colors.amber
                                  : Colors.white
                                      .withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrent
                                    ? Colors.amber
                                    : Colors.white
                                        .withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bookmark_rounded,
                                  color: isCurrent
                                      ? Colors.black
                                      : Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$page',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: isCurrent
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                SizedBox(
                  height:
                      MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Go To Page Dialog ─────────────────────────────────────

  void _showGoToPageDialog() {
    if (_totalPages == 0) {
      _showSnackBar(
        'Please wait for document to load',
        isSuccess: false,
      );
      return;
    }

    final controller = TextEditingController(
      text: _currentPage.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Go to Page',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter page number (1 - $_totalPages)',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Page number',
                hintStyle: const TextStyle(
                  color: Colors.white38,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white24,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.white24,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
              ),
              onSubmitted: (value) {
                _jumpToPage(value, dialogContext);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                _jumpToPage(controller.text, dialogContext),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _jumpToPage(String value, BuildContext dialogContext) {
    final page = int.tryParse(value);
    if (page != null &&
        page >= 1 &&
        page <= _totalPages) {
      _pdfController?.jumpToPage(page);
      Navigator.pop(dialogContext);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid page (1-$_totalPages)',
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── Section Title ─────────────────────────────────────────

  String _getSectionTitle(String key) {
    const titles = {
      'umrah_guide': 'Umrah Guide',
      'hajj_guide': 'Hajj Guide',
      'duas_collection': 'Duas',
      'makkah_guide': 'Makkah Guide',
      'madinah_guide': 'Madinah Guide',
      'health_safety': 'Health & Safety',
      'packing_checklist': 'Packing List',
      'common_mistakes': 'Common Mistakes',
      'emergency_info': 'Emergency Info',
      'quran': 'Holy Quran',
    };
    return titles[key] ?? key;
  }
}
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:pdfx/pdfx.dart';
// import '../../app/app_constants.dart';
// import '../../core/services/download_service.dart';
// import '../../core/services/storage_service.dart';

// class PdfViewerScreen extends StatefulWidget {
//   final ContentSection section;
//   final String? customFilePath;
  
//   const PdfViewerScreen({
//     super.key,
//     required this.section,
//     this.customFilePath,
//   });

//   @override
//   State<PdfViewerScreen> createState() => _PdfViewerScreenState();
// }

// class _PdfViewerScreenState extends State<PdfViewerScreen> {
//   PdfControllerPinch? _pdfController;
//   bool _isLoading = true;
//   String? _errorMessage;
//   int _currentPage = 1;
//   int _totalPages = 0;
//   bool _showControls = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPdf();
//   }

//   Future<void> _loadPdf() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });

//       String filePath;

//       // Use custom path if provided (Quran)
//       if (widget.customFilePath != null) {
//         filePath = widget.customFilePath!;
//       } else {
//         final storageService = StorageService.instance;
//         final languageCode = storageService.getLanguage() ?? 'en';
//         final downloadService = DownloadService();
//         final pdfsDir = await downloadService.getPdfsDirectory(languageCode);
//         final fileName = '${widget.section.fileName}_$languageCode.pdf';
//         filePath = '$pdfsDir/$fileName';
//       }

//       print('📄 Loading PDF: $filePath');

//       final file = File(filePath);
//       if (!await file.exists()) {
//         throw Exception(
//           'PDF file not found.\nPlease re-download content from Settings.',
//         );
//       }

//       final fileSize = await file.length();
//       print('📊 Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB');

//       // ✅ CORRECT: Pass Future directly - no await
//       final document = PdfDocument.openFile(filePath);

//       setState(() {
//         _pdfController = PdfControllerPinch(document: document);
//         _isLoading = false;
//       });

//       print('✅ PDF controller created successfully');

//     } catch (e) {
//       print('❌ Error: $e');
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e
//             .toString()
//             .replaceAll('Exception: ', '')
//             .replaceAll('PlatformException', 'Error');
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pdfController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(widget.section.icon),
//             const SizedBox(width: 8),
//             Flexible(
//               child: Text(
//                 _getSectionTitle(widget.section.titleKey),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           if (_pdfController != null)
//             IconButton(
//               icon: const Icon(Icons.find_in_page_rounded),
//               tooltip: 'Go to page',
//               onPressed: _showGoToPageDialog,
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           _buildBody(),
//           if (_pdfController != null) _buildPageOverlay(),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   // ── Body ─────────────────────────────────────────────────────────────────

//   Widget _buildBody() {
//     // Loading State
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircularProgressIndicator(),
//             const SizedBox(height: 16),
//             Text(
//               'Loading PDF...',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Large files may take a moment',
//               style: Theme.of(context).textTheme.bodySmall,
//             ),
//           ],
//         ),
//       );
//     }

//     // Error State
//     if (_errorMessage != null) {
//       return Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.picture_as_pdf_rounded,
//                 size: 64,
//                 color: Colors.red.shade400,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Error Loading PDF',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _errorMessage!,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.red.shade700,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _loadPdf,
//                 icon: const Icon(Icons.refresh_rounded),
//                 label: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // No Controller
//     if (_pdfController == null) {
//       return const Center(child: Text('No PDF loaded'));
//     }

//   // ✅ Updated PDF Viewer
// return GestureDetector(
//   onTap: () {
//     setState(() {
//       _showControls = !_showControls;
//     });
//   },
//   child: PdfViewPinch(
//     controller: _pdfController!,
//     // ✅ Set total pages once when the document loads
//     onDocumentLoaded: (document) {
//       setState(() {
//         _totalPages = document.pagesCount;
//       });
//     },
//     onPageChanged: (page) {
//       setState(() {
//         _currentPage = page;
//       });
//     },
  

//         builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
//           options: const DefaultBuilderOptions(),
//           documentLoaderBuilder: (_) => const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CircularProgressIndicator(),
//                 SizedBox(height: 12),
//                 Text('Opening document...'),
//               ],
//             ),
//           ),
//           pageLoaderBuilder: (_) => const Center(
//             child: CircularProgressIndicator(strokeWidth: 2),
//           ),
//           errorBuilder: (_, error) => Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, size: 48, color: Colors.red),
//                 const SizedBox(height: 8),
//                 Text('Page error: $error'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Page Overlay ──────────────────────────────────────────────────────────

//   Widget _buildPageOverlay() {
//     if (!_showControls) return const SizedBox();

//     return Positioned(
//       top: 16,
//       right: 16,
//       child: AnimatedOpacity(
//         opacity: _showControls ? 1.0 : 0.0,
//         duration: const Duration(milliseconds: 300),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.6),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             _totalPages > 0
//                 ? '$_currentPage / $_totalPages'
//                 : 'Page $_currentPage',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Bottom Bar ────────────────────────────────────────────────────────────

//   Widget? _buildBottomBar() {
//     if (_pdfController == null) return null;

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: _showControls ? null : 0,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardTheme.color,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               // First Page
//               IconButton(
//                 icon: const Icon(Icons.first_page_rounded),
//                 onPressed: _currentPage > 1
//                     ? () => _pdfController?.jumpToPage(1)
//                     : null,
//               ),

//               // Previous Page
//               IconButton(
//                 icon: const Icon(Icons.chevron_left_rounded),
//                 iconSize: 32,
//                 onPressed: _currentPage > 1
//                     ? () => _pdfController?.previousPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         )
//                     : null,
//               ),

//               // Page Info - Tappable
//               Expanded(
//                 child: GestureDetector(
//                   onTap: _showGoToPageDialog,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Theme.of(context)
//                           .colorScheme
//                           .primary
//                           .withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       _totalPages > 0
//                           ? 'Page $_currentPage of $_totalPages'
//                           : 'Page $_currentPage',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // Next Page
//               IconButton(
//                 icon: const Icon(Icons.chevron_right_rounded),
//                 iconSize: 32,
//                 onPressed: _currentPage < _totalPages
//                     ? () => _pdfController?.nextPage(
//                           duration: const Duration(milliseconds: 300),
//                           curve: Curves.easeInOut,
//                         )
//                     : null,
//               ),

//               // Last Page
//               IconButton(
//                 icon: const Icon(Icons.last_page_rounded),
//                 onPressed: _currentPage < _totalPages
//                     ? () => _pdfController?.jumpToPage(_totalPages)
//                     : null,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Go To Page Dialog ─────────────────────────────────────────────────────

//   void _showGoToPageDialog() {
//     // Only show if we know total pages
//     if (_totalPages == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please wait for document to fully load'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return;
//     }

//     final controller = TextEditingController(
//       text: _currentPage.toString(),
//     );

//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text('Go to Page'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('Enter page number (1 - $_totalPages)'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: 'Page number',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               onSubmitted: (value) {
//                 _jumpToPage(value, dialogContext);
//               },
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => _jumpToPage(
//               controller.text,
//               dialogContext,
//             ),
//             child: const Text('Go'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _jumpToPage(String value, BuildContext dialogContext) {
//     final page = int.tryParse(value);
//     if (page != null && page >= 1 && page <= _totalPages) {
//       _pdfController?.jumpToPage(page);
//       Navigator.pop(dialogContext);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please enter a valid page number (1 - $_totalPages)',
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ── Section Title ─────────────────────────────────────────────────────────

//   String _getSectionTitle(String key) {
//     const titles = {
//       'umrah_guide': 'Umrah Guide',
//       'hajj_guide': 'Hajj Guide',
//       'duas_collection': 'Duas',
//       'makkah_guide': 'Makkah Guide',
//       'madinah_guide': 'Madinah Guide',
//       'health_safety': 'Health & Safety',
//       'packing_checklist': 'Packing List',
//       'common_mistakes': 'Common Mistakes',
//       'emergency_info': 'Emergency Info',
//       'quran': 'Holy Quran',
//     };
//     return titles[key] ?? key;
//   }
// }

// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:pdfx/pdfx.dart';
// // import '../../app/app_constants.dart';
// // import '../../core/services/download_service.dart';
// // import '../../core/services/storage_service.dart';

// // class PdfViewerScreen extends StatefulWidget {
// //   final ContentSection section;
  
// //   const PdfViewerScreen({
// //     super.key,
// //     required this.section,
// //   });

// //   @override
// //   State<PdfViewerScreen> createState() => _PdfViewerScreenState();
// // }

// // class _PdfViewerScreenState extends State<PdfViewerScreen> {
// //   PdfController? _pdfController;
// //   bool _isLoading = true;
// //   String? _errorMessage;
// //   int _currentPage = 1;
// //   int _totalPages = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadPdf();
// //   }

// //   Future<void> _loadPdf() async {
// //     try {
// //       setState(() {
// //         _isLoading = true;
// //         _errorMessage = null;
// //       });

// //       final storageService = StorageService.instance;
// //       final languageCode = storageService.getLanguage() ?? 'en';

// //       final downloadService = DownloadService();
// //       final pdfsDir = await downloadService.getPdfsDirectory(languageCode);
// //       final fileName = '${widget.section.fileName}_$languageCode.pdf';
// //       final filePath = '$pdfsDir/$fileName';

// //       print('📄 Loading PDF from: $filePath');

// //       final file = File(filePath);
// //       if (!await file.exists()) {
// //         throw Exception('PDF file not found. Please re-download content.');
// //       }

// //       print('✅ PDF file exists');

// //       final pdfController = PdfController(
// //         document: PdfDocument.openFile(filePath),
// //       );

// //       final document = await PdfDocument.openFile(filePath);
      
// //       print('✅ PDF document loaded, pages: ${document.pagesCount}');
      
// //       setState(() {
// //         _pdfController = pdfController;
// //         _totalPages = document.pagesCount;
// //         _isLoading = false;
// //       });
      
// //       print('✅ PDF controller created successfully');
      
// //     } catch (e) {
// //       print('❌ Error loading PDF: $e');
// //       setState(() {
// //         _isLoading = false;
// //         _errorMessage = e.toString();
// //       });
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _pdfController?.dispose();
// //     super.dispose();
// //   }

// //   void _showPageJumpDialog() {
// //     final textController = TextEditingController();
    
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('Jump to Page'),
// //         content: TextField(
// //           controller: textController,
// //           keyboardType: TextInputType.number,
// //           decoration: InputDecoration(
// //             labelText: 'Page number (1-$_totalPages)',
// //             border: const OutlineInputBorder(),
// //           ),
// //           autofocus: true,
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             onPressed: () {
// //               final pageNumber = int.tryParse(textController.text);
// //               if (pageNumber != null && pageNumber >= 1 && pageNumber <= _totalPages) {
// //                 _pdfController?.jumpToPage(pageNumber);
// //                 Navigator.pop(context);
// //               } else {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(
// //                     content: Text('Please enter a number between 1 and $_totalPages'),
// //                     backgroundColor: Colors.red,
// //                   ),
// //                 );
// //               }
// //             },
// //             child: const Text('Go'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Text(widget.section.icon),
// //             const SizedBox(width: 8),
// //             Flexible(
// //               child: Text(
// //                 _getSectionTitle(widget.section.titleKey),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),
// //           ],
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.search),
// //             tooltip: 'Search',
// //             onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(
// //                   content: Text('Search feature coming soon!'),
// //                   duration: Duration(seconds: 2),
// //                 ),
// //               );
// //             },
// //           ),
// //           if (_pdfController != null)
// //             IconButton(
// //               icon: const Icon(Icons.first_page),
// //               tooltip: 'First Page',
// //               onPressed: () {
// //                 _pdfController?.jumpToPage(1);
// //               },
// //             ),
// //           if (_pdfController != null)
// //             IconButton(
// //               icon: const Icon(Icons.last_page),
// //               tooltip: 'Last Page',
// //               onPressed: () {
// //                 _pdfController?.jumpToPage(_totalPages);
// //               },
// //             ),
// //         ],
// //       ),
// //       body: _buildBody(),
// //       bottomNavigationBar: _buildBottomBar(),
// //     );
// //   }

// //   Widget _buildBody() {
// //     if (_isLoading) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const CircularProgressIndicator(),
// //             const SizedBox(height: 16),
// //             Text(
// //               'Loading PDF...',
// //               style: Theme.of(context).textTheme.bodyMedium,
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     if (_errorMessage != null) {
// //       return Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(24.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(
// //                 Icons.error_outline,
// //                 size: 64,
// //                 color: Colors.red.shade400,
// //               ),
// //               const SizedBox(height: 16),
// //               Text(
// //                 'Error Loading PDF',
// //                 style: Theme.of(context).textTheme.titleLarge,
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 _errorMessage!,
// //                 style: Theme.of(context).textTheme.bodyMedium,
// //                 textAlign: TextAlign.center,
// //               ),
// //               const SizedBox(height: 24),
// //               ElevatedButton.icon(
// //                 onPressed: _loadPdf,
// //                 icon: const Icon(Icons.refresh),
// //                 label: const Text('Retry'),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_pdfController == null) {
// //       return const Center(
// //         child: Text('No PDF loaded'),
// //       );
// //     }

// //     return PdfView(
// //       controller: _pdfController!,
// //       onPageChanged: (page) {
// //         setState(() {
// //           _currentPage = page;
// //         });
// //       },
// //       onDocumentError: (error) {
// //         setState(() {
// //           _errorMessage = error.toString();
// //         });
// //       },
// //     );
// //   }

// //   Widget? _buildBottomBar() {
// //     if (_pdfController == null) {
// //       return null;
// //     }

// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Theme.of(context).cardTheme.color,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 8,
// //             offset: const Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       child: SafeArea(
// //         child: Row(
// //           children: [
// //             IconButton(
// //               icon: const Icon(Icons.chevron_left),
// //               iconSize: 32,
// //               onPressed: _currentPage > 1
// //                   ? () {
// //                       _pdfController?.previousPage(
// //                         duration: const Duration(milliseconds: 300),
// //                         curve: Curves.easeInOut,
// //                       );
// //                     }
// //                   : null,
// //             ),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: GestureDetector(
// //                 onTap: _showPageJumpDialog,
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                   decoration: BoxDecoration(
// //                     color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Text(
// //                         'Page',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Theme.of(context).textTheme.bodyMedium?.color,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         '$_currentPage',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: Theme.of(context).colorScheme.primary,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         'of $_totalPages',
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Theme.of(context).textTheme.bodyMedium?.color,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Icon(
// //                         Icons.edit_outlined,
// //                         size: 16,
// //                         color: Theme.of(context).colorScheme.primary,
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             IconButton(
// //               icon: const Icon(Icons.chevron_right),
// //               iconSize: 32,
// //               onPressed: _currentPage < _totalPages
// //                   ? () {
// //                       _pdfController?.nextPage(
// //                         duration: const Duration(milliseconds: 300),
// //                         curve: Curves.easeInOut,
// //                       );
// //                     }
// //                   : null,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   String _getSectionTitle(String key) {
// //     final titles = {
// //       'umrah_guide': 'Umrah Guide',
// //       'hajj_guide': 'Hajj Guide',
// //       'duas_collection': 'Duas',
// //       'makkah_guide': 'Makkah Guide',
// //       'madinah_guide': 'Madinah Guide',
// //       'health_safety': 'Health & Safety',
// //       'packing_checklist': 'Packing List',
// //       'common_mistakes': 'Common Mistakes',
// //       'emergency_info': 'Emergency Info',
// //       'quran': 'Quran',
// //     };
// //     return titles[key] ?? key;
// //   }
// // }