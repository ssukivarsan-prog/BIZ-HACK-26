import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<String> {
  LocaleNotifier() : super('en') {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_locale');
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setLocale(String languageCode) async {
    state = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', languageCode);
  }
}
