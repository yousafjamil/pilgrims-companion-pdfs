import 'package:flutter/material.dart';
import '../../core/services/prayer_times_service.dart';
import '../screens/prayer_times_screen.dart';

class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key});

  @override
  State<PrayerTimesCard> createState() =>
      _PrayerTimesCardState();
}

class _PrayerTimesCardState
    extends State<PrayerTimesCard> {
  PrayerTimesModel? _makkahTimes;
  bool _isLoading = true;
  bool _showMakkah = true;

  @override
  void initState() {
    super.initState();
    _loadTimes();
  }

  Future<void> _loadTimes() async {
    try {
      final times = await PrayerTimesService()
          .getPrayerTimes(
        city: 'Makkah',
        country: 'SA',
      );
      if (mounted) {
        setState(() {
          _makkahTimes = times;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const PrayerTimesScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A3D28),
              Theme.of(context).colorScheme.primary,
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : _makkahTimes == null
                ? _buildOfflineState()
                : _buildPrayerTimesContent(),
      ),
    );
  }

  Widget _buildOfflineState() {
    return Row(
      children: [
        const Text(
          '🕌',
          style: TextStyle(fontSize: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Prayer Times',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Tap to load prayer times',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white54,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildPrayerTimesContent() {
    final model = _makkahTimes!;
    final prayers = model.getPrayersList()
        .where((p) => p.id != 'sunrise')
        .toList();
    final nextPrayer = model.getNextPrayer();
    final mins = model.minutesUntilNextPrayer();

    return Column(
      children: [
        // Header
        Row(
          children: [
            const Text(
              '🕋',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Makkah Prayer Times',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37)
                    .withOpacity(0.3),
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: Text(
                'Next: $nextPrayer (${mins}m)',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Prayer times row
        Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
          children: prayers.map((prayer) {
            final isNext =
                prayer.name == nextPrayer;
            return Expanded(
              child: Column(
                children: [
                  Text(
                    prayer.icon,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayer.name,
                    style: TextStyle(
                      color: isNext
                          ? const Color(0xFFD4AF37)
                          : Colors.white70,
                      fontSize: 10,
                      fontWeight: isNext
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayer.time
                        .split(' ')[0], // Remove timezone
                    style: TextStyle(
                      color: isNext
                          ? const Color(0xFFD4AF37)
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: isNext
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                  ),
                  if (isNext)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(
                        top: 3,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4AF37),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 10),

        // Tap hint
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              'Tap for full schedule',
              style: TextStyle(
                color:
                    Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.5),
              size: 10,
            ),
          ],
        ),
      ],
    );
  }
}