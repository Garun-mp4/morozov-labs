import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/models/history_entry.dart';

class HistoryViewModel extends ChangeNotifier {
  HistoryViewModel(this._repository);

  final TrainingRepository _repository;

  bool loading = true;
  String? error;
  List<HistoryEntry> entries = const [];

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      entries = await _repository.getHistory();
    } catch (_) {
      error = 'Не удалось загрузить историю.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
