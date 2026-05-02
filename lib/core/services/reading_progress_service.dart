import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgressService {
  static const String _prefix = 'reading_progress_';
  static const String _lastOpenedPrefix = 'last_opened_';

  // Singleton
  static final ReadingProgressService _instance =
      ReadingProgressService._internal();
  factory ReadingProgressService() => _instance;
  ReadingProgressService._internal();

  // ── Save Progress ──────────────────────────────────────────
  Future<void> saveProgress({
    required String sectionId,
    required int currentPage,
    required int totalPages,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save current page
      await prefs.setInt(
        '$_prefix${sectionId}_page',
        currentPage,
      );

      // Save total pages
      await prefs.setInt(
        '$_prefix${sectionId}_total',
        totalPages,
      );

      // Save last opened time
      await prefs.setString(
        '$_lastOpenedPrefix$sectionId',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('❌ Save progress error: $e');
    }
  }

  // ── Get Progress ───────────────────────────────────────────
  Future<ReadingProgress?> getProgress(
    String sectionId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final currentPage =
          prefs.getInt('${_prefix}${sectionId}_page');
      final totalPages =
          prefs.getInt('${_prefix}${sectionId}_total');
      final lastOpenedStr =
          prefs.getString('$_lastOpenedPrefix$sectionId');

      if (currentPage == null || totalPages == null) {
        return null;
      }

      return ReadingProgress(
        sectionId: sectionId,
        currentPage: currentPage,
        totalPages: totalPages,
        lastOpened: lastOpenedStr != null
            ? DateTime.parse(lastOpenedStr)
            : null,
      );
    } catch (e) {
      print('❌ Get progress error: $e');
      return null;
    }
  }

  // ── Get All Progress ───────────────────────────────────────
  Future<Map<String, ReadingProgress>> getAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, ReadingProgress> allProgress = {};

      for (final key in prefs.getKeys()) {
        if (key.startsWith(_prefix) &&
            key.endsWith('_page')) {
          final sectionId = key
              .replaceFirst(_prefix, '')
              .replaceAll('_page', '');

          final progress = await getProgress(sectionId);
          if (progress != null) {
            allProgress[sectionId] = progress;
          }
        }
      }

      return allProgress;
    } catch (e) {
      print('❌ Get all progress error: $e');
      return {};
    }
  }

  // ── Clear Progress ─────────────────────────────────────────
  Future<void> clearProgress(String sectionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_prefix}${sectionId}_page');
      await prefs.remove('${_prefix}${sectionId}_total');
      await prefs.remove('$_lastOpenedPrefix$sectionId');
    } catch (e) {
      print('❌ Clear progress error: $e');
    }
  }

  // ── Clear All Progress ─────────────────────────────────────
  Future<void> clearAllProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in prefs.getKeys().toList()) {
        if (key.startsWith(_prefix) ||
            key.startsWith(_lastOpenedPrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      print('❌ Clear all progress error: $e');
    }
  }
}

// ── Reading Progress Model ─────────────────────────────────────

class ReadingProgress {
  final String sectionId;
  final int currentPage;
  final int totalPages;
  final DateTime? lastOpened;

  ReadingProgress({
    required this.sectionId,
    required this.currentPage,
    required this.totalPages,
    this.lastOpened,
  });

  // Progress percentage 0.0 to 1.0
  double get progressPercentage {
    if (totalPages == 0) return 0.0;
    return (currentPage / totalPages).clamp(0.0, 1.0);
  }

  // Is completed
  bool get isCompleted => currentPage >= totalPages;

  // Progress text
  String get progressText =>
      'Page $currentPage of $totalPages';

  // Percentage text
  String get percentageText =>
      '${(progressPercentage * 100).toStringAsFixed(0)}%';
}