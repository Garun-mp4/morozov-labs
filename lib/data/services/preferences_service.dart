import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService() : _preferences = SharedPreferencesAsync();

  static const _soundKey = 'sound_enabled';
  static const _hapticsKey = 'haptics_enabled';
  static const _themeKey = 'theme_mode';

  final SharedPreferencesAsync _preferences;

  Future<bool> getSoundEnabled() async {
    return await _preferences.getBool(_soundKey) ?? true;
  }

  Future<void> setSoundEnabled(bool value) {
    return _preferences.setBool(_soundKey, value);
  }

  Future<bool> getHapticsEnabled() async {
    return await _preferences.getBool(_hapticsKey) ?? true;
  }

  Future<void> setHapticsEnabled(bool value) {
    return _preferences.setBool(_hapticsKey, value);
  }

  Future<ThemeMode> getThemeMode() async {
    final value = await _preferences.getString(_themeKey) ?? 'system';
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) {
    return _preferences.setString(_themeKey, mode.name);
  }
}
