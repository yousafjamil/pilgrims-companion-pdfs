import 'package:flutter/material.dart';
import '../../app/app_constants.dart';

class SectionGridTile extends StatelessWidget {
  final ContentSection section;
  final VoidCallback onTap;

  const SectionGridTile({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  section.icon,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                _getSectionTitle(section.titleKey),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Ready Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ready',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w600,
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

  String _getSectionTitle(String key) {
    const titles = {
      'umrah_guide': 'Umrah Guide',
      'hajj_guide': 'Hajj Guide',
      'duas_collection': 'Duas Collection',
      'makkah_guide': 'Makkah Guide',
      'madinah_guide': 'Madinah Guide',
      'health_safety': 'Health & Safety',
      'packing_checklist': 'Packing List',
      'common_mistakes': 'Common Mistakes',
      'emergency_info': 'Emergency Info',
      'quran': 'Holy Quran',
    };
    return titles[key] ?? key;
  }
}