// ── All Content Models ─────────────────────────────────

class HaramainContent {
  final String id;
  final String titleAr;
  final String titleEn;
  final String? contentAr;
  final String? contentEn;
  final String? imageUrl;
  final String? url;
  final DateTime? publishedAt;
  final ContentType type;
  final ContentSource source;

  HaramainContent({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    this.contentAr,
    this.contentEn,
    this.imageUrl,
    this.url,
    this.publishedAt,
    required this.type,
    required this.source,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar') return titleAr;
    return titleEn.isNotEmpty ? titleEn : titleAr;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleAr': titleAr,
        'titleEn': titleEn,
        'contentAr': contentAr,
        'contentEn': contentEn,
        'imageUrl': imageUrl,
        'url': url,
        'publishedAt': publishedAt?.toIso8601String(),
        'type': type.name,
        'source': source.name,
      };

  factory HaramainContent.fromJson(
    Map<String, dynamic> json,
  ) =>
      HaramainContent(
        id: json['id'] ?? '',
        titleAr: json['titleAr'] ?? '',
        titleEn: json['titleEn'] ?? '',
        contentAr: json['contentAr'],
        contentEn: json['contentEn'],
        imageUrl: json['imageUrl'],
        url: json['url'],
        publishedAt: json['publishedAt'] != null
            ? DateTime.tryParse(json['publishedAt'])
            : null,
        type: ContentType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ContentType.news,
        ),
        source: ContentSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => ContentSource.makkah,
        ),
      );
}

enum ContentType {
  news,
  khutbah,
  lesson,
  scholar,
  recitation,
  schedule,
  imamSchedule,
  muezzinSchedule,
  qaAndA,
}

enum ContentSource {
  makkah,
  madinah,
  general,
}

// ── Prayer Times with Iqama ────────────────────────────

class FullPrayerTimes {
  final String city;
  final String cityAr;
  final List<PrayerEntry> prayers;
  final String hijriDate;
  final String hijriMonthEn;
  final String hijriMonthAr;
  final String hijriYear;
  final String gregorianDate;
  final DateTime fetchedAt;

  FullPrayerTimes({
    required this.city,
    required this.cityAr,
    required this.prayers,
    required this.hijriDate,
    required this.hijriMonthEn,
    required this.hijriMonthAr,
    required this.hijriYear,
    required this.gregorianDate,
    required this.fetchedAt,
  });

  PrayerEntry? getNextPrayer() {
    final now = DateTime.now();
    final currentMinutes =
        now.hour * 60 + now.minute;

    for (final prayer in prayers) {
      if (prayer.id == 'sunrise') continue;
      final parts =
          prayer.adhanTime.split(':');
      if (parts.length >= 2) {
        final prayerMinutes =
            int.parse(parts[0]) * 60 +
            int.parse(parts[1]);
        if (prayerMinutes > currentMinutes) {
          return prayer;
        }
      }
    }
    // Return Fajr (next day)
    return prayers.firstWhere(
      (p) => p.id == 'fajr',
      orElse: () => prayers.first,
    );
  }

  int minutesUntilNext() {
    final next = getNextPrayer();
    if (next == null) return 0;

    final now = DateTime.now();
    final parts = next.adhanTime.split(':');
    if (parts.length < 2) return 0;

    var prayerTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    if (prayerTime.isBefore(now)) {
      prayerTime =
          prayerTime.add(const Duration(days: 1));
    }

    return prayerTime.difference(now).inMinutes;
  }

  Map<String, dynamic> toJson() => {
        'city': city,
        'cityAr': cityAr,
        'prayers':
            prayers.map((p) => p.toJson()).toList(),
        'hijriDate': hijriDate,
        'hijriMonthEn': hijriMonthEn,
        'hijriMonthAr': hijriMonthAr,
        'hijriYear': hijriYear,
        'gregorianDate': gregorianDate,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory FullPrayerTimes.fromJson(
    Map<String, dynamic> json,
  ) =>
      FullPrayerTimes(
        city: json['city'] ?? '',
        cityAr: json['cityAr'] ?? '',
        prayers: (json['prayers'] as List? ?? [])
            .map((p) => PrayerEntry.fromJson(p))
            .toList(),
        hijriDate: json['hijriDate'] ?? '',
        hijriMonthEn: json['hijriMonthEn'] ?? '',
        hijriMonthAr: json['hijriMonthAr'] ?? '',
        hijriYear: json['hijriYear'] ?? '',
        gregorianDate: json['gregorianDate'] ?? '',
        fetchedAt: DateTime.tryParse(
                json['fetchedAt'] ?? '') ??
            DateTime.now(),
      );
}

class PrayerEntry {
  final String id;
  final String nameEn;
  final String nameAr;
  final String adhanTime;
  final String? iqamaTime;
  final String icon;

  PrayerEntry({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.adhanTime,
    this.iqamaTime,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'adhanTime': adhanTime,
        'iqamaTime': iqamaTime,
        'icon': icon,
      };

  factory PrayerEntry.fromJson(
    Map<String, dynamic> json,
  ) =>
      PrayerEntry(
        id: json['id'] ?? '',
        nameEn: json['nameEn'] ?? '',
        nameAr: json['nameAr'] ?? '',
        adhanTime: json['adhanTime'] ?? '',
        iqamaTime: json['iqamaTime'],
        icon: json['icon'] ?? '🕌',
      );
}

// ── Schedule Model ─────────────────────────────────────

class ScheduleModel {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? role;
  final String? time;
  final String? imageUrl;
  final ScheduleType type;
  final ContentSource source;

  ScheduleModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.role,
    this.time,
    this.imageUrl,
    required this.type,
    required this.source,
  });

  String getName(String langCode) {
    if (langCode == 'ar') return nameAr;
    return nameEn.isNotEmpty ? nameEn : nameAr;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameAr': nameAr,
        'nameEn': nameEn,
        'role': role,
        'time': time,
        'imageUrl': imageUrl,
        'type': type.name,
        'source': source.name,
      };

  factory ScheduleModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      ScheduleModel(
        id: json['id'] ?? '',
        nameAr: json['nameAr'] ?? '',
        nameEn: json['nameEn'] ?? '',
        role: json['role'],
        time: json['time'],
        imageUrl: json['imageUrl'],
        type: ScheduleType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ScheduleType.imam,
        ),
        source: ContentSource.values.firstWhere(
          (e) => e.name == json['source'],
          orElse: () => ContentSource.makkah,
        ),
      );
}

enum ScheduleType {
  imam,
  muezzin,
  lesson,
}