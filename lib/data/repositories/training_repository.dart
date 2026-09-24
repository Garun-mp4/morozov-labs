import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../domain/enums/difficulty.dart';
import '../../domain/enums/sequence_type.dart';
import '../../domain/enums/session_mode.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/models/history_entry.dart';
import '../../domain/models/sequence_task.dart';
import '../../domain/models/session_item.dart';
import '../../domain/models/session_result.dart';
import '../../domain/models/statistics_data.dart';
import '../../domain/models/training_session.dart';
import '../services/database_service.dart';

class TrainingRepository {
  const TrainingRepository(this._databaseService);

  final DatabaseService _databaseService;

  Database get _db => _databaseService.database;

  Future<int> createSession({
    required SessionMode mode,
    required List<SequenceTask> tasks,
    Difficulty? difficulty,
    int? levelId,
  }) async {
    if (tasks.isEmpty) throw ArgumentError('tasks must not be empty');

    return _db.transaction((txn) async {
      await txn.update(
        'sessions',
        {'status': SessionStatus.abandoned.dbValue},
        where: 'status = ?',
        whereArgs: [SessionStatus.inProgress.dbValue],
      );

      final sessionId = await txn.insert('sessions', {
        'mode': mode.dbValue,
        'difficulty': difficulty?.dbValue,
        'level_id': levelId,
        'total_questions': tasks.length,
        'status': SessionStatus.inProgress.dbValue,
        'best_streak': 0,
        'started_at': DateTime.now().millisecondsSinceEpoch,
      });

      final batch = txn.batch();
      for (var index = 0; index < tasks.length; index++) {
        final task = tasks[index];
        batch.insert('session_items', {
          'session_id': sessionId,
          'position': index,
          'sequence_type': task.type.dbValue,
          'sequence_json': jsonEncode(task.values),
          'correct_answer': task.answer,
          'explanation': task.explanation,
        });
      }
      await batch.commit(noResult: true);
      return sessionId;
    });
  }

  Future<TrainingSession?> getActiveSession() async {
    final rows = await _db.query(
      'sessions',
      where: 'status = ?',
      whereArgs: [SessionStatus.inProgress.dbValue],
      orderBy: 'started_at DESC',
      limit: 1,
    );
    return rows.isEmpty ? null : TrainingSession.fromMap(rows.first);
  }

  Future<TrainingSession?> getSession(int id) async {
    final rows = await _db.query('sessions', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : TrainingSession.fromMap(rows.first);
  }

  Future<List<SessionItem>> getItems(int sessionId) async {
    final rows = await _db.query(
      'session_items',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'position ASC',
    );
    return rows.map(SessionItem.fromMap).toList(growable: false);
  }

  Future<SessionResult?> getResult(int sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return null;
    return SessionResult(session: session, items: await getItems(sessionId));
  }

  Future<void> saveAnswer({
    required int itemId,
    required int userAnswer,
    required bool isCorrect,
  }) async {
    await _db.update(
      'session_items',
      {
        'user_answer': userAnswer,
        'is_correct': isCorrect ? 1 : 0,
        'answered_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND is_correct IS NULL',
      whereArgs: [itemId],
    );
  }

  Future<void> updateBestStreak(int sessionId, int bestStreak) async {
    await _db.update(
      'sessions',
      {'best_streak': bestStreak},
      where: 'id = ? AND best_streak < ?',
      whereArgs: [sessionId, bestStreak],
    );
  }

  Future<void> completeSession(int sessionId) async {
    await _db.update(
      'sessions',
      {
        'status': SessionStatus.completed.dbValue,
        'completed_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ? AND status = ?',
      whereArgs: [sessionId, SessionStatus.inProgress.dbValue],
    );
  }

  Future<List<HistoryEntry>> getHistory() async {
    final rows = await _db.rawQuery('''
      SELECT
        s.*,
        COUNT(i.id) AS answered,
        COALESCE(SUM(CASE WHEN i.is_correct = 1 THEN 1 ELSE 0 END), 0) AS correct
      FROM sessions s
      LEFT JOIN session_items i ON i.session_id = s.id AND i.is_correct IS NOT NULL
      WHERE s.status = ?
      GROUP BY s.id
      ORDER BY s.completed_at DESC
    ''', [SessionStatus.completed.dbValue]);

    return rows.map((row) {
      return HistoryEntry(
        session: TrainingSession.fromMap(row),
        correct: (row['correct'] as num).toInt(),
        answered: (row['answered'] as num).toInt(),
      );
    }).toList(growable: false);
  }

  Future<StatisticsData> getStatistics() async {
    final totalRows = await _db.rawQuery('''
      SELECT
        COUNT(i.id) AS total,
        COALESCE(SUM(CASE WHEN i.is_correct = 1 THEN 1 ELSE 0 END), 0) AS correct,
        COALESCE(MAX(s.best_streak), 0) AS best_streak
      FROM sessions s
      LEFT JOIN session_items i ON i.session_id = s.id AND i.is_correct IS NOT NULL
      WHERE s.status = ?
    ''', [SessionStatus.completed.dbValue]);

    final sessionsRows = await _db.rawQuery(
      'SELECT COUNT(*) AS count FROM sessions WHERE status = ?',
      [SessionStatus.completed.dbValue],
    );

    final typeRows = await _db.rawQuery('''
      SELECT
        i.sequence_type,
        COUNT(i.id) AS total,
        COALESCE(SUM(CASE WHEN i.is_correct = 1 THEN 1 ELSE 0 END), 0) AS correct
      FROM session_items i
      INNER JOIN sessions s ON s.id = i.session_id
      WHERE s.status = ? AND i.is_correct IS NOT NULL
      GROUP BY i.sequence_type
    ''', [SessionStatus.completed.dbValue]);

    final total = totalRows.first;
    final byType = <SequenceType, TypeStatistics>{};
    for (final row in typeRows) {
      final type = SequenceTypeX.fromDb(row['sequence_type']! as String);
      byType[type] = TypeStatistics(
        total: (row['total'] as num).toInt(),
        correct: (row['correct'] as num).toInt(),
      );
    }

    return StatisticsData(
      totalAnswered: (total['total'] as num).toInt(),
      totalCorrect: (total['correct'] as num).toInt(),
      bestStreak: (total['best_streak'] as num).toInt(),
      completedSessions: (sessionsRows.first['count'] as num).toInt(),
      byType: byType,
    );
  }

  Future<int> getBestLevelAccuracy(int levelId) async {
    final rows = await _db.rawQuery('''
      SELECT
        s.id,
        COUNT(i.id) AS total,
        COALESCE(SUM(CASE WHEN i.is_correct = 1 THEN 1 ELSE 0 END), 0) AS correct
      FROM sessions s
      INNER JOIN session_items i ON i.session_id = s.id AND i.is_correct IS NOT NULL
      WHERE s.status = ? AND s.mode = ? AND s.level_id = ?
      GROUP BY s.id
    ''', [SessionStatus.completed.dbValue, SessionMode.level.dbValue, levelId]);

    var best = 0;
    for (final row in rows) {
      final total = (row['total'] as num).toInt();
      final correct = (row['correct'] as num).toInt();
      if (total > 0) {
        final score = ((correct / total) * 100).round();
        if (score > best) best = score;
      }
    }
    return best;
  }

  Future<void> deleteSession(int id) async {
    await _db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearProgress() async {
    await _db.delete('sessions');
  }
}
