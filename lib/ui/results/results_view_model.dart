import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/models/session_result.dart';

class ResultsViewModel extends ChangeNotifier {
  ResultsViewModel(this._repository, this.sessionId);

  final TrainingRepository _repository;
  final int sessionId;

  bool loading = true;
  String? error;
  SessionResult? result;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      result = await _repository.getResult(sessionId);
      if (result == null) error = 'Результат не найден.';
    } catch (_) {
      error = 'Не удалось загрузить результат.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
