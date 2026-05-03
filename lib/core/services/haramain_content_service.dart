import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/content_models.dart';

class HaramainContentService {
  // Singleton
  static final HaramainContentService _instance =
      HaramainContentService._internal();
  factory HaramainContentService() => _instance;
  HaramainContentService._internal();

  static const String _baseUrl = 'https://prh.gov.sa';
  static const String _prayerApiUrl =
      'https://api.aladhan.com/v1/timingsByCity';

  // ── Download ALL Content (for offline) ─────────────

  Future<DownloadResult> downloadAllContent({
    required String languageCode,
    required void Function(String task, double progress)
        onProgress,
  }) async {
    int completed = 0;
    const total = 8;

    void progress(String task) {
      completed++;
      onProgress(task, completed / total);
    }

    try {
      // 1. Prayer times Makkah
      await _fetchAndCachePrayerTimes('Makkah');
      progress('Prayer times - Makkah');

      // 2. Prayer times Madinah
      await _fetchAndCachePrayerTimes('Medina');
      progress('Prayer times - Madinah');

      // 3. Makkah News
      await _fetchAndCacheNews(ContentSource.makkah);
      progress('Masjid Al-Haram news');

      // 4. Madinah News
      await _fetchAndCacheNews(ContentSource.madinah);
      progress('Masjid An-Nabawi news');

      // 5. Imam Schedules
      await _fetchAndCacheSchedules(
        ScheduleType.imam,
        ContentSource.makkah,
      );
      progress('Imam schedules');

      // 6. Lesson Schedules
      await _fetchAndCacheSchedules(
        ScheduleType.lesson,
        ContentSource.makkah,
      );
      progress('Lesson schedules');

      // 7. Khutbah content
      await _fetchAndCacheKhutbah();
      progress('Friday Khutbah');

      // 8. Scholars
      await _fetchAndCacheScholars();
      progress('Scholars & Sheikhs');

      return DownloadResult(
        success: true,
        message: 'All content downloaded successfully!',
      );
    } catch (e) {
      return DownloadResult(
        success: false,
        message: 'Error: $e',
      );
    }
  }

  // ── Prayer Times ─────────────────────────────────────

  Future<FullPrayerTimes?> getPrayerTimes(
    String city,
  ) async {
    final cached = await _getCached<FullPrayerTimes>(
      key: 'prayer_$city',
      fromJson: FullPrayerTimes.fromJson,
      maxAge: const Duration(hours: 12),
    );
    if (cached != null) return cached;

    return await _fetchAndCachePrayerTimes(city);
  }

  Future<FullPrayerTimes?> _fetchAndCachePrayerTimes(
    String city,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_prayerApiUrl?city=$city'
              '&country=SA&method=4',
            ),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final date = data['data']['date'];

        final model = FullPrayerTimes(
          city: city,
          cityAr: city == 'Makkah'
              ? 'مكة المكرمة'
              : 'المدينة المنورة',
          prayers: [
            PrayerEntry(
              id: 'fajr',
              nameEn: 'Fajr',
              nameAr: 'الفجر',
              adhanTime: _cleanTime(timings['Fajr']),
              iqamaTime: null,
              icon: '🌙',
            ),
            PrayerEntry(
              id: 'sunrise',
              nameEn: 'Sunrise',
              nameAr: 'الشروق',
              adhanTime: _cleanTime(timings['Sunrise']),
              icon: '🌅',
            ),
            PrayerEntry(
              id: 'dhuhr',
              nameEn: 'Dhuhr',
              nameAr: 'الظهر',
              adhanTime: _cleanTime(timings['Dhuhr']),
              icon: '☀️',
            ),
            PrayerEntry(
              id: 'asr',
              nameEn: 'Asr',
              nameAr: 'العصر',
              adhanTime: _cleanTime(timings['Asr']),
              icon: '🌤️',
            ),
            PrayerEntry(
              id: 'maghrib',
              nameEn: 'Maghrib',
              nameAr: 'المغرب',
              adhanTime: _cleanTime(timings['Maghrib']),
              icon: '🌆',
            ),
            PrayerEntry(
              id: 'isha',
              nameEn: 'Isha',
              nameAr: 'العشاء',
              adhanTime: _cleanTime(timings['Isha']),
              icon: '🌃',
            ),
          ],
          hijriDate: date['hijri']['day'],
          hijriMonthEn: date['hijri']['month']['en'],
          hijriMonthAr: date['hijri']['month']['ar'],
          hijriYear: date['hijri']['year'],
          gregorianDate: date['gregorian']['date'],
          fetchedAt: DateTime.now(),
        );

        await _saveCache(
          key: 'prayer_$city',
          data: model.toJson(),
        );
        return model;
      }
    } catch (e) {
      print('❌ Prayer times error: $e');
    }
    return null;
  }

  String _cleanTime(String time) {
    return time.split(' ')[0];
  }

  // ── News ─────────────────────────────────────────────

  Future<List<HaramainContent>> getNews(
    ContentSource source,
  ) async {
    final cacheKey = 'news_${source.name}';

    final cached = await _getCachedList<HaramainContent>(
      key: cacheKey,
      fromJson: HaramainContent.fromJson,
      maxAge: const Duration(hours: 6),
    );
    if (cached != null) return cached;

    return await _fetchAndCacheNews(source) ?? [];
  }

  Future<List<HaramainContent>?> _fetchAndCacheNews(
    ContentSource source,
  ) async {
    try {
      final url = source == ContentSource.makkah
          ? '$_baseUrl/المسجد-الحرام/makkah-news'
          : '$_baseUrl/المسجد-النبوي/madina-news';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final items = _parseNewsHtml(
          response.body,
          source,
        );
        await _saveCacheList(
          key: 'news_${source.name}',
          data: items.map((i) => i.toJson()).toList(),
        );
        return items;
      }
    } catch (e) {
      print('❌ News fetch error: $e');
    }
    return [];
  }

  List<HaramainContent> _parseNewsHtml(
    String html,
    ContentSource source,
  ) {
    final items = <HaramainContent>[];

    try {
      final linkPattern = RegExp(
        r'href="(https://prh\.gov\.sa/[^"]+(?:makkah-news|madina-news)/\d+[^"]*)"[^>]*>\s*([^<]{10,200})',
        multiLine: true,
      );

      final imagePattern = RegExp(
        r'<img[^>]+src="(/(?:cache|images)/[^"]+\.(?:jpg|jpeg|png))"',
      );

      final images = imagePattern
          .allMatches(html)
          .map((m) => '$_baseUrl${m.group(1)}')
          .toList();

      int imgIndex = 0;
      int id = 1;
      final seen = <String>{};

      for (final match
          in linkPattern.allMatches(html)) {
        if (items.length >= 15) break;

        final url = match.group(1) ?? '';
        final titleAr =
            match.group(2)?.trim() ?? '';

        if (titleAr.isEmpty ||
            seen.contains(url)) {
          continue;
        }
        seen.add(url);

        items.add(HaramainContent(
          id: '${source.name}_$id',
          titleAr: titleAr,
          titleEn: titleAr,
          imageUrl: imgIndex < images.length
              ? images[imgIndex++]
              : null,
          url: url,
          type: ContentType.news,
          source: source,
          publishedAt: DateTime.now(),
        ));
        id++;
      }
    } catch (e) {
      print('❌ Parse error: $e');
    }

    return items;
  }

  // ── Schedules ─────────────────────────────────────────

  Future<List<ScheduleModel>> getSchedules({
    required ScheduleType type,
    required ContentSource source,
  }) async {
    final cacheKey =
        'schedule_${type.name}_${source.name}';

    final cached = await _getCachedList<ScheduleModel>(
      key: cacheKey,
      fromJson: ScheduleModel.fromJson,
      maxAge: const Duration(days: 7),
    );
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    return await _fetchAndCacheSchedules(
          type,
          source,
        ) ??
        [];
  }

  Future<List<ScheduleModel>?> _fetchAndCacheSchedules(
    ScheduleType type,
    ContentSource source,
  ) async {
    try {
      String url;
      if (source == ContentSource.makkah) {
        url = type == ScheduleType.imam
            ? '$_baseUrl/المسجد-الحرام/جداول-الائمة-مكة-المكرمة'
            : type == ScheduleType.muezzin
                ? '$_baseUrl/المسجد-الحرام/جداول-المؤذنين-مكة-المكرمة'
                : '$_baseUrl/المسجد-الحرام/جداول-الدروس-العلمية-بالمسجد-الحرام';
      } else {
        url = type == ScheduleType.imam
            ? '$_baseUrl/المسجد-النبوي/جداول-الائمة-المدينة-المنورة'
            : type == ScheduleType.muezzin
                ? '$_baseUrl/المسجد-النبوي/جداول-المؤذنين-المدينة-المنورة'
                : '$_baseUrl/المسجد-النبوي/جداول-الدروس-بالمسجد-النبوي';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final schedules = _parseScheduleHtml(
          response.body,
          type,
          source,
        );

        await _saveCacheList(
          key: 'schedule_${type.name}_${source.name}',
          data: schedules
              .map((s) => s.toJson())
              .toList(),
        );
        return schedules;
      }
    } catch (e) {
      print('❌ Schedule error: $e');
    }
    return [];
  }

  List<ScheduleModel> _parseScheduleHtml(
    String html,
    ScheduleType type,
    ContentSource source,
  ) {
    final schedules = <ScheduleModel>[];

    try {
      final namePattern = RegExp(
        r'<td[^>]*>\s*([^\d<]{5,100}?)\s*</td>',
        multiLine: true,
      );

      final imagePattern = RegExp(
        r'src="(/images/elharamain/imems/[^"]+)"',
      );

      final images = imagePattern
          .allMatches(html)
          .map((m) => '$_baseUrl${m.group(1)}')
          .toList();

      int id = 1;
      int imgIndex = 0;
      final seen = <String>{};

      for (final match
          in namePattern.allMatches(html)) {
        if (schedules.length >= 30) break;

        final name = match
                .group(1)
                ?.trim()
                .replaceAll(RegExp(r'\s+'), ' ') ??
            '';

        if (name.isEmpty ||
            name.length < 5 ||
            seen.contains(name)) {
          continue;
        }

        if (name.contains('<') ||
            name.contains('>') ||
            name.contains('http')) {
          continue;
        }

        seen.add(name);

        schedules.add(ScheduleModel(
          id: '${type.name}_${source.name}_$id',
          nameAr: name,
          nameEn: name,
          imageUrl: imgIndex < images.length
              ? images[imgIndex++]
              : null,
          type: type,
          source: source,
        ));
        id++;
      }
    } catch (e) {
      print('❌ Schedule parse error: $e');
    }

    return schedules;
  }

  // ── Khutbah ───────────────────────────────────────────

  Future<List<HaramainContent>> getKhutbah() async {
    final cached =
        await _getCachedList<HaramainContent>(
      key: 'khutbah',
      fromJson: HaramainContent.fromJson,
      maxAge: const Duration(days: 7),
    );
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return await _fetchAndCacheKhutbah() ?? [];
  }

  Future<List<HaramainContent>?>
      _fetchAndCacheKhutbah() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/الخطب-بالحرمين'),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final items = _parseKhutbahHtml(
          response.body,
        );
        await _saveCacheList(
          key: 'khutbah',
          data: items.map((i) => i.toJson()).toList(),
        );
        return items;
      }
    } catch (e) {
      print('❌ Khutbah error: $e');
    }
    return [];
  }

  List<HaramainContent> _parseKhutbahHtml(
    String html,
  ) {
    final items = <HaramainContent>[];
    try {
      final pattern = RegExp(
        r'href="(https://prh\.gov\.sa/[^"]*(?:خطب|khutb)[^"]*)"[^>]*>\s*([^<]{10,200})',
        multiLine: true,
      );

      int id = 1;
      for (final m in pattern.allMatches(html)) {
        if (items.length >= 20) break;
        final url = m.group(1) ?? '';
        final title = m.group(2)?.trim() ?? '';
        if (title.isEmpty) continue;

        items.add(HaramainContent(
          id: 'khutbah_$id',
          titleAr: title,
          titleEn: title,
          url: url,
          type: ContentType.khutbah,
          source: ContentSource.general,
        ));
        id++;
      }
    } catch (e) {
      print('❌ Khutbah parse: $e');
    }
    return items;
  }

  // ── Scholars ──────────────────────────────────────────

  Future<List<HaramainContent>> getScholars() async {
    final cached =
        await _getCachedList<HaramainContent>(
      key: 'scholars',
      fromJson: HaramainContent.fromJson,
      maxAge: const Duration(days: 30),
    );
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return await _fetchAndCacheScholars() ?? [];
  }

  Future<List<HaramainContent>?>
      _fetchAndCacheScholars() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/علماء-ومشائخ-الحرمين',
            ),
            headers: {'User-Agent': 'Mozilla/5.0'},
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final items = _parseScholarsHtml(
          response.body,
        );
        await _saveCacheList(
          key: 'scholars',
          data: items.map((i) => i.toJson()).toList(),
        );
        return items;
      }
    } catch (e) {
      print('❌ Scholars error: $e');
    }
    return [];
  }

  List<HaramainContent> _parseScholarsHtml(
    String html,
  ) {
    final items = <HaramainContent>[];
    try {
      final imagePattern = RegExp(
        r'src="(/images/elharamain/[^"]+\.(?:jpg|jpeg|png))"',
      );
      final namePattern = RegExp(
        r'<(?:h[1-6]|strong|b)[^>]*>\s*([^<]{10,100})\s*</(?:h[1-6]|strong|b)>',
        multiLine: true,
      );

      final images = imagePattern
          .allMatches(html)
          .map((m) => '$_baseUrl${m.group(1)}')
          .toList();

      int id = 1;
      int imgIdx = 0;

      for (final m in namePattern.allMatches(html)) {
        if (items.length >= 30) break;
        final name = m.group(1)?.trim() ?? '';
        if (name.isEmpty || name.length < 5) {
          continue;
        }

        items.add(HaramainContent(
          id: 'scholar_$id',
          titleAr: name,
          titleEn: name,
          imageUrl: imgIdx < images.length
              ? images[imgIdx++]
              : null,
          url: '$_baseUrl/علماء-ومشائخ-الحرمين',
          type: ContentType.scholar,
          source: ContentSource.general,
        ));
        id++;
      }
    } catch (e) {
      print('❌ Scholars parse: $e');
    }
    return items;
  }

  // ── Cache Helpers ─────────────────────────────────────

  Future<void> _saveCache({
    required String key,
    required Map<String, dynamic> data,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      await prefs.setString(
        'cache_$key',
        json.encode({
          'data': data,
          'savedAt':
              DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('❌ Save cache error: $e');
    }
  }

  Future<void> _saveCacheList({
    required String key,
    required List<Map<String, dynamic>> data,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      await prefs.setString(
        'cache_$key',
        json.encode({
          'data': data,
          'savedAt':
              DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      print('❌ Save cache list error: $e');
    }
  }

  Future<T?> _getCached<T>({
    required String key,
    required T Function(Map<String, dynamic>)
        fromJson,
    required Duration maxAge,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      final raw = prefs.getString('cache_$key');
      if (raw == null) return null;

      final wrapper = json.decode(raw);
      final savedAt = DateTime.tryParse(
        wrapper['savedAt'] ?? '',
      );

      if (savedAt == null ||
          DateTime.now().difference(savedAt) >
              maxAge) {
        return null;
      }

      return fromJson(wrapper['data']);
    } catch (e) {
      return null;
    }
  }

  Future<List<T>?> _getCachedList<T>({
    required String key,
    required T Function(Map<String, dynamic>)
        fromJson,
    required Duration maxAge,
  }) async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      final raw = prefs.getString('cache_$key');
      if (raw == null) return null;

      final wrapper = json.decode(raw);
      final savedAt = DateTime.tryParse(
        wrapper['savedAt'] ?? '',
      );

      if (savedAt == null ||
          DateTime.now().difference(savedAt) >
              maxAge) {
        return null;
      }

      return (wrapper['data'] as List)
          .map((item) => fromJson(item))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ── Clear Cache ───────────────────────────────────────

  Future<void> clearAllCache() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().toList()) {
        if (k.startsWith('cache_')) {
          await prefs.remove(k);
        }
      }
      print('🗑️ All cache cleared');
    } catch (e) {
      print('❌ Clear cache error: $e');
    }
  }

  // ── Check if Downloaded ───────────────────────────────

  Future<bool> isContentDownloaded() async {
    try {
      final prefs =
          await SharedPreferences.getInstance();
      return prefs
              .containsKey('cache_prayer_Makkah') &&
          prefs.containsKey('cache_news_makkah');
    } catch (_) {
      return false;
    }
  }
}

// ── Download Result ───────────────────────────────────

class DownloadResult {
  final bool success;
  final String message;

  DownloadResult({
    required this.success,
    required this.message,
  });
}