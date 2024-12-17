import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _useMaterial3Key = 'use_material3';
  bool _isDarkMode = false;
  bool _useMaterial3 = true;

  ThemeProvider() {
    _loadPreferences();
  }

  bool get isDarkMode => _isDarkMode;
  bool get useMaterial3 => _useMaterial3;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    _useMaterial3 = prefs.getBool(_useMaterial3Key) ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleMaterial3() async {
    _useMaterial3 = !_useMaterial3;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useMaterial3Key, _useMaterial3);
    notifyListeners();
  }
}
