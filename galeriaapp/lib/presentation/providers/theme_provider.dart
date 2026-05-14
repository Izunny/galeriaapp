import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode');
    if (isDarkMode != null) {
      state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }

  void toggleTheme() async {
    state = (state == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', state == ThemeMode.dark);
  }
}
