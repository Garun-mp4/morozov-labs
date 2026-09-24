import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/session_mode.dart';
import '../../logic/sequence_generator.dart';

class TrainingSetupViewModel extends ChangeNotifier {
  TrainingSetupViewModel(this._repository, this._generator);

  final TrainingRepository _repository;
  final SequenceGenerator _generator;

  Difficulty difficulty = Difficulty.medium;
  int questionCount = 10;
  bool creating = false;
  String? error;

  void selectDifficulty(Difficulty value) {
    difficulty = value;
    notifyListeners();
  }

  void selectCount(int value) {
    questionCount = value;
    notifyListeners();
  }

  Future<int?> createTraining() async {
    creating = true;
    error = null;
    notifyListeners();
    try {
      final tasks = _generator.generateSession(
        difficulty: difficulty,
        count: questionCount,
      );
      return await _repository.createSession(
        mode: SessionMode.training,
        difficulty: difficulty,
        tasks: tasks,
      );
    } catch (_) {
      error = 'Не удалось создать тренировку.';
      return null;
    } finally {
      creating = false;
      notifyListeners();
    }
  }
}
