import 'package:flutter/material.dart';

import '../../data/repositories/settings_repository.dart';
import '../../data/services/feedback_service.dart';

class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repository, this._feedback);

  final SettingsRepository _repository;
  final FeedbackService _feedback;

  bool loading = true;
  bool soundEnabled = true;
  bool hapticsEnabled = true;
  ThemeMode themeMode = ThemeMode.system;

  Future<void> load() async {
    final settings = await _repository.load();
    soundEnabled = settings.soundEnabled;
    hapticsEnabled = settings.hapticsEnabled;
    themeMode = settings.themeMode;
    _feedback.configure(sound: soundEnabled, haptics: hapticsEnabled);
    loading = false;
    notifyListeners();
  }

  Future<void> setSound(bool value) async {
    soundEnabled = value;
    _feedback.configure(sound: soundEnabled, haptics: hapticsEnabled);
    notifyListeners();
    await _repository.setSoundEnabled(value);
  }

  Future<void> setHaptics(bool value) async {
    hapticsEnabled = value;
    _feedback.configure(sound: soundEnabled, haptics: hapticsEnabled);
    notifyListeners();
    await _repository.setHapticsEnabled(value);
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _repository.setThemeMode(value);
  }
}
