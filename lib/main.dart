import 'package:flutter/material.dart';

import 'app.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/training_repository.dart';
import 'data/services/database_service.dart';
import 'data/services/feedback_service.dart';
import 'data/services/preferences_service.dart';
import 'ui/settings/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final databaseService = DatabaseService();
    await databaseService.initialize();

    final preferencesService = PreferencesService();
    final feedbackService = FeedbackService();
    final settingsRepository = SettingsRepository(preferencesService);
    final settingsViewModel = SettingsViewModel(settingsRepository, feedbackService);
    await settingsViewModel.load();

    runApp(
      SequenceTrainerApp(
        trainingRepository: TrainingRepository(databaseService),
        settingsRepository: settingsRepository,
        feedbackService: feedbackService,
        settingsViewModel: settingsViewModel,
      ),
    );
  } catch (error) {
    runApp(DatabaseInitializationErrorApp(error: error));
  }
}

class DatabaseInitializationErrorApp extends StatelessWidget {
  const DatabaseInitializationErrorApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storage_rounded, size: 54),
                    const SizedBox(height: 16),
                    const Text(
                      'Не удалось запустить приложение',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Перезапустите приложение. Если ошибка повторяется, проверьте локальное хранилище и настройки устройства.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
