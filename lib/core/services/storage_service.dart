import 'package:shared_preferences/shared_preferences.dart';
import '../../app/app_constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  // ── Public Instance Getter ─────────────────────────────────────────────
  static StorageService get instance {
    if (_instance == null) {
      throw Exception(
        'StorageService not initialized. '
        'Call StorageService.getInstance() first in main().',
      );
    }
    return _instance!;
  }

  // ── Initialize ─────────────────────────────────────────────────────────
  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // ── Language ───────────────────────────────────────────────────────────
  Future<void> saveLanguage(String languageCode) async {
    await _preferences?.setString(
      AppConstants.keySelectedLanguage,
      languageCode,
    );
  }

  String? getLanguage() {
    return _preferences?.getString(AppConstants.keySelectedLanguage);
  }

  // ── First Launch ───────────────────────────────────────────────────────
  Future<void> setFirstLaunchComplete() async {
    await _preferences?.setBool(AppConstants.keyFirstLaunch, false);
  }

  bool isFirstLaunch() {
    return _preferences?.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  // ── Theme Mode ─────────────────────────────────────────────────────────
  Future<void> saveThemeMode(String mode) async {
    await _preferences?.setString(AppConstants.keyThemeMode, mode);
  }

  String getThemeMode() {
    return _preferences?.getString(AppConstants.keyThemeMode) ?? 'light';
  }

  // ── Content Downloaded ─────────────────────────────────────────────────
  Future<void> setContentDownloaded(
    String languageCode,
    bool downloaded,
  ) async {
    await _preferences?.setBool(
      '${AppConstants.keyContentDownloaded}_$languageCode',
      downloaded,
    );
  }

  bool isContentDownloaded(String languageCode) {
    return _preferences?.getBool(
          '${AppConstants.keyContentDownloaded}_$languageCode',
        ) ??
        false;
  }

  // ── Onboarding ─────────────────────────────────────────────────────────
  Future<void> setOnboardingComplete() async {
    await _preferences?.setBool('onboarding_complete', true);
  }

  bool isOnboardingComplete() {
    return _preferences?.getBool('onboarding_complete') ?? false;
  }

  // ── Clear All ──────────────────────────────────────────────────────────
  Future<void> clearAll() async {
    await _preferences?.clear();
  }
}