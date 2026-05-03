import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/haramain_content_service.dart';
import '../../data/models/content_models.dart';
import 'category_screen.dart';
import 'content_detail_screen.dart';
import 'prayer_times_screen.dart';
import 'webview_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  final TextEditingController _controller =
      TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<_SearchResult> _results = [];
  bool _isSearching = false;
  String _lastQuery = '';

  String get _langCode =>
      StorageService.instance.getLanguage() ?? 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Search ────────────────────────────────────────

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

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted || query != _lastQuery) return;

    final results = <_SearchResult>[];
    final q = query.toLowerCase();

    // Search through categories
    for (final cat in AppConstants.homeCategories) {
      final catTitle =
          cat.getTitle(_langCode).toLowerCase();

      if (catTitle.contains(q)) {
        results.add(_SearchResult(
          icon: cat.icon,
          title: cat.getTitle(_langCode),
          subtitle: '${cat.subcategories.length}'
              ' sections',
          color: Color(cat.color),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CategoryScreen(
                category: cat,
                langCode: _langCode,
              ),
            ),
          ),
        ));
      }

      // Search subcategories
      for (final sub in cat.subcategories) {
        final subTitle =
            sub.getTitle(_langCode).toLowerCase();

        if (subTitle.contains(q)) {
          results.add(_SearchResult(
            icon: sub.icon,
            title: sub.getTitle(_langCode),
            subtitle: cat.getTitle(_langCode),
            color: Color(cat.color),
            onTap: () =>
                _handleSubTap(sub, cat, _langCode),
          ));
        }
      }
    }

    // Search in cached news
    try {
      final makkahNews =
          await HaramainContentService()
              .getNews(ContentSource.makkah);
      final madinahNews =
          await HaramainContentService()
              .getNews(ContentSource.madinah);

      for (final news in [
        ...makkahNews,
        ...madinahNews,
      ]) {
        final title =
            news.getTitle(_langCode).toLowerCase();
        if (title.contains(q) &&
            results.length < 20) {
          results.add(_SearchResult(
            icon: '📰',
            title: news.getTitle(_langCode),
            subtitle: news.source ==
                    ContentSource.makkah
                ? '🕋 Masjid Al-Haram'
                : '🕌 Masjid An-Nabawi',
            color: Theme.of(context)
                .colorScheme
                .primary,
            onTap: () {
              if (news.url != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: news.url!,
                      title: news.getTitle(
                        _langCode,
                      ),
                    ),
                  ),
                );
              }
            },
          ));
        }
      }
    } catch (e) {
      debugPrint('Search news error: $e');
    }

    if (mounted && query == _lastQuery) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  void _handleSubTap(
    SubCategory sub,
    HomeCategory cat,
    String langCode,
  ) {
    if (sub.id.contains('prayer')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const PrayerTimesScreen(),
        ),
      );
      return;
    }

    if (sub.id == 'haram_news' ||
        sub.id == 'nabawi_news' ||
        sub.id.contains('imams') ||
        sub.id.contains('muezzin') ||
        sub.id.contains('lessons') ||
        sub.id == 'scholars') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContentDetailScreen(
            subCategory: sub,
            langCode: langCode,
            categoryColor: Color(cat.color),
          ),
        ),
      );
      return;
    }

    if (sub.url.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WebViewScreen(
            url: sub.url,
            title: sub.getTitle(langCode),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: _langCode == 'ar'
                ? 'ابحث في المحتوى...'
                : 'Search content...',
            hintStyle: const TextStyle(
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
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _controller.clear();
                _search('');
                _focusNode.requestFocus();
              },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return _buildResults();
  }

  // ── Empty State ────────────────────────────────────

  Widget _buildEmptyState() {
    final suggestions = [
      ('🕋', 'Makkah'),
      ('🕌', 'Madinah'),
      ('🕐', 'Prayer'),
      ('📰', 'News'),
      ('🎙️', 'Khutbah'),
      ('👨‍💼', 'Imams'),
      ('📚', 'Lessons'),
      ('👨‍🏫', 'Scholars'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // Suggestions
          Text(
            _langCode == 'ar'
                ? 'بحث سريع'
                : 'Quick Search',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () {
                  _controller.text = s.$2;
                  _search(s.$2);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
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
                          fontSize: 13,
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

          // All Categories
          Text(
            _langCode == 'ar'
                ? 'جميع الأقسام'
                : 'All Categories',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          ...AppConstants.homeCategories
              .map((cat) {
            return ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(cat.color)
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    cat.icon,
                    style: const TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              title: Text(
                cat.getTitle(_langCode),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${cat.subcategories.length} sections',
              ),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Color(cat.color),
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CategoryScreen(
                      category: cat,
                      langCode: _langCode,
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

  // ── No Results ─────────────────────────────────────

  Widget _buildNoResults() {
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
            _langCode == 'ar'
                ? 'لا توجد نتائج'
                : 'No results found',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _langCode == 'ar'
                ? 'جرب: مكة، مدينة، صلاة، أخبار'
                : 'Try: makkah, prayer, news, imam',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Results ────────────────────────────────────────

  Widget _buildResults() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final result = _results[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: result.color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  result.icon,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            title: Text(
              result.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              result.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: result.color,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: result.color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                _langCode == 'ar' ? 'فتح' : 'Open',
                style: TextStyle(
                  fontSize: 11,
                  color: result.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              result.onTap();
            },
          ),
        );
      },
    );
  }
}

// ── Search Result Model ────────────────────────────────

class _SearchResult {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _SearchResult({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}