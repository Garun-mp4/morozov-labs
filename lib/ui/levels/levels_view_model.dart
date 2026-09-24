import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/enums/session_mode.dart';
import '../../logic/sequence_generator.dart';

class LevelState {
  const LevelState({
    required this.id,
    required this.title,
    required this.description,
    required this.bestScore,
    required this.unlocked,
  });

  final int id;
  final String title;
  final String description;
  final int bestScore;
  final bool unlocked;
}

class LevelsViewModel extends ChangeNotifier {
  LevelsViewModel(this._repository, this._generator);

  final TrainingRepository _repository;
  final SequenceGenerator _generator;

  bool loading = true;
  String? error;
  List<LevelState> levels = const [];
  int? creatingLevel;

  static const _titles = <String>[
    'Сложение',
    'Вычитание',
    'Умножение',
    'Деление',
    'Смешанные',
    'Особые закономерности',
  ];

  static const _descriptions = <String>[
    'Постоянный положительный шаг',
    'Постоянный отрицательный шаг',
    'Последовательное умножение',
    'Последовательное деление',
    'Все базовые типы вперемешку',
    'Квадраты, Фибоначчи и растущий шаг',
  ];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final scores = <int>[];
      for (var id = 1; id <= 6; id++) {
        scores.add(await _repository.getBestLevelAccuracy(id));
      }
      levels = List<LevelState>.generate(6, (index) {
        final id = index + 1;
        final unlocked = id == 1 || scores[index - 1] >= 70;
        return LevelState(
          id: id,
          title: _titles[index],
          description: _descriptions[index],
          bestScore: scores[index],
          unlocked: unlocked,
        );
      });
    } catch (_) {
      error = 'Не удалось загрузить уровни.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<int?> startLevel(int levelId) async {
    creatingLevel = levelId;
    notifyListeners();
    try {
      final tasks = _generator.generateLevel(levelId: levelId);
      return await _repository.createSession(
        mode: SessionMode.level,
        levelId: levelId,
        tasks: tasks,
      );
    } catch (_) {
      error = 'Не удалось начать уровень.';
      return null;
    } finally {
      creatingLevel = null;
      notifyListeners();
    }
  }
}
