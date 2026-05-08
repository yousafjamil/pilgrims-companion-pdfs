import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pilgrims_companion/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_constants.dart';
import '../../core/cubit/settings_cubit/settings_cubit.dart';
import '../../core/cubit/settings_cubit/settings_state.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/quran_downloader.dart';
import '../../core/services/risala_service.dart';
import '../../core/services/reading_progress_service.dart';
import '../../core/services/haramain_content_service.dart';
import 'language_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('⚙️', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Settings'),
          ],
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SettingsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // ── Language ─────────────────────────
              _buildSectionHeader(
                context, '🌍', 'Language',
              ),
              _buildLanguageCard(context),
              const SizedBox(height: 24),

              // ── Appearance ────────────────────────
              _buildSectionHeader(
                context, '🎨', 'Appearance',
              ),
              _buildThemeCard(context, state),
              const SizedBox(height: 24),

              // ── Storage ───────────────────────────
              _buildSectionHeader(
                context, '💾', 'Storage & Cache',
              ),
              _buildStorageCard(context),
              const SizedBox(height: 24),

              // ── Holy Quran ────────────────────────
              _buildSectionHeader(
                context, '📖', 'Holy Quran',
              ),
              _buildQuranCard(context),
              const SizedBox(height: 24),

              // ── Risala Library ────────────────────
              _buildSectionHeader(
                context, '📚', 'Risala Library',
              ),
              _buildRisalaCard(context),
              const SizedBox(height: 24),

              // ── About ─────────────────────────────
              _buildSectionHeader(
                context, 'ℹ️', 'About',
              ),
              _buildAboutCard(context),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  // ── Section Header ────────────────────────────────

  Widget _buildSectionHeader(
    BuildContext context,
    String emoji,
    String title,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),
          ),
        ],
      ),
    );
  }

  // ── Language Card ─────────────────────────────────

  Widget _buildLanguageCard(BuildContext context) {
    final currentCode =
        StorageService.instance.getLanguage() ?? 'en';
    final language =
        AppConstants.supportedLanguages.firstWhere(
      (l) => l.code == currentCode,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              language.flag,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: const Text(
          'Current Language',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${language.nativeName} (${language.name})',
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Change',
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        onTap: () =>
            _showLanguageChangeDialog(context),
      ),
    );
  }

  // ── Theme Card ────────────────────────────────────

  Widget _buildThemeCard(
    BuildContext context,
    SettingsState state,
  ) {
    String currentTheme = 'light';
    if (state is SettingsLoaded) {
      currentTheme = state.themeMode;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'light',
            groupValue: currentTheme,
            title: const Text(
              'Light Mode',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text('Bright and clear'),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.light_mode_rounded,
                color: Colors.orange,
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                context
                    .read<SettingsCubit>()
                    .changeTheme(value);
              }
            },
          ),
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),
          RadioListTile<String>(
            value: 'dark',
            groupValue: currentTheme,
            title: const Text(
              'Dark Mode',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: const Text('Easy on the eyes'),
            secondary: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.dark_mode_rounded,
                color: Colors.indigo,
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                context
                    .read<SettingsCubit>()
                    .changeTheme(value);
              }
            },
          ),
        ],
      ),
    );
  }

  // ── Storage Card ──────────────────────────────────

  Widget _buildStorageCard(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ?? 'en';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Cache size info
          FutureBuilder<Map<String, String>>(
            future: _getStorageInfo(langCode),
            builder: (context, snapshot) {
              final info = snapshot.data;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storage_rounded,
                    color: Colors.blue,
                  ),
                ),
                title: const Text(
                  'Storage Usage',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  snapshot.connectionState ==
                          ConnectionState.waiting
                      ? 'Calculating...'
                      : 'Cache: ${info?['cache'] ?? '0'} • '
                          'Risala: ${info?['risala'] ?? '0 MB'}',
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Clear website cache
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.red,
              ),
            ),
            title: const Text(
              'Clear Website Cache',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'News, prayer times, schedules',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () =>
                _showClearCacheDialog(context),
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Clear reading progress
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.purple,
              ),
            ),
            title: const Text(
              'Clear Reading Progress',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Reset reading progress for all guides',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () =>
                _showClearProgressDialog(context),
          ),
        ],
      ),
    );
  }

  // ── Quran Card ────────────────────────────────────

  Widget _buildQuranCard(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ?? 'en';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: QuranDownloader()
                .getDownloadInfo(langCode),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final isDownloading =
                  QuranDownloader().isDownloading(langCode);

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '📖',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                title: const Text(
                  'Holy Quran',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  snapshot.connectionState ==
                          ConnectionState.waiting
                      ? 'Checking...'
                      : isDownloading
                          ? '📥 Downloading in background...'
                          : info != null
                              ? '✅ Downloaded '
                                  '(${info['sizeMB']} MB)'
                              : '⚠️ Not downloaded yet',
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
            title: const Text(
              'Delete Quran Cache',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Remove downloaded Quran file',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () =>
                _showDeleteQuranDialog(context),
          ),
        ],
      ),
    );
  }

  // ── Risala Card ───────────────────────────────────

  Widget _buildRisalaCard(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ?? 'en';
    final totalBooks = RisalaService
        .getBooksForLanguage(langCode)
        .length;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Books count
          FutureBuilder<int>(
            future: RisalaService()
                .getDownloadedCount(langCode),
            builder: (context, snapshot) {
              final downloaded = snapshot.data ?? 0;
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.green,
                  ),
                ),
                title: const Text(
                  'Downloaded Books',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  snapshot.connectionState ==
                          ConnectionState.waiting
                      ? 'Checking...'
                      : '$downloaded / $totalBooks books downloaded',
                ),
                trailing: downloaded > 0
                    ? Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green
                              .withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$downloaded ready',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Risala size
          FutureBuilder<String>(
            future: RisalaService().getTotalSize(langCode),
            builder: (context, snapshot) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.folder_zip_rounded,
                    color: Colors.orange,
                  ),
                ),
                title: const Text(
                  'Library Size',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Total: ${snapshot.data ?? '0 MB'}',
                ),
              );
            },
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          // Clear risala
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.red,
              ),
            ),
            title: const Text(
              'Clear Risala Library',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Remove all downloaded PDF books',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () =>
                _showClearRisalaDialog(context),
          ),
        ],
      ),
    );
  }

  // ── About Card ────────────────────────────────────

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '🕋',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            ),
            title: const Text(
              'App Name',
              style:
                  TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              AppConstants.appName,
              style:
                  Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: Colors.purple,
              ),
            ),
            title: const Text(
              'Version',
              style:
                  TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppConstants.appVersion,
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.language_rounded,
                color: Colors.teal,
              ),
            ),
            title: const Text(
              'Languages Supported',
              style:
                  TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              '${AppConstants.supportedLanguages.length}'
              ' languages',
              style:
                  Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.offline_bolt_rounded,
                color: Colors.green,
              ),
            ),
            title: const Text(
              'Offline Mode',
              style:
                  TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Enabled',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),

          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),
            title: const Text(
              'About App',
              style:
                  TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Mission, features & more',
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Storage Info Helper ───────────────────────────

  Future<Map<String, String>> _getStorageInfo(
    String langCode,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int cacheCount = 0;
      for (final key in prefs.getKeys()) {
        if (key.startsWith('cache_')) cacheCount++;
      }
      final risalaSize =
          await RisalaService().getTotalSize(langCode);

      return {
        'cache': '$cacheCount sections cached',
        'risala': risalaSize,
      };
    } catch (_) {
      return {'cache': '0', 'risala': '0 MB'};
    }
  }

  // ── Dialogs ───────────────────────────────────────

  void _showLanguageChangeDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('🌍'),
            SizedBox(width: 8),
            Text('Change Language'),
          ],
        ),
        content: const Text(
          'Changing language will re-download all content '
          'for the new language.\n\n'
          'The Quran will also be re-downloaded.\n\n'
          'This may take a few minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ElevatedButton(
  onPressed: () {
    Navigator.pop(dialogContext);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const OnboardingScreen(),
      ),
      (route) => false,
    );
  },
  child: const Text('Continue'),
),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.delete_sweep_rounded,
              color: Colors.red,
            ),
            SizedBox(width: 8),
            Text('Clear Website Cache'),
          ],
        ),
        content: const Text(
          'This will remove all cached news, prayer times, '
          'schedules, and other website content.\n\n'
          'Note: Quran and Risala books will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await HaramainContentService()
                  .clearAllCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text('Cache cleared successfully'),
                      ],
                    ),
                    backgroundColor:
                        Colors.green.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration:
                        const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.auto_stories_rounded,
              color: Colors.purple,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Clear Reading Progress',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: const Text(
          'This will reset reading progress for all guides.\n\n'
          'You will lose track of where you left off.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ReadingProgressService()
                  .clearAllProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text('Reading progress cleared'),
                      ],
                    ),
                    backgroundColor: Colors.purple,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearRisalaDialog(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ?? 'en';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Colors.orange,
            ),
            SizedBox(width: 8),
            Text('Clear Risala Library'),
          ],
        ),
        content: const Text(
          'This will delete all downloaded PDF books '
          'from the Risala library.\n\n'
          'You can re-download them anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await RisalaService()
                  .deleteAllBooks(langCode);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text('Risala library cleared'),
                      ],
                    ),
                    backgroundColor:
                        Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteQuranDialog(BuildContext context) {
    final langCode =
        StorageService.instance.getLanguage() ?? 'en';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Text('📖'),
            SizedBox(width: 8),
            Text('Delete Quran'),
          ],
        ),
        content: const Text(
          'This will delete the downloaded Quran file.\n\n'
          'You will need to re-download it to '
          'read offline.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await QuranDownloader()
                  .deleteCached(langCode);
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          success
                              ? Icons.check_circle_rounded
                              : Icons.error_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          success
                              ? 'Quran deleted successfully'
                              : 'Failed to delete Quran',
                        ),
                      ],
                    ),
                    backgroundColor: success
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration:
                        const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}