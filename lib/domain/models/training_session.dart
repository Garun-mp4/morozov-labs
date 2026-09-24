import '../enums/difficulty.dart';
import '../enums/session_mode.dart';
import '../enums/session_status.dart';

class TrainingSession {
  const TrainingSession({
    required this.id,
    required this.mode,
    required this.totalQuestions,
    required this.status,
    required this.bestStreak,
    required this.startedAt,
    this.difficulty,
    this.levelId,
    this.completedAt,
  });

  final int id;
  final SessionMode mode;
  final Difficulty? difficulty;
  final int? levelId;
  final int totalQuestions;
  final SessionStatus status;
  final int bestStreak;
  final DateTime startedAt;
  final DateTime? completedAt;

  factory TrainingSession.fromMap(Map<String, Object?> map) {
    return TrainingSession(
      id: map['id']! as int,
      mode: SessionModeX.fromDb(map['mode']! as String),
      difficulty: DifficultyX.fromDb(map['difficulty'] as String?),
      levelId: map['level_id'] as int?,
      totalQuestions: map['total_questions']! as int,
      status: SessionStatusX.fromDb(map['status']! as String),
      bestStreak: map['best_streak']! as int,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at']! as int),
      completedAt: map['completed_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['completed_at']! as int),
    );
  }
}
