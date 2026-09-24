import 'session_item.dart';
import 'training_session.dart';

class SessionResult {
  const SessionResult({
    required this.session,
    required this.items,
  });

  final TrainingSession session;
  final List<SessionItem> items;

  int get answeredCount => items.where((item) => item.isAnswered).length;
  int get correctCount => items.where((item) => item.isCorrect == true).length;
  int get incorrectCount => answeredCount - correctCount;
  double get accuracy => answeredCount == 0 ? 0 : correctCount / answeredCount;
  int get accuracyPercent => (accuracy * 100).round();

  Duration get duration {
    final end = session.completedAt ?? DateTime.now();
    return end.difference(session.startedAt);
  }
}
