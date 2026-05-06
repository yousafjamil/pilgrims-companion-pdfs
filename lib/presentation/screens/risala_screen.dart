import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/risala_service.dart';
import '../../core/services/storage_service.dart';
import 'pdf_viewer_screen.dart';
import 'webview_screen.dart';
import '../../app/app_constants.dart';

class RisalaScreen extends StatefulWidget {
  const RisalaScreen({super.key});

  @override
  State<RisalaScreen> createState() =>
      _RisalaScreenState();
}

class _RisalaScreenState extends State<RisalaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String get _langCode =>
      StorageService.instance.getLanguage() ?? 'en';

  List<RisalaBook> _books = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  Map<String, bool> _downloadStatus = {};
  Map<String, double> _downloadProgress = {};
  bool _isDownloadingAll = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final books =
        RisalaService.getBooksForLanguage(_langCode);
    final cats = ['All'] +
        RisalaService.getCategoriesForLanguage(
          _langCode,
        );

    setState(() {
      _books = books;
      _categories = cats;
    });

    // Check download status
    await _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final status = <String, bool>{};
    for (final book in _books) {
      status[book.id] = await RisalaService()
          .isBookDownloaded(_langCode, book.id);
    }
    if (mounted) {
      setState(() => _downloadStatus = status);
    }
  }

  List<RisalaBook> get _filteredBooks {
    if (_selectedCategory == 'All') return _books;
    return _books
        .where((b) => b.category == _selectedCategory)
        .toList();
  }

  // ── Download Single Book ──────────────────────────

  Future<void> _downloadBook(RisalaBook book) async {
    setState(() {
      _downloadProgress[book.id] = 0.0;
    });

    final success = await RisalaService().downloadBook(
      langCode: _langCode,
      book: book,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress[book.id] = progress;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        _downloadStatus[book.id] = success;
        _downloadProgress.remove(book.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ ${book.title} downloaded!'
                : '⚠️ ${book.title} - opening online',
          ),
          backgroundColor:
              success ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ── Download All Books ────────────────────────────

  Future<void> _downloadAll() async {
    setState(() => _isDownloadingAll = true);

    await RisalaService().downloadAllBooks(
      langCode: _langCode,
      onProgress: (title, current, total, progress) {
        if (mounted) {
          setState(() {
            _downloadProgress['all_$current'] =
                progress;
          });
        }
      },
      onComplete: () async {
        await _checkDownloadStatus();
        if (mounted) {
          setState(() {
            _isDownloadingAll = false;
            _downloadProgress.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '✅ All books downloaded for offline use!',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isDownloadingAll = false);
        }
      },
    );
  }

  // ── Open Book ─────────────────────────────────────

  Future<void> _openBook(RisalaBook book) async {
    HapticFeedback.lightImpact();

    final isDownloaded = _downloadStatus[book.id] ??
        await RisalaService()
            .isBookDownloaded(_langCode, book.id);

    if (isDownloaded) {
      // Open local PDF
      final path = await RisalaService().getBookPath(
        _langCode,
        book.id,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RisalaPdfViewerScreen(
              book: book,
              filePath: path,
            ),
          ),
        );
      }
    } else {
      // Show options
      _showBookOptions(book);
    }
  }

  void _showBookOptions(RisalaBook book) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  book.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        book.category,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),

            // Download option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.download_rounded,
                  color: Colors.green,
                ),
              ),
              title: const Text('Download for Offline'),
              subtitle: const Text(
                'Save to read without internet',
              ),
              onTap: () {
                Navigator.pop(ctx);
                _downloadBook(book);
              },
            ),

            // Online option
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.open_in_browser_rounded,
                  color: Colors.blue,
                ),
              ),
              title: const Text('Open Online'),
              subtitle: const Text(
                'Requires internet connection',
              ),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: book.bookPageUrl!,
                      title: book.title,
                    ),
                  ),
                );
              },
            ),

            SizedBox(
              height:
                  MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final downloadedCount = _downloadStatus.values
        .where((v) => v)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📚', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Risala Library'),
          ],
        ),
        actions: [
          // Download all button
          if (!_isDownloadingAll)
            IconButton(
              icon: const Icon(
                Icons.download_for_offline_rounded,
              ),
              tooltip: 'Download All',
              onPressed: _downloadAll,
            )
          else
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(50),
          child: _buildCategoryFilter(),
        ),
      ),
      body: Column(
        children: [
          // Download status bar
          _buildStatusBar(
            context,
            downloadedCount,
          ),

          // Books grid
          Expanded(
            child: _buildBooksGrid(context),
          ),
        ],
      ),
    );
  }

  // ── Category Filter ───────────────────────────────

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() =>
                  _selectedCategory = cat);
            },
            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.2),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Status Bar ────────────────────────────────────

  Widget _buildStatusBar(
    BuildContext context,
    int downloadedCount,
  ) {
    final total = _books.length;
    final progress =
        total > 0 ? downloadedCount / total : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      color: Theme.of(context)
          .colorScheme
          .primary
          .withOpacity(0.05),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$downloadedCount / $total books downloaded',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Books Grid ────────────────────────────────────

  Widget _buildBooksGrid(BuildContext context) {
    final books = _filteredBooks;
    final isTablet =
        MediaQuery.of(context).size.width > 600;

    if (books.isEmpty) {
      return const Center(
        child: Text('No books available'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: isTablet ? 0.75 : 0.70,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return _buildBookCard(context, book);
      },
    );
  }

  // ── Book Card ─────────────────────────────────────

  Widget _buildBookCard(
    BuildContext context,
    RisalaBook book,
  ) {
    final isDownloaded =
        _downloadStatus[book.id] ?? false;
    final isDownloading =
        _downloadProgress.containsKey(book.id);
    final progress = _downloadProgress[book.id] ?? 0.0;

    return GestureDetector(
      onTap: () => _openBook(book),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Book Cover
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2D5F3F),
                      const Color(0xFF1A3D28),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter:
                            _BookCoverPainter(),
                      ),
                    ),
                    // Official logo area
                    Center(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            book.icon,
                            style: const TextStyle(
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD4AF37,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                6,
                              ),
                            ),
                            child: const Text(
                              'رئاسة الشؤون الدينية',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                              textDirection:
                                  TextDirection.rtl,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Download status badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDownloaded
                              ? Colors.green
                              : Colors.black
                                  .withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: isDownloading
                            ? Padding(
                                padding:
                                    const EdgeInsets
                                        .all(4),
                                child:
                                    CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isDownloaded
                                    ? Icons
                                        .check_rounded
                                    : Icons
                                        .download_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Book Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                        fontSize: 9,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Status
                  Row(
                    children: [
                      Icon(
                        isDownloaded
                            ? Icons
                                .offline_pin_rounded
                            : Icons
                                .cloud_download_outlined,
                        size: 12,
                        color: isDownloaded
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDownloaded
                            ? 'Offline Ready'
                            : isDownloading
                                ? '${(progress * 100).toInt()}%'
                                : 'Tap to download',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDownloaded
                              ? Colors.green
                              : isDownloading
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Book Cover Painter ────────────────────────────────

class _BookCoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0;
        x < size.width + 30;
        x += 30) {
      for (double y = 0;
          y < size.height + 30;
          y += 30) {
        canvas.drawCircle(Offset(x, y), 15, paint);
      }
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter old,
  ) =>
      false;
}

// ── Risala PDF Viewer ─────────────────────────────────

class RisalaPdfViewerScreen extends StatelessWidget {
  final RisalaBook book;
  final String filePath;

  const RisalaPdfViewerScreen({
    super.key,
    required this.book,
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    // Reuse existing PDF viewer with custom path
    return PdfViewerScreen(
      section: ContentSection(
        id: book.id,
        titleKey: book.title,
        icon: book.icon,
        fileName: book.id,
      ),
      customFilePath: filePath,
    );
  }
}