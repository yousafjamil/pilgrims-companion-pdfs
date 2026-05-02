import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NewsService {
  static final NewsService _instance =
      NewsService._internal();
  factory NewsService() => _instance;
  NewsService._internal();

  // PRH Website URLs
  static const String _makkahNewsUrl =
      'https://prh.gov.sa/المسجد-الحرام/makkah-news';
  static const String _madinahNewsUrl =
      'https://prh.gov.sa/المسجد-النبوي/madina-news';
  static const String _baseImageUrl =
      'https://prh.gov.sa';

  // ── Fetch News (Parse HTML) ─────────────────────────

  Future<List<NewsItem>> getMakkahNews() async {
    return await _fetchNews(
      _makkahNewsUrl,
      'makkah',
    );
  }

  Future<List<NewsItem>> getMadinahNews() async {
    return await _fetchNews(
      _madinahNewsUrl,
      'madinah',
    );
  }

  Future<List<NewsItem>> _fetchNews(
    String url,
    String cacheKey,
  ) async {
    try {
      // Try cache first (1 hour)
      final cached = await _getCachedNews(cacheKey);
      if (cached != null) return cached;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final news = _parseNewsFromHtml(
          response.body,
          cacheKey,
        );

        // Cache it
        await _cacheNews(cacheKey, news);

        return news;
      }

      return [];
    } catch (e) {
      print('❌ News fetch error: $e');
      // Return cached even if expired
      return await _getCachedNews(
            cacheKey,
            ignoreExpiry: true,
          ) ??
          [];
    }
  }

  // ── Parse HTML ───────────────────────────────────────

  List<NewsItem> _parseNewsFromHtml(
    String html,
    String source,
  ) {
    final List<NewsItem> items = [];

    try {
      // Simple regex to extract news items
      // Pattern: extract title, link, image, date

      // Extract article blocks
      final articlePattern = RegExp(
        r'<h2[^>]*>\s*<a[^>]*href="([^"]+)"[^>]*>([^<]+)</a>\s*</h2>[\s\S]*?'
        r'(\d{1,2}/\d{1,2}/\d{4}|\d{4}-\d{2}-\d{2})',
        multiLine: true,
      );

      // Extract images
      final imagePattern = RegExp(
        r'<img[^>]*src="(/images/[^"]+\.(?:jpg|jpeg|png|gif))"',
      );

      final images = imagePattern
          .allMatches(html)
          .map((m) => '$_baseImageUrl${m.group(1)}')
          .toList();

      int imageIndex = 0;
      int id = 1;

      final matches =
          articlePattern.allMatches(html);

      for (final match in matches) {
        if (items.length >= 20) break;

        final link = match.group(1) ?? '';
        final title = match.group(2)?.trim() ?? '';
        final date = match.group(3) ?? '';

        if (title.isEmpty || link.isEmpty) {
          continue;
        }

        final imageUrl = imageIndex < images.length
            ? images[imageIndex]
            : null;
        imageIndex++;

        final fullLink = link.startsWith('http')
            ? link
            : 'https://prh.gov.sa$link';

        items.add(NewsItem(
          id: id++,
          title: title,
          url: fullLink,
          imageUrl: imageUrl,
          date: date,
          source: source,
        ));
      }

      // If regex didn't work, create fallback items
      if (items.isEmpty) {
        return _getFallbackNews(source);
      }

      return items;
    } catch (e) {
      print('❌ Parse error: $e');
      return _getFallbackNews(source);
    }
  }

  // ── Fallback News ────────────────────────────────────

  List<NewsItem> _getFallbackNews(String source) {
    if (source == 'makkah') {
      return [
        NewsItem(
          id: 1,
          title:
              'أخبار المسجد الحرام',
          url:
              'https://prh.gov.sa/المسجد-الحرام/makkah-news',
          imageUrl: null,
          date: DateTime.now()
              .toString()
              .split(' ')[0],
          source: 'makkah',
        ),
      ];
    } else {
      return [
        NewsItem(
          id: 1,
          title: 'أخبار المسجد النبوي',
          url:
              'https://prh.gov.sa/المسجد-النبوي/madina-news',
          imageUrl: null,
          date: DateTime.now()
              .toString()
              .split(' ')[0],
          source: 'madinah',
        ),
      ];
    }
  }

  // ── Cache ────────────────────────────────────────────

  Future<void> _cacheNews(
    String key,
    List<NewsItem> items,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'items': items.map((i) => i.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await prefs.setString(
        'news_$key',
        json.encode(data),
      );
    } catch (e) {
      print('❌ Cache news error: $e');
    }
  }

  Future<List<NewsItem>?> _getCachedNews(
    String key, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('news_$key');
      if (cached == null) return null;

      final data = json.decode(cached);
      final cachedAt =
          DateTime.parse(data['cachedAt']);

      // 1 hour cache
      if (!ignoreExpiry) {
        final age = DateTime.now()
            .difference(cachedAt)
            .inHours;
        if (age >= 1) return null;
      }

      final items = (data['items'] as List)
          .map((i) => NewsItem.fromJson(i))
          .toList();

      return items;
    } catch (e) {
      return null;
    }
  }
}

// ── News Item Model ────────────────────────────────────

class NewsItem {
  final int id;
  final String title;
  final String url;
  final String? imageUrl;
  final String date;
  final String source;

  NewsItem({
    required this.id,
    required this.title,
    required this.url,
    this.imageUrl,
    required this.date,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'imageUrl': imageUrl,
      'date': date,
      'source': source,
    };
  }

  factory NewsItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      date: json['date'],
      source: json['source'],
    );
  }
}