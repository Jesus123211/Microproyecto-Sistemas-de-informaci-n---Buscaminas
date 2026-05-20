// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  String _numberStyle = 'Clásico'; // Clásico, Colorido, Retro, Minimalista

  ThemeMode get themeMode => _themeMode;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;
  String get numberStyle => _numberStyle;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    int themeIndex =
        prefs.getInt('themeMode') ?? 0; // 0=system, 1=light, 2=dark
    _themeMode = ThemeMode.values[themeIndex];
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;
    _numberStyle = prefs.getString('numberStyle') ?? 'Clásico';
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', value);
    notifyListeners();
  }

  Future<void> setAnimationsEnabled(bool value) async {
    _animationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animationsEnabled', value);
    notifyListeners();
  }

  Future<void> setNumberStyle(String style) async {
    _numberStyle = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('numberStyle', style);
    notifyListeners();
  }
}
