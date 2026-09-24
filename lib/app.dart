import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/training_repository.dart';
import 'data/services/feedback_service.dart';
import 'logic/sequence_generator.dart';
import 'ui/settings/settings_view_model.dart';

class SequenceTrainerApp extends StatefulWidget {
  const SequenceTrainerApp({
    required this.trainingRepository,
    required this.settingsRepository,
    required this.feedbackService,
    required this.settingsViewModel,
    super.key,
  });

  final TrainingRepository trainingRepository;
  final SettingsRepository settingsRepository;
  final FeedbackService feedbackService;
  final SettingsViewModel settingsViewModel;

  @override
  State<SequenceTrainerApp> createState() => _SequenceTrainerAppState();
}

class _SequenceTrainerAppState extends State<SequenceTrainerApp> {
  late final _router = AppRouter.create();
  late final _generator = SequenceGenerator();

  @override
  void dispose() {
    _router.dispose();
    widget.feedbackService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TrainingRepository>.value(value: widget.trainingRepository),
        Provider<SettingsRepository>.value(value: widget.settingsRepository),
        Provider<FeedbackService>.value(value: widget.feedbackService),
        Provider<SequenceGenerator>.value(value: _generator),
        ChangeNotifierProvider<SettingsViewModel>.value(value: widget.settingsViewModel),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Sequence Trainer',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
