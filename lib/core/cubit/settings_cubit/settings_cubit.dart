import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import '../../services/download_service.dart';
import '../../services/quran_downloader.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final StorageService storageService;
  final DownloadService downloadService;

  SettingsCubit({
    required this.storageService,
    required this.downloadService,
  }) : super(SettingsInitial()) {
    loadSettings();
  }

  // ── Load Settings ──────────────────────────────────────────────────────
  void loadSettings() {
    try {
      final themeMode = storageService.getThemeMode();
      final languageCode = storageService.getLanguage() ?? 'en';

      emit(SettingsLoaded(
        themeMode: themeMode,
        languageCode: languageCode,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ── Change Theme ───────────────────────────────────────────────────────
  Future<void> changeTheme(String themeMode) async {
    try {
      await storageService.saveThemeMode(themeMode);
      loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ── Clear Cache (guides only, not Quran) ───────────────────────────────
  Future<void> clearCache() async {
    try {
      emit(SettingsLoading());

      final languageCode = storageService.getLanguage() ?? 'en';

      // Delete downloaded guide PDFs
      await downloadService.deleteLanguageContent(languageCode);

      // Mark as not downloaded
      await storageService.setContentDownloaded(languageCode, false);

      loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  // ── Clear Everything Including Quran ───────────────────────────────────
  Future<void> clearAllContent() async {
    try {
      emit(SettingsLoading());

      final languageCode = storageService.getLanguage() ?? 'en';

      // Delete guide PDFs
      await downloadService.deleteLanguageContent(languageCode);

      // Delete Quran cache
      await QuranDownloader().deleteCached(languageCode);

      // Mark as not downloaded
      await storageService.setContentDownloaded(languageCode, false);

      loadSettings();
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}