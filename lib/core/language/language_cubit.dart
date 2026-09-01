import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_strings.dart';
import '../network/app_session.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  static const _key = 'app_language';

  LanguageCubit() : super(const LanguageState(AppLanguage.uz));

  /// Call once at startup to restore persisted language.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'uz';
    final lang = AppLanguage.values.firstWhere(
      (l) => l.code == code,
      orElse: () => AppLanguage.uz,
    );
    _apply(lang);
    emit(LanguageState(lang));
  }

  /// Change language: persist locally, update AppStrings, and sync with backend.
  Future<void> changeLanguage(AppLanguage language) async {
    if (language == state.language) return;

    _apply(language);
    emit(LanguageState(language));

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language.code);

    // Backend only supports uz and ru — en returns 422, skip PATCH.
    if (language == AppLanguage.en) return;

    // Sync with backend if user is logged in
    if (AppSession.authLocalStorage.isLoggedIn) {
      try {
        await AppSession.apiClient.patch(
          ApiEndpoints.me,
          body: {'locale': language.code},
        );
      } catch (_) {
        // Silently fail — local change is already applied
      }
    }
  }

  void _apply(AppLanguage lang) {
    AppStrings.currentLanguage = lang;
  }
}
