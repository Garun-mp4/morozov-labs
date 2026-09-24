import 'package:flutter_test/flutter_test.dart';
import 'package:sequence_trainer/domain/enums/sequence_type.dart';
import 'package:sequence_trainer/domain/models/session_item.dart';
import 'package:sequence_trainer/logic/training_math.dart';

SessionItem item(int position, bool? correct) {
  return SessionItem(
    id: position + 1,
    sessionId: 1,
    position: position,
    type: SequenceType.addition,
    values: const [2, 4, 6, 8],
    correctAnswer: 10,
    explanation: 'Шаг +2.',
    userAnswer: correct == null ? null : (correct ? 10 : 9),
    isCorrect: correct,
    answeredAt: correct == null ? null : DateTime(2026, 9, 24),
  );
}

void main() {
  test('accuracyPercent корректно обрабатывает обычные и пустые данные', () {
    expect(TrainingMath.accuracyPercent(correct: 8, total: 10), 80);
    expect(TrainingMath.accuracyPercent(correct: 0, total: 0), 0);
  });

  test('bestStreak находит максимальную серию правильных ответов', () {
    final items = [
      item(0, true),
      item(1, true),
      item(2, false),
      item(3, true),
      item(4, true),
      item(5, true),
      item(6, null),
    ];

    expect(TrainingMath.bestStreak(items), 3);
    expect(TrainingMath.currentStreak(items), 3);
  });
}
