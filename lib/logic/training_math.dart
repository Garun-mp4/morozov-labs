import '../domain/models/session_item.dart';

class TrainingMath {
  const TrainingMath._();

  static int accuracyPercent({required int correct, required int total}) {
    if (total <= 0) return 0;
    return ((correct / total) * 100).round();
  }

  static int currentStreak(List<SessionItem> items) {
    var streak = 0;
    for (final item in items) {
      if (!item.isAnswered) break;
      if (item.isCorrect == true) {
        streak += 1;
      } else {
        streak = 0;
      }
    }
    return streak;
  }

  static int bestStreak(List<SessionItem> items) {
    var best = 0;
    var current = 0;
    for (final item in items) {
      if (!item.isAnswered) continue;
      if (item.isCorrect == true) {
        current += 1;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }
}
