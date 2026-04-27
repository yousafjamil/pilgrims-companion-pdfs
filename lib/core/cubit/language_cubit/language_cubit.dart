import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  final StorageService storageService;
  String? _selectedLanguageCode;

  LanguageCubit(this.storageService) : super(LanguageInitial()) {
    _loadSavedLanguage();
  }

  String? get selectedLanguageCode => _selectedLanguageCode;

  // ── Load Saved Language ────────────────────────────────────────────────
  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguage = storageService.getLanguage();
      if (savedLanguage != null) {
        _selectedLanguageCode = savedLanguage;
        emit(LanguageSelected(savedLanguage));
      }
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  // ── Select Language (UI only) ──────────────────────────────────────────
  void selectLanguage(String languageCode) {
    _selectedLanguageCode = languageCode;
    emit(LanguageSelected(languageCode));
  }

  // ── Save Language ──────────────────────────────────────────────────────
  Future<void> saveLanguage(String languageCode) async {
    try {
      emit(LanguageLoading());
      await storageService.saveLanguage(languageCode);
      _selectedLanguageCode = languageCode;
      emit(LanguageSelected(languageCode));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }

  // ── Change Language ────────────────────────────────────────────────────
  Future<void> changeLanguage(String newLanguageCode) async {
    try {
      emit(LanguageLoading());
      await storageService.saveLanguage(newLanguageCode);
      _selectedLanguageCode = newLanguageCode;
      emit(LanguageSelected(newLanguageCode));
    } catch (e) {
      emit(LanguageError(e.toString()));
    }
  }
}