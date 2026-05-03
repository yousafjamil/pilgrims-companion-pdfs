import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/haramain_content_service.dart';
import '../../data/models/content_models.dart';
import 'prayer_times_screen.dart';
import 'webview_screen.dart';
import 'content_detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  final HomeCategory category;
  final String langCode;

  const CategoryScreen({
    super.key,
    required this.category,
    required this.langCode,
  });

  @override
  State<CategoryScreen> createState() =>
      _CategoryScreenState();
}

class _CategoryScreenState
    extends State<CategoryScreen> {
  final Color _categoryColor;

  _CategoryScreenState()
      : _categoryColor = Colors.green;

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.category.color);
    final langCode =
        StorageService.instance.getLanguage() ??
        'en';

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sliver App Bar ───────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
            iconTheme: const IconThemeData(
              color: Colors.white,
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.category.getTitle(langCode),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter:
                            _CategoryPatternPainter(
                          color: color,
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.category.icon,
                        style: const TextStyle(
                          fontSize: 80,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Subcategories ────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final sub = widget
                      .category.subcategories[index];
                  return TweenAnimationBuilder<double>(
                    tween:
                        Tween<double>(begin: 0, end: 1),
                    duration: Duration(
                      milliseconds: 200 + (index * 80),
                    ),
                    builder: (_, val, child) => Opacity(
                      opacity: val,
                      child: Transform.translate(
                        offset:
                            Offset(0, 20 * (1 - val)),
                        child: child,
                      ),
                    ),
                    child: _buildSubCategoryCard(
                      context,
                      sub,
                      color,
                      langCode,
                    ),
                  );
                },
                childCount: widget
                    .category.subcategories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(
    BuildContext context,
    SubCategory sub,
    Color color,
    String langCode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              sub.icon,
              style: const TextStyle(fontSize: 26),
            ),
          ),
        ),
        title: Text(
          sub.getTitle(langCode),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          _getSubtitle(sub.id, langCode),
          style:
              Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: color,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          _handleSubCategoryTap(
            context,
            sub,
            langCode,
          );
        },
      ),
    );
  }

  void _handleSubCategoryTap(
    BuildContext context,
    SubCategory sub,
    String langCode,
  ) {
    // Prayer times - open prayer screen
    if (sub.id == 'haram_prayer' ||
        sub.id == 'nabawi_prayer' ||
        sub.id == 'prayer_makkah' ||
        sub.id == 'prayer_madinah') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              const PrayerTimesScreen(),
        ),
      );
      return;
    }

    // Quran section
    if (sub.id == 'quran') {
      // Show Quran from QuranDownloader
      _showQuranDialog(context, langCode);
      return;
    }

    // News sections
    if (sub.id == 'haram_news' ||
        sub.id == 'nabawi_news') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContentDetailScreen(
            subCategory: sub,
            langCode: langCode,
            categoryColor:
                Color(widget.category.color),
          ),
        ),
      );
      return;
    }

    // Schedules - show content screen
    if (sub.id.contains('imams') ||
        sub.id.contains('muezzin') ||
        sub.id.contains('lessons') ||
        sub.id == 'scholars') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ContentDetailScreen(
            subCategory: sub,
            langCode: langCode,
            categoryColor:
                Color(widget.category.color),
          ),
        ),
      );
      return;
    }

    // All other sections - open in WebView
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

  void _showQuranDialog(
    BuildContext context,
    String langCode,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('📖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Holy Quran'),
          ],
        ),
        content: const Text(
          'The Holy Quran is available in the app.\n\n'
          'You can access it from the Quran tile '
          'on the home screen.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  String _getSubtitle(
    String subId,
    String langCode,
  ) {
    const subtitles = {
      'haram_news': 'Latest updates from Al-Haram',
      'nabawi_news':
          'Latest updates from An-Nabawi',
      'haram_prayer':
          'Adhan & Iqama times Makkah',
      'nabawi_prayer':
          'Adhan & Iqama times Madinah',
      'haram_imams': 'Current Makkah imams',
      'nabawi_imams': 'Current Madinah imams',
      'haram_muezzin': 'Makkah muezzin schedule',
      'nabawi_muezzin': 'Madinah muezzin schedule',
      'haram_lessons': 'Daily lessons at Al-Haram',
      'nabawi_lessons': 'Daily lessons at An-Nabawi',
      'khutbah': 'Friday sermons audio & text',
      'lessons': 'Scientific Islamic lessons',
      'scholars':
          'Sheikhs of the Two Holy Mosques',
      'recitations': 'Quran recitations from Haram',
      'quran': 'Full Holy Quran offline',
      'qanda': 'Islamic Q&A and Fatawa',
      'prayer_makkah': 'Makkah prayer schedule',
      'prayer_madinah': 'Madinah prayer schedule',
      'photos': 'Official photo gallery',
      'magazine': 'Monthly Haramain magazine',
      'risala': 'Al-Haramain message',
    };
    return subtitles[subId] ??
        'Tap to view content';
  }
}

class _CategoryPatternPainter extends CustomPainter {
  final Color color;
  _CategoryPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0;
        x < size.width + 50;
        x += 50) {
      for (double y = 0;
          y < size.height + 50;
          y += 50) {
        canvas.drawCircle(Offset(x, y), 25, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) =>
      false;
}