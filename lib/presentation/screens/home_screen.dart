
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pilgrims_companion/core/services/risala_service.dart';
import 'package:pilgrims_companion/presentation/screens/risala_screen.dart';
import '../../app/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/haramain_content_service.dart';
import '../widgets/prayer_times_card.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'category_screen.dart';
import 'prayer_times_screen.dart';
import 'haramain_news_screen.dart';
import 'webview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ScrollController _scrollController =
      ScrollController();
  bool _isScrolled = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();

    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _scrollOffset = offset;
        _isScrolled = offset > 80;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Widget _buildRisalaPreview(
    BuildContext context,
    String langCode,
  ) {
    final books =
        RisalaService.getBooksForLanguage(langCode);
    final previewBooks = books.take(4).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16, 0, 16, 8,
      ),
      child: Column(
        children: [
          // Books horizontal scroll
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: previewBooks.length,
              itemBuilder: (context, index) {
                final book = previewBooks[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const RisalaScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2D5F3F),
                          Color(0xFF1A3D28),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Text(
                                book.icon,
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.w600,
                                    height: 1.3,
                                  ),
                                  textAlign:
                                      TextAlign.center,
                                  maxLines: 3,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding:
                                const EdgeInsets.all(
                              3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFD4AF37,
                              ),
                              borderRadius:
                                  BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: const Text(
                              'PRH',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // View all button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const RisalaScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2D5F3F)
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2D5F3F)
                      .withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D5F3F)
                          .withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '📚',
                        style:
                            TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          langCode == 'ar'
                              ? 'مكتبة رسالة الحرمين'
                              : 'Risala Al-Haramain Library',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${books.length} books in your language',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFF2D5F3F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ??
        'en';
    final isTablet =
        MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await HaramainContentService()
                  .downloadAllContent(
                languageCode: langCode,
                onProgress: (_, __) {},
              );
              setState(() {});
            },
            color: Theme.of(context)
                .colorScheme
                .primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics:
                  const BouncingScrollPhysics(
                parent:
                    AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Hero Header ──────────────────
                SliverToBoxAdapter(
                  child: _buildHeroHeader(
                    context,
                    langCode,
                  ),
                ),

                // ── Prayer Times Card ────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '🕐',
                    title: 'Prayer Times',
                    titleAr: 'مواقيت الصلوات',
                    langCode: langCode,
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const PrayerTimesScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: const PrayerTimesCard(),
                ),

                // ── Categories ───────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📋',
                    title: 'Categories',
                    titleAr: 'الأقسام',
                    langCode: langCode,
                  ),
                ),

                // ── Category Cards ───────────────
         
             
// ── Category Cards ───────────────
SliverPadding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  sliver: SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: isTablet ? 3 : 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: isTablet ? 1.1 : 0.95,
    ),
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final category = AppConstants.homeCategories[index];
        return TweenAnimationBuilder<double>(  // ← FIXED: added <double> correctly
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 200 + (index * 80)),
          builder: (_, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - val)),
              child: child,
            ),
          ),
          child: _buildCategoryCard(context, category, langCode),
        );
      },
      childCount: AppConstants.homeCategories.length,
    ),
  ),
),


                // ── Quick Links ──────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '⚡',
                    title: 'Quick Access',
                    titleAr: 'الوصول السريع',
                    langCode: langCode,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildQuickLinks(
                    context,
                    langCode,
                  ),
                ),

                // ── Latest News Preview ──────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📰',
                    title: 'Latest News',
                    titleAr: 'آخر الأخبار',
                    langCode: langCode,
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const HaramainNewsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                // ── Risala Library ────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📚',
                    title: 'Risala Library',
                    titleAr: 'مكتبة رسالة الحرمين',
                    langCode: langCode,
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const RisalaScreen(),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildRisalaPreview(
                    context,
                    langCode,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildNewsPreview(
                    context,
                    langCode,
                  ),
                ),

                // ── Official Website ─────────────
                SliverToBoxAdapter(
                  child: _buildOfficialWebsite(
                    context,
                    langCode,
                  ),
                ),

                // ── Daily Tip ────────────────────
                SliverToBoxAdapter(
                  child: _buildDailyTip(context),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
      title: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🕋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Pilgrim\'s Companion'),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_rounded,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    const SettingsScreen(),
              ),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero Header ───────────────────────────────────

  Widget _buildHeroHeader(
    BuildContext context,
    String langCode,
  ) {
    final collapseProgress =
        (_scrollOffset / 120.0).clamp(0.0, 1.0);
    final headerHeight =
        (220.0 - (collapseProgress * 100))
            .clamp(130.0, 220.0);

    return AnimatedContainer(
      duration: Duration.zero,
      height: headerHeight,
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3D28),
            Theme.of(context).colorScheme.primary,
            const Color(0xFF3D7A52),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _HeaderPatternPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        AnimatedOpacity(
                          opacity:
                              1.0 - collapseProgress,
                          duration: Duration.zero,
                          child: Text(
                            _getGreeting(langCode),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedOpacity(
                          opacity:
                              1.0 - collapseProgress,
                          duration: Duration.zero,
                          child: Text(
                            _getTimeGreeting(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity:
                              1.0 - collapseProgress,
                          duration: Duration.zero,
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2),
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),
                            child: const Text(
                              '🏛️ prh.gov.sa Official',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: Duration.zero,
                    width: 60 +
                        (20 * (1 - collapseProgress)),
                    height: 60 +
                        (20 * (1 - collapseProgress)),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white
                            .withOpacity(0.3),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🕋',
                        style:
                            TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Label ─────────────────────────────────

  Widget _buildSectionLabel(
    BuildContext context, {
    required String emoji,
    required String title,
    required String titleAr,
    required String langCode,
    VoidCallback? onMore,
  }) {
    final displayTitle =
        langCode == 'ar' ? titleAr : title;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        12,
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
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
                  langCode == 'ar'
                      ? 'المزيد'
                      : 'See All',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Category Card ─────────────────────────────────

  Widget _buildCategoryCard(
    BuildContext context,
    HomeCategory category,
    String langCode,
  ) {
    final color = Color(category.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              category: category,
              langCode: langCode,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.15),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -10,
              bottom: -10,
              child: Text(
                category.icon,
                style: TextStyle(
                  fontSize: 60,
                  color: color.withOpacity(0.1),
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
                  // Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        category.icon,
                        style: const TextStyle(
                          fontSize: 26,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Title
                  Text(
                    category.getTitle(langCode),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Subcategory count
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              color.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${category.subcategories.length} sections',
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 12,
                        color:
                            color.withOpacity(0.6),
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

  // ── Quick Links ───────────────────────────────────

  Widget _buildQuickLinks(
    BuildContext context,
    String langCode,
  ) {
    final links = [
      _QuickLink(
        '🕐',
        langCode == 'ar' ? 'الصلاة' : 'Prayer',
        Colors.teal,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const PrayerTimesScreen(),
          ),
        ),
      ),
      _QuickLink(
        '📰',
        langCode == 'ar' ? 'أخبار' : 'News',
        Colors.blue,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const HaramainNewsScreen(),
          ),
        ),
      ),
      _QuickLink(
        '🎙️',
        langCode == 'ar' ? 'خطب' : 'Khutbah',
        Colors.purple,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url:
                  'https://prh.gov.sa/الخطب-بالحرمين',
              title: langCode == 'ar'
                  ? 'الخطب بالحرمين'
                  : 'Haramain Khutbah',
            ),
          ),
        ),
      ),
      _QuickLink(
        '👨‍🏫',
        langCode == 'ar'
            ? 'علماء'
            : 'Scholars',
        Colors.indigo,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url:
                  'https://prh.gov.sa/علماء-ومشائخ-الحرمين',
              title: langCode == 'ar'
                  ? 'علماء الحرمين'
                  : 'Haramain Scholars',
            ),
          ),
        ),
      ),
      _QuickLink(
        '❓',
        langCode == 'ar' ? 'فتاوى' : 'Fatawa',
        Colors.orange,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url:
                  'https://prh.gov.sa/إجابة-السائلين',
              title: langCode == 'ar'
                  ? 'إجابة السائلين'
                  : 'Q&A (Fatawa)',
            ),
          ),
        ),
      ),
      _QuickLink(
        '🎵',
        langCode == 'ar'
            ? 'تلاوات'
            : 'Recitations',
        Colors.red,
        () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WebViewScreen(
              url:
                  'https://prh.gov.sa/تلاوات-الحرمين',
              title: langCode == 'ar'
                  ? 'تلاوات الحرمين'
                  : 'Quran Recitations',
            ),
          ),
        ),
      ),
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: links.length,
        itemBuilder: (context, index) {
          final link = links[index];
          return GestureDetector(
            onTap: link.onTap,
            child: Container(
              width: 72,
              margin: const EdgeInsets.only(
                right: 12,
              ),
              decoration: BoxDecoration(
                color: link.color.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: link.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    link.emoji,
                    style: const TextStyle(
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    link.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: link.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── News Preview ──────────────────────────────────

  Widget _buildNewsPreview(
    BuildContext context,
    String langCode,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        8,
      ),
      child: Column(
        children: [
          // Makkah news
          _buildNewsButton(
            context,
            emoji: '🕋',
            title: langCode == 'ar'
                ? 'أخبار المسجد الحرام'
                : 'Masjid Al-Haram News',
            subtitle: langCode == 'ar'
                ? 'آخر الأخبار والتحديثات'
                : 'Latest news & updates',
            color:
                Theme.of(context).colorScheme.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const HaramainNewsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          // Madinah news
          _buildNewsButton(
            context,
            emoji: '🕌',
            title: langCode == 'ar'
                ? 'أخبار المسجد النبوي'
                : 'Masjid An-Nabawi News',
            subtitle: langCode == 'ar'
                ? 'آخر الأخبار والتحديثات'
                : 'Latest news & updates',
            color: Colors.indigo,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      const HaramainNewsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsButton(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style:
                      const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  // ── Official Website ──────────────────────────────

  Widget _buildOfficialWebsite(
    BuildContext context,
    String langCode,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const WebViewScreen(
                url: 'https://prh.gov.sa',
                title: 'رئاسة الشؤون الدينية',
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A3D28),
                Color(0xFF2D5F3F),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    '🌐',
                    style:
                        TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      langCode == 'ar'
                          ? 'الموقع الرسمي'
                          : 'Official Website',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'prh.gov.sa',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.2),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  langCode == 'ar'
                      ? 'زيارة'
                      : 'Visit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Daily Tip ─────────────────────────────────────

  Widget _buildDailyTip(BuildContext context) {
    final tips = [
      ('🕋', 'Umrah Tip',
          'Start Tawaf from the Black Stone.'),
      ('🤲', 'Dua Tip',
          'Best dua on Arafah: La ilaha illallah...'),
      ('💧', 'Zamzam', 'Drink Zamzam facing Qibla.'),
      ('🌙', 'Hajj Tip', 'Hajj is Arafah.'),
    ];
    final tip = tips[DateTime.now().day % tips.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        0,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Text(
            tip.$1,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  tip.$2,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip.$3,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────

  String _getGreeting(String langCode) {
    const greetings = {
      'en': 'As-salamu alaykum 👋',
      'ar': 'السلام عليكم 👋',
      'ur': 'السلام علیکم 👋',
      'tr': 'Es-selamu aleyküm 👋',
      'id': 'Assalamu\'alaikum 👋',
      'fr': 'As-salamu alaykum 👋',
      'bn': 'আস-সালামু আলাইকুম 👋',
      'ru': 'Ас-саляму алейкум 👋',
      'fa': 'السلام علیکم 👋',
      'hi': 'अस्सलामु अलैकुम 👋',
      'ha': 'Assalamu alaikum 👋',
      'so': 'Assalaamu calaykum 👋',
    };
    return greetings[langCode] ??
        'As-salamu alaykum 👋';
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning, Pilgrim 🌅';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon, Pilgrim ☀️';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening, Pilgrim 🌆';
    } else {
      return 'Good Night, Pilgrim 🌙';
    }
  }
}

// ── Header Pattern ────────────────────────────────────

class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double x = 0;
        x < size.width + 40;
        x += 40) {
      for (double y = 0;
          y < size.height + 40;
          y += 40) {
        canvas.drawCircle(Offset(x, y), 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) =>
      false;
}

// ── Models ────────────────────────────────────────────

class _QuickLink {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  _QuickLink(
    this.emoji,
    this.label,
    this.color,
    this.onTap,
  );
}
