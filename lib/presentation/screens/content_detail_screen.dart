import 'package:flutter/material.dart';
import '../../app/app_constants.dart';
import '../../core/services/haramain_content_service.dart';
import '../../data/models/content_models.dart';
import 'webview_screen.dart';

class ContentDetailScreen extends StatefulWidget {
  final SubCategory subCategory;
  final String langCode;
  final Color categoryColor;

  const ContentDetailScreen({
    super.key,
    required this.subCategory,
    required this.langCode,
    required this.categoryColor,
  });

  @override
  State<ContentDetailScreen> createState() =>
      _ContentDetailScreenState();
}

class _ContentDetailScreenState
    extends State<ContentDetailScreen> {
  bool _isLoading = true;
  List<dynamic> _items = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = HaramainContentService();
      List<dynamic> items = [];

      final id = widget.subCategory.id;

      if (id == 'haram_news') {
        items = await service.getNews(
          ContentSource.makkah,
        );
      } else if (id == 'nabawi_news') {
        items = await service.getNews(
          ContentSource.madinah,
        );
      } else if (id == 'haram_imams') {
        items = await service.getSchedules(
          type: ScheduleType.imam,
          source: ContentSource.makkah,
        );
      } else if (id == 'nabawi_imams') {
        items = await service.getSchedules(
          type: ScheduleType.imam,
          source: ContentSource.madinah,
        );
      } else if (id == 'haram_muezzin') {
        items = await service.getSchedules(
          type: ScheduleType.muezzin,
          source: ContentSource.makkah,
        );
      } else if (id == 'nabawi_muezzin') {
        items = await service.getSchedules(
          type: ScheduleType.muezzin,
          source: ContentSource.madinah,
        );
      } else if (id == 'haram_lessons') {
        items = await service.getSchedules(
          type: ScheduleType.lesson,
          source: ContentSource.makkah,
        );
      } else if (id == 'nabawi_lessons') {
        items = await service.getSchedules(
          type: ScheduleType.lesson,
          source: ContentSource.madinah,
        );
      } else if (id == 'scholars') {
        items = await service.getScholars();
      } else if (id == 'khutbah') {
        items = await service.getKhutbah();
      }

      setState(() {
        _items = items;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.subCategory.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.subCategory
                    .getTitle(widget.langCode),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (widget.subCategory.url.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.open_in_browser_rounded,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WebViewScreen(
                      url: widget.subCategory.url,
                      title: widget.subCategory
                          .getTitle(widget.langCode),
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadContent,
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
            Text('Loading content...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              const Text(
                'No Connection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Showing cached content or '
                'connect to refresh',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadContent,
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text('Retry'),
              ),
              if (widget
                  .subCategory.url.isNotEmpty) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            WebViewScreen(
                          url:
                              widget.subCategory.url,
                          title: widget.subCategory
                              .getTitle(
                            widget.langCode,
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.open_in_browser_rounded,
                  ),
                  label: const Text('View Online'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.subCategory.icon,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            const Text(
              'No content available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.subCategory.url.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WebViewScreen(
                        url: widget.subCategory.url,
                        title: widget.subCategory
                            .getTitle(widget.langCode),
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.open_in_browser_rounded,
                ),
                label: const Text('View on Website'),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadContent,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          if (item is HaramainContent) {
            return _buildContentCard(item);
          } else if (item is ScheduleModel) {
            return _buildScheduleCard(item);
          }
          return const SizedBox();
        },
      ),
    );
  }

  // ── Content Card (News/Khutbah) ───────────────────

  Widget _buildContentCard(HaramainContent item) {
    return GestureDetector(
      onTap: () {
        if (item.url != null &&
            item.url!.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => WebViewScreen(
                url: item.url!,
                title: item.getTitle(
                  widget.langCode,
                ),
              ),
            ),
          );
        }
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
                height: 160,
                width: double.infinity,
                child: Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(
                    height: 160,
                    color:
                        widget.categoryColor
                            .withOpacity(0.1),
                    child: Center(
                      child: Text(
                        widget.subCategory.icon,
                        style: const TextStyle(
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 80,
                width: double.infinity,
                color: widget.categoryColor
                    .withOpacity(0.08),
                child: Center(
                  child: Text(
                    widget.subCategory.icon,
                    style: const TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
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
                      color: widget.categoryColor
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.source ==
                              ContentSource.makkah
                          ? '🕋 Masjid Al-Haram'
                          : '🕌 Masjid An-Nabawi',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.categoryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Title
                  Text(
                    item.getTitle(widget.langCode),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                    textDirection:
                        TextDirection.rtl,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Read more
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.langCode == 'ar'
                            ? 'قراءة المزيد ←'
                            : 'Read More →',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.categoryColor,
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

  // ── Schedule Card ─────────────────────────────────

  Widget _buildScheduleCard(ScheduleModel item) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),
                child: Image.network(
                  item.imageUrl!,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _defaultAvatar(item),
                ),
              )
            : _defaultAvatar(item),
        title: Text(
          item.getName(widget.langCode),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: item.role != null
            ? Text(
                item.role!,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.categoryColor,
                ),
              )
            : item.time != null
                ? Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color:
                            widget.categoryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.time!,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              widget.categoryColor,
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }

  Widget _defaultAvatar(ScheduleModel item) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: widget.categoryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          _getScheduleIcon(item.type),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  String _getScheduleIcon(ScheduleType type) {
    switch (type) {
      case ScheduleType.imam:
        return '👨‍💼';
      case ScheduleType.muezzin:
        return '📢';
      case ScheduleType.lesson:
        return '📚';
    }
  }
}