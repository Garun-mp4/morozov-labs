import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/models/statistics_data.dart';
import '../../domain/models/training_session.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final TrainingRepository _repository;

  bool loading = true;
  String? error;
  TrainingSession? activeSession;
  StatisticsData statistics = const StatisticsData.empty();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final values = await Future.wait<Object?>([
        _repository.getActiveSession(),
        _repository.getStatistics(),
      ]);
      activeSession = values[0] as TrainingSession?;
      statistics = values[1]! as StatisticsData;
    } catch (_) {
      error = 'Не удалось загрузить данные приложения.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
