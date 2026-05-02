import 'package:flutter/material.dart';
import '../../app/app_constants.dart';
import '../../core/services/download_service.dart';
import '../../core/services/storage_service.dart';
import 'pdf_viewer_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<_SearchResult> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Search Logic ─────────────────────────────────────────

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _isSearching = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted || query != _lastQuery) return;

    final languageCode =
        StorageService.instance.getLanguage() ?? 'en';
    final downloadService = DownloadService();
    final List<_SearchResult> results = [];

    // Search through section titles and keywords
    for (final section in AppConstants.contentSections) {
      if (section.id == 'quran') continue;

      final title = _getSectionTitle(section.titleKey);
      final keywords =
          _getSectionKeywords(section.id);

      // Check if query matches title or keywords
      if (title.toLowerCase().contains(
            query.toLowerCase(),
          ) ||
          keywords.any(
            (k) => k.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )) {
        // Check if PDF exists
        final pdfsDir = await downloadService
            .getPdfsDirectory(languageCode);
        final fileName =
            '${section.fileName}_$languageCode.pdf';
        final filePath = '$pdfsDir/$fileName';

        results.add(_SearchResult(
          section: section,
          title: title,
          matchedKeyword: keywords.firstWhere(
            (k) => k.toLowerCase().contains(
                  query.toLowerCase(),
                ),
            orElse: () => title,
          ),
          filePath: filePath,
        ));
      }
    }

    if (mounted && query == _lastQuery) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _searchController.clear();
                _search('');
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  // ── Search Field ──────────────────────────────────────────

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      decoration: const InputDecoration(
        hintText: 'Search guides...',
        hintStyle: TextStyle(
          color: Colors.white60,
          fontSize: 16,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      onChanged: _search,
      textInputAction: TextInputAction.search,
      onSubmitted: _search,
    );
  }

  // ── Body ──────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    // Empty state
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(context);
    }

    // Loading
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // No results
    if (_results.isEmpty) {
      return _buildNoResults(context);
    }

    // Results
    return _buildResults(context);
  }

  // ── Empty State ───────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    final suggestions = [
      ('🕋', 'Umrah Guide'),
      ('🌙', 'Hajj Guide'),
      ('🤲', 'Duas'),
      ('🏥', 'Health'),
      ('🎒', 'Packing'),
      ('⚠️', 'Mistakes'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Search',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = s.$2;
                  _search(s.$2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.$1,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.$2,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          Text(
            'All Guides',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // All sections list
          ...AppConstants.contentSections
              .where((s) => s.id != 'quran')
              .map((section) {
            return ListTile(
              leading: Text(
                section.icon,
                style: const TextStyle(fontSize: 28),
              ),
              title: Text(
                _getSectionTitle(section.titleKey),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(
                      section: section,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ── No Results ────────────────────────────────────────────

  Widget _buildNoResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '🔍',
            style: TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for:\numrah, hajj, duas, health, packing',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────

  Widget _buildResults(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultCard(context, result);
      },
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    _SearchResult result,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              result.section.icon,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        title: Text(
          result.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          result.matchedKeyword,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Open',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PdfViewerScreen(
                section: result.section,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  String _getSectionTitle(String key) {
    const titles = {
      'umrah_guide': 'Umrah Guide',
      'hajj_guide': 'Hajj Guide',
      'duas_collection': 'Duas Collection',
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

  List<String> _getSectionKeywords(String id) {
    const keywords = {
      'umrah_guide': [
        'umrah', 'tawaf', 'sai', 'ihram',
        'halq', 'miqat', 'rituals',
      ],
      'hajj_guide': [
        'hajj', 'arafah', 'mina', 'muzdalifah',
        'jamarat', 'stoning', 'sacrifice', 'eid',
      ],
      'duas': [
        'dua', 'prayer', 'supplication', 'dhikr',
        'arabic', 'quran', 'bismillah',
      ],
      'makkah_guide': [
        'makkah', 'mecca', 'kaaba', 'zamzam',
        'black stone', 'haram', 'safa', 'marwah',
      ],
      'madinah_guide': [
        'madinah', 'medina', 'prophet', 'mosque',
        'rawdah', 'quba', 'uhud',
      ],
      'health_safety': [
        'health', 'safety', 'heat', 'water',
        'medicine', 'hospital', 'emergency',
      ],
      'packing': [
        'packing', 'luggage', 'clothes', 'ihram',
        'checklist', 'what to bring',
      ],
      'mistakes': [
        'mistakes', 'avoid', 'errors', 'wrong',
        'correct', 'rules', 'important',
      ],
      'emergency': [
        'emergency', 'help', 'contact', 'police',
        'ambulance', 'lost', 'missing',
      ],
    };
    return keywords[id] ?? [];
  }
}

// ── Search Result Model ────────────────────────────────────

class _SearchResult {
  final ContentSection section;
  final String title;
  final String matchedKeyword;
  final String filePath;

  _SearchResult({
    required this.section,
    required this.title,
    required this.matchedKeyword,
    required this.filePath,
  });
}