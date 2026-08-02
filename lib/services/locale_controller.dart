import 'package:flutter/foundation.dart';
import 'package:rategold/l10n/app_language.dart';
import 'package:rategold/l10n/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({AppLanguage? initialLanguage})
      : _language = initialLanguage ?? AppLanguage.en,
        _strings = AppStrings(initialLanguage ?? AppLanguage.en);

  static const _prefsKey = 'app_language';

  AppLanguage _language;
  AppStrings _strings;

  AppLanguage get language => _language;
  AppStrings get strings => _strings;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      _setLanguage(AppLanguage.fromCode(code), persist: false);
    }
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_language == language) return;
    _setLanguage(language, persist: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language.code);
    notifyListeners();
  }

  void _setLanguage(AppLanguage language, {required bool persist}) {
    _language = language;
    _strings = AppStrings(language);
    if (!persist) notifyListeners();
  }
}
