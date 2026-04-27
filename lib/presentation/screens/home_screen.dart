import 'package:flutter/material.dart';
import '../../app/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../widgets/section_grid_tile.dart';
import '../widgets/quran_download_tile.dart';
import 'settings_screen.dart';
import 'pdf_viewer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🕋', style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Text('Pilgrim\'s Companion'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Welcome Header ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildWelcomeHeader(
                context,
                languageCode,
              ),
            ),

            // ── Section Label ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionLabel(
                context,
                '📚',
                'Guides & Resources',
                '${regularSections.length} guides available',
              ),
            ),

            // ── Regular Sections Grid ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: isTablet ? 0.95 : 0.88,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final section = regularSections[index];
                    return SectionGridTile(
                      section: section,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(
                              section: section,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: regularSections.length,
                ),
              ),
            ),

            // ── Quran Section Label ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSectionLabel(
                context,
                '📖',
                'Holy Quran',
                'Full Quran with translation',
              ),
            ),

            // ── Quran Tile ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  height: isTablet ? 180 : 160,
                  child: const QuranDownloadTile(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Welcome Header ───────────────────────────────────────────────────────

  Widget _buildWelcomeHeader(BuildContext context, String langCode) {
    final greeting = _getGreeting(langCode);
    final now = DateTime.now();
    final timeOfDay = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
      child: Row(
        children: [
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$timeOfDay, Pilgrim 🌿',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✨ May Allah accept your journey',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Kaaba Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
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
    );
  }

  // ── Section Label ────────────────────────────────────────────────────────

  Widget _buildSectionLabel(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
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
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Greeting Helper ──────────────────────────────────────────────────────

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
}

// import 'package:flutter/material.dart';
// import '../../app/app_constants.dart';
// import '../widgets/section_grid_tile.dart';
// import 'settings_screen.dart';
// import 'pdf_viewer_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Determine grid columns based on screen width
//     final screenWidth = MediaQuery.of(context).size.width;
//     final crossAxisCount = screenWidth > 600 ? 3 : 2;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Text('🕋'),
//             SizedBox(width: 8),
//             Text('Pilgrim\'s Companion'),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(builder: (_) => const SettingsScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Welcome Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'As-salamu alaykum',
//                       style: Theme.of(context).textTheme.displayMedium?.copyWith(
//                         fontSize: 28,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Choose a guide to begin your spiritual journey',
//                       style: Theme.of(context).textTheme.bodyMedium,
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Sections Grid
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: crossAxisCount,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                     childAspectRatio: 0.9,
//                   ),
//                   itemCount: AppConstants.contentSections.length,
//                   itemBuilder: (context, index) {
//                     final section = AppConstants.contentSections[index];
                    
//                     return SectionGridTile(
//                       section: section,
//                       onTap: () {
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (_) => PdfViewerScreen(
//                               section: section,
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }