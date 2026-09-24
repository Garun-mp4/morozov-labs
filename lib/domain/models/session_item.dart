import 'dart:convert';

import '../enums/sequence_type.dart';

class SessionItem {
  const SessionItem({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.type,
    required this.values,
    required this.correctAnswer,
    required this.explanation,
    this.userAnswer,
    this.isCorrect,
    this.answeredAt,
  });

  final int id;
  final int sessionId;
  final int position;
  final SequenceType type;
  final List<int> values;
  final int correctAnswer;
  final String explanation;
  final int? userAnswer;
  final bool? isCorrect;
  final DateTime? answeredAt;

  bool get isAnswered => isCorrect != null;

  SessionItem copyWith({
    int? userAnswer,
    bool? isCorrect,
    DateTime? answeredAt,
  }) {
    return SessionItem(
      id: id,
      sessionId: sessionId,
      position: position,
      type: type,
      values: values,
      correctAnswer: correctAnswer,
      explanation: explanation,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  factory SessionItem.fromMap(Map<String, Object?> map) {
    final decoded = jsonDecode(map['sequence_json']! as String) as List<dynamic>;
    return SessionItem(
      id: map['id']! as int,
      sessionId: map['session_id']! as int,
      position: map['position']! as int,
      type: SequenceTypeX.fromDb(map['sequence_type']! as String),
      values: decoded.map((value) => value as int).toList(growable: false),
      correctAnswer: map['correct_answer']! as int,
      explanation: map['explanation']! as String,
      userAnswer: map['user_answer'] as int?,
      isCorrect: map['is_correct'] == null
          ? null
          : (map['is_correct']! as int) == 1,
      answeredAt: map['answered_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['answered_at']! as int),
    );
  }
}
