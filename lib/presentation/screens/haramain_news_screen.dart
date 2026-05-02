import 'package:flutter/material.dart';
import '../../core/services/news_service.dart';
import 'webview_screen.dart';

class HaramainNewsScreen extends StatefulWidget {
  const HaramainNewsScreen({super.key});

  @override
  State<HaramainNewsScreen> createState() =>
      _HaramainNewsScreenState();
}

class _HaramainNewsScreenState
    extends State<HaramainNewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NewsItem> _makkahNews = [];
  List<NewsItem> _madinahNews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _loadNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        NewsService().getMakkahNews(),
        NewsService().getMadinahNews(),
      ]);

      setState(() {
        _makkahNews = results[0];
        _madinahNews = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load news. Check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('📰', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Haramain News'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadNews,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WebViewScreen(
                    url: 'https://prh.gov.sa',
                    title: 'PRH Official Website',
                  ),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(
              icon: Text(
                '🕋',
                style: TextStyle(fontSize: 18),
              ),
              text: 'Al-Haram',
            ),
            Tab(
              icon: Text(
                '🕌',
                style: TextStyle(fontSize: 18),
              ),
              text: 'An-Nabawi',
            ),
          ],
        ),
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
            Text('Loading latest news...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNews,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildNewsList(_makkahNews, 'makkah'),
        _buildNewsList(_madinahNews, 'madinah'),
      ],
    );
  }

  Widget _buildNewsList(
    List<NewsItem> items,
    String source,
  ) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '📰',
              style: TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'No news available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: source == 'makkah'
                          ? 'https://prh.gov.sa/المسجد-الحرام/makkah-news'
                          : 'https://prh.gov.sa/المسجد-النبوي/madina-news',
                      title: source == 'makkah'
                          ? 'Makkah News'
                          : 'Madinah News',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.open_in_browser_rounded),
              label: const Text('View on Website'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNews,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildNewsCard(items[index]);
        },
      ),
    );
  }

  Widget _buildNewsCard(NewsItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url: item.url,
              title: item.title,
            ),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Image
            if (item.imageUrl != null)
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    child: const Center(
                      child: Text(
                        '🕌',
                        style:
                            TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  loadingBuilder: (_, child,
                      loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Container(
                      color: Colors.grey
                          .withOpacity(0.1),
                      child: const Center(
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 100,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.08),
                child: const Center(
                  child: Text(
                    '🕌',
                    style: TextStyle(fontSize: 40),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Source badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.source == 'makkah'
                          ? '🕋 Masjid Al-Haram'
                          : '🕌 Masjid An-Nabawi',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textDirection: TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Date & Read More
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.date,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        'Read More →',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          fontWeight: FontWeight.w600,
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