import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.grey[200],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
  ),
);

ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.grey[900],
  cardColor: Colors.grey[800],
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
  ),
);

class ThemeProvider {
  static const _themeKey = 'theme_mode';

  Future<void> toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}