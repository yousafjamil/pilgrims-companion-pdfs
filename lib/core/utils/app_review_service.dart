import 'package:shared_preferences/shared_preferences.dart';

class AppReviewService {
  static const String _launchCountKey = 'launch_count';
  static const String _lastReviewKey = 'last_review_date';
  static const int _minLaunchCount = 5;

  // Increment launch count
  static Future<void> incrementLaunchCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_launchCountKey) ?? 0;
    await prefs.setInt(_launchCountKey, count + 1);
  }

  // Check if should show review
  static Future<bool> shouldShowReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = prefs.getInt(_launchCountKey) ?? 0;
      final lastReview = prefs.getString(_lastReviewKey);

      // Show after 5 launches
      if (count < _minLaunchCount) return false;

      // Don't show if reviewed in last 30 days
      if (lastReview != null) {
        final lastDate = DateTime.parse(lastReview);
        final daysSince =
            DateTime.now().difference(lastDate).inDays;
        if (daysSince < 30) return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Mark as reviewed
  static Future<void> markAsReviewed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastReviewKey,
      DateTime.now().toIso8601String(),
    );
  }
}