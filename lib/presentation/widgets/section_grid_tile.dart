import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pilgrims_companion/core/services/reading_progress_service.dart';
import '../../app/app_constants.dart';

class SectionGridTile extends StatefulWidget {
  final ContentSection section;
  final VoidCallback onTap;

  const SectionGridTile({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  State<SectionGridTile> createState() => _SectionGridTileState();
}

class _SectionGridTileState extends State<SectionGridTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  ReadingProgress? _progress;

  @override
  void initState() {
    super.initState();
     _loadProgress();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));
  }

 Future<void> _loadProgress() async {
    final progress = await ReadingProgressService()
        .getProgress(widget.section.id);
    if (mounted) {
      setState(() {
        _progress = progress;
      });
    }
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Section Info
            Row(
              children: [
                Text(
                  widget.section.icon,
                  style: const TextStyle(fontSize: 36),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getSectionTitle(
                        widget.section.titleKey,
                      ),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_progress != null)
                      Text(
                        '${_progress!.percentageText} completed',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 8),

            // Actions
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color:
                      Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              title: const Text('Open Guide'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onTap();
              },
            ),

            if (_progress != null &&
                _progress!.currentPage > 1)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bookmark_rounded,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Resume (Page ${_progress!.currentPage})',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onTap();
                },
              ),

            if (_progress != null)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: const Text('Reset Progress'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ReadingProgressService()
                      .clearProgress(widget.section.id);
                  if (mounted) {
                    setState(() => _progress = null);
                  }
                },
              ),

            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
 return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _pressController.reverse();
        _showQuickActions(context);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
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
                    widget.section.icon,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                ),
                child: Text(
                  _getSectionTitle(widget.section.titleKey),
                  style:
                      Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

          // Progress Badge
              if (_progress != null &&
                  _progress!.currentPage > 1)
                Column(
                  children: [
                    // Progress bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value:
                              _progress!.progressPercentage,
                          minHeight: 4,
                          backgroundColor:
                              Colors.grey.withOpacity(0.2),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(
                            _progress!.isCompleted
                                ? Colors.green
                                : Theme.of(context)
                                    .colorScheme
                                    .primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Percentage text
                    Text(
                      _progress!.isCompleted
                          ? '✅ Completed'
                          : '${_progress!.percentageText} read',
                      style: TextStyle(
                        fontSize: 10,
                        color: _progress!.isCompleted
                            ? Colors.green
                            : Theme.of(context)
                                .colorScheme
                                .primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
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
                        size: 11,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ready',
                        style: TextStyle(
                          fontSize: 10,
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