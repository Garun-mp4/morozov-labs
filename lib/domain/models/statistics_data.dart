import '../enums/sequence_type.dart';

class TypeStatistics {
  const TypeStatistics({required this.total, required this.correct});

  final int total;
  final int correct;

  double get accuracy => total == 0 ? 0 : correct / total;
  int get accuracyPercent => (accuracy * 100).round();
}

class StatisticsData {
  const StatisticsData({
    required this.totalAnswered,
    required this.totalCorrect,
    required this.bestStreak,
    required this.completedSessions,
    required this.byType,
  });

  const StatisticsData.empty()
      : totalAnswered = 0,
        totalCorrect = 0,
        bestStreak = 0,
        completedSessions = 0,
        byType = const {};

  final int totalAnswered;
  final int totalCorrect;
  final int bestStreak;
  final int completedSessions;
  final Map<SequenceType, TypeStatistics> byType;

  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;
  int get accuracyPercent => (accuracy * 100).round();
}
