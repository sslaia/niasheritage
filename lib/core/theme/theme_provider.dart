import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'theme_mode';
  SharedPreferences? _prefs;

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final index = _prefs?.getInt(_key);
    if (index != null) {
      state = ThemeMode.values[index];
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final mode = isDark ? ThemeMode.dark : ThemeMode.light;
    state = mode;
    await _prefs?.setInt(_key, mode.index);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs?.setInt(_key, mode.index);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
