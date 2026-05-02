import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pilgrims_companion/presentation/screens/haramain_news_screen.dart';
import 'package:pilgrims_companion/presentation/screens/prayer_times_screen.dart';
import 'package:pilgrims_companion/presentation/screens/webview_screen.dart';
import 'package:pilgrims_companion/presentation/widgets/prayer_times_card.dart';
import '../../app/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../widgets/section_grid_tile.dart';
import '../widgets/quran_download_tile.dart';
import 'settings_screen.dart';
import 'pdf_viewer_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ──────────────────────────────────────────
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ── Scroll ─────────────────────────────────────────────
  final ScrollController _scrollController =
      ScrollController();
  bool _isScrolled = false;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();

    // Setup animations
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
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();

    // Scroll listener
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _scrollOffset = offset;
      _isScrolled = offset > 80;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 3 : 2;
    final languageCode =
        StorageService.instance.getLanguage() ?? 'en';

    // All sections except Quran
    final regularSections = AppConstants.contentSections
        .where((s) => s.id != 'quran')
        .toList();

    return Scaffold(
      // ── Custom App Bar ─────────────────────────────────
      appBar: _buildAppBar(context),

      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              setState(() {});
              await Future.delayed(
                const Duration(milliseconds: 600),
              );
            },
            color: Theme.of(context).colorScheme.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // ── Collapsible Hero Header ───────────────
                SliverToBoxAdapter(
                  child: _buildHeroHeader(
                    context,
                    languageCode,
                  ),
                ),

                // ── Stats Row ─────────────────────────────
                SliverToBoxAdapter(
                  child: _buildStatsRow(context),
                ),

                // ── Quick Actions ─────────────────────────
                SliverToBoxAdapter(
                  child: _buildQuickActions(context),
                ),

                // ── Guides Section Label ──────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📚',
                    title: 'Guides & Resources',
                    subtitle:
                        '${regularSections.length} guides available',
                  ),
                ),

                // ── Regular Sections Grid ─────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio:
                          isTablet ? 0.95 : 0.88,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final section =
                            regularSections[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ),
                          duration: Duration(
                            milliseconds:
                                200 + (index * 80),
                          ),
                          curve: Curves.easeOut,
                          builder:
                              (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(
                                  0,
                                  20 * (1 - value),
                                ),
                                child: child,
                              ),
                            );
                          },
                          child: SectionGridTile(
                            section: section,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PdfViewerScreen(
                                    section: section,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: regularSections.length,
                    ),
                  ),
                ),

                // ── Quran Section Label ───────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📖',
                    title: 'Holy Quran',
                    subtitle:
                        'Full Quran with translation',
                  ),
                ),

                // ── Quran Tile ────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: isTablet ? 180 : 160,
                      child: const QuranDownloadTile(),
                    ),
                  ),
                ),

          // ── Prayer Times Card ─────────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '🕌',
                    title: 'Prayer Times',
                    subtitle:
                        'Makkah & Madinah',
                  ),
                ),

                SliverToBoxAdapter(
                  child: const PrayerTimesCard(),
                ),

                // ── News Section ──────────────────────────
                SliverToBoxAdapter(
                  child: _buildSectionLabel(
                    context,
                    emoji: '📰',
                    title: 'Haramain News',
                    subtitle:
                        'Latest from prh.gov.sa',
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildNewsPreview(context),
                ),

                // ── Daily Tip Card ────────────────────────
                SliverToBoxAdapter(
                  child: _buildDailyTipCard(context),
                ),

                // ── Bottom Padding ────────────────────────
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



// ── News Preview ──────────────────────────────────────

  Widget _buildNewsPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16, 0, 16, 8,
      ),
      child: Column(
        children: [
          // Makkah News Button
          _buildNewsButton(
            context,
            emoji: '🕋',
            title: 'Masjid Al-Haram News',
            subtitle: 'Latest news & updates',
            color: Theme.of(context).colorScheme.primary,
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

          // Madinah News Button
          _buildNewsButton(
            context,
            emoji: '🕌',
            title: 'Masjid An-Nabawi News',
            subtitle: 'Latest news & updates',
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

          const SizedBox(height: 10),

          // Visit Website Button
          GestureDetector(
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(14),
                border: Border.all(
                  color:
                      Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.open_in_browser_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Visit Official Website',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'prh.gov.sa',
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
                  ),
                ],
              ),
            ),
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
                  style: const TextStyle(
                    fontSize: 22,
                  ),
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
  // ── App Bar ───────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      // Collapse title when scrolled
      title: AnimatedOpacity(
        opacity: _isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🕋', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Pilgrim\'s Companion',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
      actions: [
        // Search
        IconButton(
          icon: const Icon(Icons.search_rounded),
          tooltip: 'Search Guides',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            );
          },
        ),

        // Tips
        IconButton(
          icon: const Icon(
            Icons.tips_and_updates_rounded,
          ),
          tooltip: 'Daily Tips',
          onPressed: () => _showTipDialog(context),
        ),

        // Settings
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            );
          },
        ),

        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero Header ───────────────────────────────────────────

  Widget _buildHeroHeader(
    BuildContext context,
    String langCode,
  ) {
    // Calculate collapse based on scroll
    final collapseProgress =
        (_scrollOffset / 120.0).clamp(0.0, 1.0);
    final headerHeight =
        (220.0 - (collapseProgress * 100)).clamp(
      120.0,
      220.0,
    );

    return AnimatedContainer(
      duration: Duration.zero,
      height: headerHeight,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.75),
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
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _HeaderPatternPainter(),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Left content
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        // Greeting
                        AnimatedOpacity(
                          opacity:
                              1.0 - collapseProgress,
                          duration: Duration.zero,
                          child: Text(
                            _getGreeting(langCode),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Time greeting
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

                        // Hijri badge
                        AnimatedOpacity(
                          opacity:
                              1.0 - collapseProgress,
                          duration: Duration.zero,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
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
                            child: Text(
                              _getHijriInfo(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Kaaba Icon
                  AnimatedContainer(
                    duration: Duration.zero,
                    width: 60 +
                        (20 * (1 - collapseProgress)),
                    height: 60 +
                        (20 * (1 - collapseProgress)),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🕋',
                        style: TextStyle(fontSize: 36),
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

  // ── Stats Row ─────────────────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    final stats = [
      _StatItem(
        emoji: '📚',
        value: '10',
        label: 'Guides',
        color: Theme.of(context).colorScheme.primary,
      ),
      _StatItem(
        emoji: '🌍',
        value: '12',
        label: 'Languages',
        color: Colors.blue,
      ),
      _StatItem(
        emoji: '📴',
        value: '100%',
        label: 'Offline',
        color: Colors.green,
      ),
      _StatItem(
        emoji: '🆓',
        value: 'Free',
        label: 'Forever',
        color: const Color(0xFFD4AF37),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 4,
              ),
              decoration: BoxDecoration(
                color: stat.color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: stat.color.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    stat.emoji,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                  ),
                  Text(
                    stat.label,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        emoji: '🔍',
        label: 'Search',
        color: Colors.purple,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SearchScreen(),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '🕋',
        label: 'Umrah',
        color: Theme.of(context).colorScheme.primary,
        onTap: () {
          HapticFeedback.lightImpact();
          final section = AppConstants.contentSections
              .firstWhere((s) => s.id == 'umrah_guide');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(section: section),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '🌙',
        label: 'Hajj',
        color: Colors.indigo,
        onTap: () {
          HapticFeedback.lightImpact();
          final section = AppConstants.contentSections
              .firstWhere((s) => s.id == 'hajj_guide');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(section: section),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '🤲',
        label: 'Duas',
        color: Colors.teal,
        onTap: () {
          HapticFeedback.lightImpact();
          final section = AppConstants.contentSections
              .firstWhere((s) => s.id == 'duas');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(section: section),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '🕌',
        label: 'Prayer',
        color: Colors.teal,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const PrayerTimesScreen(),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '📰',
        label: 'News',
        color: Colors.orange,
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const HaramainNewsScreen(),
            ),
          );
        },
      ),
      _QuickAction(
        emoji: '🚨',
        label: 'Emergency',
        color: Colors.red,
        onTap: () {
          HapticFeedback.lightImpact();
          final section = AppConstants.contentSections
              .firstWhere((s) => s.id == 'emergency');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  PdfViewerScreen(section: section),
            ),
          );
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            20, 16, 20, 12,
          ),
          child: Text(
            'Quick Access',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return GestureDetector(
                onTap: action.onTap,
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color:
                        action.color.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          action.color.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        action.emoji,
                        style: const TextStyle(
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: action.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Section Label ─────────────────────────────────────────

  Widget _buildSectionLabel(
    BuildContext context, {
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style:
                      Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Daily Tip Card ────────────────────────────────────────

  Widget _buildDailyTipCard(BuildContext context) {
    final tips = [
      _TipData(
        emoji: '🕋',
        title: 'Umrah Tip',
        content:
            'Start Tawaf from the Black Stone. Walk '
            'counterclockwise with the Kaaba on your left.',
        color: Theme.of(context).colorScheme.primary,
      ),
      _TipData(
        emoji: '🤲',
        title: 'Dua Tip',
        content:
            'The best dua on Day of Arafah is: '
            '"La ilaha illallah wahdahu la shareeka lah..."',
        color: Colors.teal,
      ),
      _TipData(
        emoji: '💧',
        title: 'Zamzam Tip',
        content:
            'Drink Zamzam while standing, facing Qibla. '
            'Make dua before drinking this blessed water.',
        color: Colors.blue,
      ),
      _TipData(
        emoji: '🌙',
        title: 'Hajj Tip',
        content:
            'The most important act of Hajj is standing '
            'at Arafah. The Prophet ﷺ said: "Hajj is Arafah."',
        color: Colors.indigo,
      ),
      _TipData(
        emoji: '👟',
        title: 'Health Tip',
        content:
            'Wear comfortable shoes. You will walk '
            '10-15 km daily. Bring blister pads!',
        color: Colors.orange,
      ),
    ];

    final tip = tips[DateTime.now().day % tips.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tip.color.withOpacity(0.15),
            tip.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tip.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tip.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    tip.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Tip',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          tip.color.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    tip.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: tip.color,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showTipDialog(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tip.color.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    'More',
                    style: TextStyle(
                      fontSize: 12,
                      color: tip.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            tip.content,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  // ── Tip Dialog ────────────────────────────────────────────

  void _showTipDialog(BuildContext context) {
    final tips = [
      (
        '🕋',
        'Umrah Tip',
        'Start your Tawaf from the Black Stone. '
            'Walk counterclockwise with the Kaaba on your left.',
      ),
      (
        '🤲',
        'Dua Tip',
        'The best dua on Day of Arafah:\n'
            '"La ilaha illallah wahdahu la shareeka lah, '
            'lahul mulku wa lahul hamd, wa huwa ala kulli '
            'shay\'in qadeer"',
      ),
      (
        '💧',
        'Zamzam Tip',
        'Drink Zamzam water while standing, facing Qibla. '
            'Make dua before drinking. It is blessed water.',
      ),
      (
        '🌙',
        'Hajj Tip',
        'The most important act of Hajj is standing '
            'at Arafah. The Prophet ﷺ said: "Hajj is Arafah."',
      ),
      (
        '👟',
        'Health Tip',
        'Wear comfortable shoes. '
            'You will walk 10-15 km daily. '
            'Bring blister pads and change socks regularly.',
      ),
    ];

    final tip = tips[DateTime.now().second % tips.length];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Text(
              tip.$1,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              tip.$2,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          tip.$3,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('JazakAllah Khair'),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

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
    return greetings[langCode] ?? 'As-salamu alaykum 👋';
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

  String _getHijriInfo() {
    const hijriMonths = [
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhul Qi\'dah',
      'Dhul Hijjah',
    ];
    final now = DateTime.now();
    final monthIndex = (now.month + 8) % 12;
    return '📅 ${hijriMonths[monthIndex]} • May Allah bless your journey';
  }
}

// ── Header Pattern Painter ────────────────────────────────

class _HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw circles pattern
    for (double x = 0;
        x < size.width + 40;
        x += 40) {
      for (double y = 0;
          y < size.height + 40;
          y += 40) {
        canvas.drawCircle(Offset(x, y), 20, paint);
      }
    }

    // Draw diagonal lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    for (double i = -size.height;
        i < size.width;
        i += 30) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      false;
}

// ── Data Models ───────────────────────────────────────────

class _StatItem {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  _StatItem({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });
}

class _QuickAction {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _TipData {
  final String emoji;
  final String title;
  final String content;
  final Color color;

  _TipData({
    required this.emoji,
    required this.title,
    required this.content,
    required this.color,
  });
}