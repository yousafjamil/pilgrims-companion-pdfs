import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
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

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfControllerPinch? _pdfController;
  bool _isLoading = true;
  String? _errorMessage;
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
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      String filePath;

      // Use custom path if provided (Quran)
      if (widget.customFilePath != null) {
        filePath = widget.customFilePath!;
      } else {
        final storageService = StorageService.instance;
        final languageCode = storageService.getLanguage() ?? 'en';
        final downloadService = DownloadService();
        final pdfsDir = await downloadService.getPdfsDirectory(languageCode);
        final fileName = '${widget.section.fileName}_$languageCode.pdf';
        filePath = '$pdfsDir/$fileName';
      }

      print('📄 Loading PDF: $filePath');

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception(
          'PDF file not found.\nPlease re-download content from Settings.',
        );
      }

      final fileSize = await file.length();
      print('📊 Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB');

      // ✅ CORRECT: Pass Future directly - no await
      final document = PdfDocument.openFile(filePath);

      setState(() {
        _pdfController = PdfControllerPinch(document: document);
        _isLoading = false;
      });

      print('✅ PDF controller created successfully');

    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('PlatformException', 'Error');
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.section.icon),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _getSectionTitle(widget.section.titleKey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_pdfController != null)
            IconButton(
              icon: const Icon(Icons.find_in_page_rounded),
              tooltip: 'Go to page',
              onPressed: _showGoToPageDialog,
            ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_pdfController != null) _buildPageOverlay(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Body ─────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    // Loading State
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Large files may take a moment',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    // Error State
    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading PDF',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // No Controller
    if (_pdfController == null) {
      return const Center(child: Text('No PDF loaded'));
    }

  // ✅ Updated PDF Viewer
return GestureDetector(
  onTap: () {
    setState(() {
      _showControls = !_showControls;
    });
  },
  child: PdfViewPinch(
    controller: _pdfController!,
    // ✅ Set total pages once when the document loads
    onDocumentLoaded: (document) {
      setState(() {
        _totalPages = document.pagesCount;
      });
    },
    onPageChanged: (page) {
      setState(() {
        _currentPage = page;
      });
    },
  

        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Opening document...'),
              ],
            ),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          errorBuilder: (_, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text('Page error: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Page Overlay ──────────────────────────────────────────────────────────

  Widget _buildPageOverlay() {
    if (!_showControls) return const SizedBox();

    return Positioned(
      top: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _totalPages > 0
                ? '$_currentPage / $_totalPages'
                : 'Page $_currentPage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget? _buildBottomBar() {
    if (_pdfController == null) return null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showControls ? null : 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // First Page
              IconButton(
                icon: const Icon(Icons.first_page_rounded),
                onPressed: _currentPage > 1
                    ? () => _pdfController?.jumpToPage(1)
                    : null,
              ),

              // Previous Page
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                iconSize: 32,
                onPressed: _currentPage > 1
                    ? () => _pdfController?.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),

              // Page Info - Tappable
              Expanded(
                child: GestureDetector(
                  onTap: _showGoToPageDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _totalPages > 0
                          ? 'Page $_currentPage of $_totalPages'
                          : 'Page $_currentPage',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),

              // Next Page
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                iconSize: 32,
                onPressed: _currentPage < _totalPages
                    ? () => _pdfController?.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
              ),

              // Last Page
              IconButton(
                icon: const Icon(Icons.last_page_rounded),
                onPressed: _currentPage < _totalPages
                    ? () => _pdfController?.jumpToPage(_totalPages)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Go To Page Dialog ─────────────────────────────────────────────────────

  void _showGoToPageDialog() {
    // Only show if we know total pages
    if (_totalPages == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for document to fully load'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final controller = TextEditingController(
      text: _currentPage.toString(),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Go to Page'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter page number (1 - $_totalPages)'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Page number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _jumpToPage(
              controller.text,
              dialogContext,
            ),
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _jumpToPage(String value, BuildContext dialogContext) {
    final page = int.tryParse(value);
    if (page != null && page >= 1 && page <= _totalPages) {
      _pdfController?.jumpToPage(page);
      Navigator.pop(dialogContext);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid page number (1 - $_totalPages)',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Section Title ─────────────────────────────────────────────────────────

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
  
//   const PdfViewerScreen({
//     super.key,
//     required this.section,
//   });

//   @override
//   State<PdfViewerScreen> createState() => _PdfViewerScreenState();
// }

// class _PdfViewerScreenState extends State<PdfViewerScreen> {
//   PdfController? _pdfController;
//   bool _isLoading = true;
//   String? _errorMessage;
//   int _currentPage = 1;
//   int _totalPages = 0;

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

//       final storageService = StorageService.instance;
//       final languageCode = storageService.getLanguage() ?? 'en';

//       final downloadService = DownloadService();
//       final pdfsDir = await downloadService.getPdfsDirectory(languageCode);
//       final fileName = '${widget.section.fileName}_$languageCode.pdf';
//       final filePath = '$pdfsDir/$fileName';

//       print('📄 Loading PDF from: $filePath');

//       final file = File(filePath);
//       if (!await file.exists()) {
//         throw Exception('PDF file not found. Please re-download content.');
//       }

//       print('✅ PDF file exists');

//       final pdfController = PdfController(
//         document: PdfDocument.openFile(filePath),
//       );

//       final document = await PdfDocument.openFile(filePath);
      
//       print('✅ PDF document loaded, pages: ${document.pagesCount}');
      
//       setState(() {
//         _pdfController = pdfController;
//         _totalPages = document.pagesCount;
//         _isLoading = false;
//       });
      
//       print('✅ PDF controller created successfully');
      
//     } catch (e) {
//       print('❌ Error loading PDF: $e');
//       setState(() {
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _pdfController?.dispose();
//     super.dispose();
//   }

//   void _showPageJumpDialog() {
//     final textController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Jump to Page'),
//         content: TextField(
//           controller: textController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             labelText: 'Page number (1-$_totalPages)',
//             border: const OutlineInputBorder(),
//           ),
//           autofocus: true,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               final pageNumber = int.tryParse(textController.text);
//               if (pageNumber != null && pageNumber >= 1 && pageNumber <= _totalPages) {
//                 _pdfController?.jumpToPage(pageNumber);
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Please enter a number between 1 and $_totalPages'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Go'),
//           ),
//         ],
//       ),
//     );
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
//           IconButton(
//             icon: const Icon(Icons.search),
//             tooltip: 'Search',
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Search feature coming soon!'),
//                   duration: Duration(seconds: 2),
//                 ),
//               );
//             },
//           ),
//           if (_pdfController != null)
//             IconButton(
//               icon: const Icon(Icons.first_page),
//               tooltip: 'First Page',
//               onPressed: () {
//                 _pdfController?.jumpToPage(1);
//               },
//             ),
//           if (_pdfController != null)
//             IconButton(
//               icon: const Icon(Icons.last_page),
//               tooltip: 'Last Page',
//               onPressed: () {
//                 _pdfController?.jumpToPage(_totalPages);
//               },
//             ),
//         ],
//       ),
//       body: _buildBody(),
//       bottomNavigationBar: _buildBottomBar(),
//     );
//   }

//   Widget _buildBody() {
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
//           ],
//         ),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.error_outline,
//                 size: 64,
//                 color: Colors.red.shade400,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Error Loading PDF',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _errorMessage!,
//                 style: Theme.of(context).textTheme.bodyMedium,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _loadPdf,
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Retry'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     if (_pdfController == null) {
//       return const Center(
//         child: Text('No PDF loaded'),
//       );
//     }

//     return PdfView(
//       controller: _pdfController!,
//       onPageChanged: (page) {
//         setState(() {
//           _currentPage = page;
//         });
//       },
//       onDocumentError: (error) {
//         setState(() {
//           _errorMessage = error.toString();
//         });
//       },
//     );
//   }

//   Widget? _buildBottomBar() {
//     if (_pdfController == null) {
//       return null;
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardTheme.color,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: SafeArea(
//         child: Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.chevron_left),
//               iconSize: 32,
//               onPressed: _currentPage > 1
//                   ? () {
//                       _pdfController?.previousPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     }
//                   : null,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: GestureDetector(
//                 onTap: _showPageJumpDialog,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Page',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Theme.of(context).textTheme.bodyMedium?.color,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         '$_currentPage',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.primary,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'of $_totalPages',
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Theme.of(context).textTheme.bodyMedium?.color,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         Icons.edit_outlined,
//                         size: 16,
//                         color: Theme.of(context).colorScheme.primary,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.chevron_right),
//               iconSize: 32,
//               onPressed: _currentPage < _totalPages
//                   ? () {
//                       _pdfController?.nextPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     }
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   String _getSectionTitle(String key) {
//     final titles = {
//       'umrah_guide': 'Umrah Guide',
//       'hajj_guide': 'Hajj Guide',
//       'duas_collection': 'Duas',
//       'makkah_guide': 'Makkah Guide',
//       'madinah_guide': 'Madinah Guide',
//       'health_safety': 'Health & Safety',
//       'packing_checklist': 'Packing List',
//       'common_mistakes': 'Common Mistakes',
//       'emergency_info': 'Emergency Info',
//       'quran': 'Quran',
//     };
//     return titles[key] ?? key;
//   }
// }