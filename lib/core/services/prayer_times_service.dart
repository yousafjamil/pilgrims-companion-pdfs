import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimesService {
  // Singleton
  static final PrayerTimesService _instance =
      PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  // AlAdhan API - Free, Legal, Accurate
  // Method 4 = Umm Al-Qura (Saudi Arabia official)
  static const String _baseUrl =
      'https://api.aladhan.com/v1/timingsByCity';

  // ── Fetch Prayer Times ──────────────────────────────

  Future<PrayerTimesModel?> getPrayerTimes({
    required String city,
    required String country,
  }) async {
    try {
      // Try cache first
      final cached = await _getCachedTimes(city);
      if (cached != null) return cached;

      // Fetch from API
      final response = await http.get(
        Uri.parse(
          '$_baseUrl?city=$city&country=$country'
          '&method=4', // Umm Al-Qura method
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];
        final date = data['data']['date'];

        final model = PrayerTimesModel(
          city: city,
          fajr: timings['Fajr'],
          sunrise: timings['Sunrise'],
          dhuhr: timings['Dhuhr'],
          asr: timings['Asr'],
          maghrib: timings['Maghrib'],
          isha: timings['Isha'],
          hijriDate: date['hijri']['date'],
          hijriMonth:
              date['hijri']['month']['en'],
          hijriYear: date['hijri']['year'],
          gregorianDate: date['gregorian']
              ['date'],
          fetchedAt: DateTime.now(),
        );

        // Cache it
        await _cacheTimings(city, model);

        return model;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Prayer times error: $e');
      // Return cached even if expired
      return await _getCachedTimes(
        city,
        ignoreExpiry: true,
      );
    }
  }

  // ── Get Both Cities ─────────────────────────────────

  Future<Map<String, PrayerTimesModel?>>
      getBothCities() async {
    final results = await Future.wait([
      getPrayerTimes(city: 'Makkah', country: 'SA'),
      getPrayerTimes(city: 'Medina', country: 'SA'),
    ]);

    return {
      'makkah': results[0],
      'madinah': results[1],
    };
  }

  // ── Cache ────────────────────────────────────────────

  Future<void> _cacheTimings(
    String city,
    PrayerTimesModel model,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'prayer_times_${city.toLowerCase()}',
        json.encode(model.toJson()),
      );
    } catch (e) {
      debugPrint('❌ Cache error: $e');
    }
  }

  Future<PrayerTimesModel?> _getCachedTimes(
    String city, {
    bool ignoreExpiry = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(
        'prayer_times_${city.toLowerCase()}',
      );

      if (cached == null) return null;

      final model = PrayerTimesModel.fromJson(
        json.decode(cached),
      );

      // Check if cache is from today
      if (!ignoreExpiry) {
        final now = DateTime.now();
        final fetchedAt = model.fetchedAt;
        if (fetchedAt == null) return null;

        final isToday =
            now.year == fetchedAt.year &&
            now.month == fetchedAt.month &&
            now.day == fetchedAt.day;

        if (!isToday) return null;
      }

      return model;
    } catch (e) {
      return null;
    }
  }
}

// ── Prayer Times Model ─────────────────────────────────

class PrayerTimesModel {
  final String city;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String gregorianDate;
  final DateTime? fetchedAt;

  PrayerTimesModel({
    required this.city,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.gregorianDate,
    this.fetchedAt,
  });

  // Get next prayer
  String getNextPrayer() {
    final now = TimeOfDay.now();
    final prayers = getPrayersList();

    for (final prayer in prayers) {
      if (prayer.id == 'sunrise') continue;
      final time = _parseTime(prayer.time);
      if (time != null) {
        if (time.hour > now.hour ||
            (time.hour == now.hour &&
                time.minute > now.minute)) {
          return prayer.name;
        }
      }
    }
    return fajr; // Next day Fajr
  }

  // Get next prayer time
  String getNextPrayerTime() {
    final now = TimeOfDay.now();
    final prayers = getPrayersList();

    for (final prayer in prayers) {
      if (prayer.id == 'sunrise') continue;
      final time = _parseTime(prayer.time);
      if (time != null) {
        if (time.hour > now.hour ||
            (time.hour == now.hour &&
                time.minute > now.minute)) {
          return prayer.time;
        }
      }
    }
    return fajr;
  }

  // Minutes until next prayer
  int minutesUntilNextPrayer() {
    final now = DateTime.now();
    final prayers = getPrayersList();

    for (final prayer in prayers) {
      if (prayer.id == 'sunrise') continue;
      final time = _parseTime(prayer.time);
      if (time != null) {
        final prayerTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        if (prayerTime.isAfter(now)) {
          return prayerTime
              .difference(now)
              .inMinutes;
        }
      }
    }
    return 0;
  }

  TimeOfDay? _parseTime(String time) {
    try {
      // Remove (BST) etc
      final clean = time.split(' ')[0];
      final parts = clean.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (_) {
      return null;
    }
  }

  List<PrayerItem> getPrayersList() {
    return [
      PrayerItem(
        id: 'fajr',
        name: 'Fajr',
        nameAr: 'الفجر',
        time: fajr,
        icon: '🌙',
      ),
      PrayerItem(
        id: 'sunrise',
        name: 'Sunrise',
        nameAr: 'الشروق',
        time: sunrise,
        icon: '🌅',
      ),
      PrayerItem(
        id: 'dhuhr',
        name: 'Dhuhr',
        nameAr: 'الظهر',
        time: dhuhr,
        icon: '☀️',
      ),
      PrayerItem(
        id: 'asr',
        name: 'Asr',
        nameAr: 'العصر',
        time: asr,
        icon: '🌤️',
      ),
      PrayerItem(
        id: 'maghrib',
        name: 'Maghrib',
        nameAr: 'المغرب',
        time: maghrib,
        icon: '🌆',
      ),
      PrayerItem(
        id: 'isha',
        name: 'Isha',
        nameAr: 'العشاء',
        time: isha,
        icon: '🌃',
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'hijriDate': hijriDate,
      'hijriMonth': hijriMonth,
      'hijriYear': hijriYear,
      'gregorianDate': gregorianDate,
      'fetchedAt':
          fetchedAt?.toIso8601String(),
    };
  }

  factory PrayerTimesModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PrayerTimesModel(
      city: json['city'],
      fajr: json['fajr'],
      sunrise: json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
      hijriDate: json['hijriDate'],
      hijriMonth: json['hijriMonth'],
      hijriYear: json['hijriYear'],
      gregorianDate: json['gregorianDate'],
      fetchedAt: json['fetchedAt'] != null
          ? DateTime.parse(json['fetchedAt'])
          : null,
    );
  }
}

class PrayerItem {
  final String id;
  final String name;
  final String nameAr;
  final String time;
  final String icon;

  PrayerItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.time,
    required this.icon,
  });
}

void debugPrint(String message) {
  // ignore: avoid_print
  print(message);
}