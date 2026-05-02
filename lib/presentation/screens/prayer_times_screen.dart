import 'package:flutter/material.dart';
import '../../core/services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() =>
      _PrayerTimesScreenState();
}

class _PrayerTimesScreenState
    extends State<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PrayerTimesModel? _makkahTimes;
  PrayerTimesModel? _madinahTimes;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _loadPrayerTimes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await PrayerTimesService()
          .getBothCities();
      setState(() {
        _makkahTimes = results['makkah'];
        _madinahTimes = results['madinah'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load prayer times';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🕌', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Prayer Times'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadPrayerTimes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor:
              Colors.white60,
          tabs: const [
            Tab(
              icon: Text(
                '🕋',
                style: TextStyle(fontSize: 20),
              ),
              text: 'Makkah',
            ),
            Tab(
              icon: Text(
                '🕌',
                style: TextStyle(fontSize: 20),
              ),
              text: 'Madinah',
            ),
          ],
        ),
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
            Text('Loading prayer times...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPrayerTimes,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildPrayerTimesTab(
          _makkahTimes,
          'Makkah Al-Mukarramah',
          '🕋',
        ),
        _buildPrayerTimesTab(
          _madinahTimes,
          'Madinah Al-Munawwarah',
          '🕌',
        ),
      ],
    );
  }

  Widget _buildPrayerTimesTab(
    PrayerTimesModel? model,
    String cityName,
    String emoji,
  ) {
    if (model == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final prayers = model.getPrayersList();
    final nextPrayer = model.getNextPrayer();
    final minutesLeft =
        model.minutesUntilNextPrayer();
    final hoursLeft = minutesLeft ~/ 60;
    final minsLeft = minutesLeft % 60;

    return RefreshIndicator(
      onRefresh: _loadPrayerTimes,
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Date Card ─────────────────────────
            _buildDateCard(model, cityName, emoji),

            const SizedBox(height: 16),

            // ── Next Prayer Card ──────────────────
            _buildNextPrayerCard(
              nextPrayer,
              model.getNextPrayerTime(),
              hoursLeft,
              minsLeft,
            ),

            const SizedBox(height: 16),

            // ── Prayer Times List ─────────────────
            _buildPrayerTimesList(
              prayers,
              nextPrayer,
            ),

            const SizedBox(height: 16),

            // ── Source Info ───────────────────────
            _buildSourceInfo(),
          ],
        ),
      ),
    );
  }

  // ── Date Card ──────────────────────────────────────

  Widget _buildDateCard(
    PrayerTimesModel model,
    String cityName,
    String emoji,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            cityName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${model.hijriDate} ${model.hijriMonth} ${model.hijriYear}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  // ── Next Prayer Card ───────────────────────────────

  Widget _buildNextPrayerCard(
    String nextPrayer,
    String nextTime,
    int hours,
    int mins,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFD4AF37).withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37)
                  .withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '⏰',
                style: TextStyle(fontSize: 26),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Prayer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  nextPrayer,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  nextTime,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                hours > 0
                    ? '${hours}h ${mins}m'
                    : '${mins}m',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const Text(
                'remaining',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Prayer Times List ──────────────────────────────

  Widget _buildPrayerTimesList(
    List<PrayerItem> prayers,
    String nextPrayer,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: prayers.map((prayer) {
          final isNext =
              prayer.name == nextPrayer;
          final isSunrise =
              prayer.id == 'sunrise';

          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isNext
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius:
                      prayers.last == prayer
                          ? const BorderRadius.vertical(
                              bottom:
                                  Radius.circular(16),
                            )
                          : prayers.first ==
                                  prayer
                              ? const BorderRadius
                                  .vertical(
                                  top: Radius.circular(
                                    16,
                                  ),
                                )
                              : null,
                ),
                child: ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isNext
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15)
                          : Colors.grey
                              .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        prayer.icon,
                        style: const TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        prayer.name,
                        style: TextStyle(
                          fontWeight: isNext
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isNext
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        prayer.nameAr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                        textDirection:
                            TextDirection.rtl,
                      ),
                    ],
                  ),
                  subtitle: isSunrise
                      ? const Text(
                          'Not a prayer time',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle:
                                FontStyle.italic,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        prayer.time,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isNext
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isNext
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                              : null,
                        ),
                      ),
                      if (isNext) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (prayers.last != prayer)
                const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Source Info ────────────────────────────────────

  Widget _buildSourceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Prayer times based on Umm Al-Qura '
              'method (Saudi Arabia official)',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}