import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/models/statistics_data.dart';

class StatisticsViewModel extends ChangeNotifier {
  StatisticsViewModel(this._repository);

  final TrainingRepository _repository;

  bool loading = true;
  String? error;
  StatisticsData data = const StatisticsData.empty();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _repository.getStatistics();
    } catch (_) {
      error = 'Не удалось загрузить статистику.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
