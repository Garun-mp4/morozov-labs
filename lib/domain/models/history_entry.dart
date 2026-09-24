import 'training_session.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.session,
    required this.correct,
    required this.answered,
  });

  final TrainingSession session;
  final int correct;
  final int answered;

  int get accuracyPercent => answered == 0 ? 0 : ((correct / answered) * 100).round();
}
