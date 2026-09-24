import 'package:flutter/material.dart';

import '../services/preferences_service.dart';

class AppSettings {
  const AppSettings({
    required this.soundEnabled,
    required this.hapticsEnabled,
    required this.themeMode,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final ThemeMode themeMode;
}

class SettingsRepository {
  const SettingsRepository(this._preferences);

  final PreferencesService _preferences;

  Future<AppSettings> load() async {
    final values = await Future.wait<Object>([
      _preferences.getSoundEnabled(),
      _preferences.getHapticsEnabled(),
      _preferences.getThemeMode(),
    ]);

    return AppSettings(
      soundEnabled: values[0] as bool,
      hapticsEnabled: values[1] as bool,
      themeMode: values[2] as ThemeMode,
    );
  }

  Future<void> setSoundEnabled(bool value) =>
      _preferences.setSoundEnabled(value);

  Future<void> setHapticsEnabled(bool value) =>
      _preferences.setHapticsEnabled(value);

  Future<void> setThemeMode(ThemeMode value) =>
      _preferences.setThemeMode(value);
}
