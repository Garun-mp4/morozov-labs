import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:sequence_trainer/domain/enums/difficulty.dart';
import 'package:sequence_trainer/domain/enums/sequence_type.dart';
import 'package:sequence_trainer/domain/models/sequence_task.dart';
import 'package:sequence_trainer/logic/sequence_generator.dart';

void main() {
  group('SequenceGenerator', () {
    for (final difficulty in Difficulty.values) {
      test('генерирует 300 корректных заданий для ${difficulty.name}', () {
        final generator = SequenceGenerator(random: Random(100 + difficulty.index));
        final tasks = generator.generateSession(difficulty: difficulty, count: 300);

        expect(tasks, hasLength(300));
        expect(tasks.map((task) => task.signature).toSet(), hasLength(300));
        for (final task in tasks) {
          expect(task.values, hasLength(4));
          _expectTaskIsValid(task);
        }
      });
    }

    test('каждый уровень выдаёт 10 уникальных корректных заданий', () {
      final generator = SequenceGenerator(random: Random(42));
      for (var level = 1; level <= 6; level++) {
        final tasks = generator.generateLevel(levelId: level);
        expect(tasks, hasLength(10));
        expect(tasks.map((task) => task.signature).toSet(), hasLength(10));
        for (final task in tasks) {
          _expectTaskIsValid(task);
        }
      }
    });
  });
}

void _expectTaskIsValid(SequenceTask task) {
  final values = task.values;
  switch (task.type) {
    case SequenceType.addition:
    case SequenceType.subtraction:
      final delta = values[1] - values[0];
      for (var i = 1; i < values.length; i++) {
        expect(values[i] - values[i - 1], delta);
      }
      expect(task.answer, values.last + delta);
      break;
    case SequenceType.multiplication:
      final multiplier = values[1] ~/ values[0];
      expect(multiplier, greaterThanOrEqualTo(2));
      for (var i = 1; i < values.length; i++) {
        expect(values[i], values[i - 1] * multiplier);
      }
      expect(task.answer, values.last * multiplier);
      break;
    case SequenceType.division:
      final divisor = values[0] ~/ values[1];
      expect(divisor, greaterThanOrEqualTo(2));
      for (var i = 1; i < values.length; i++) {
        expect(values[i - 1], values[i] * divisor);
      }
      expect(values.last, task.answer * divisor);
      break;
    case SequenceType.squares:
      final roots = values.map((value) => sqrt(value).round()).toList();
      for (var i = 0; i < values.length; i++) {
        expect(roots[i] * roots[i], values[i]);
        if (i > 0) expect(roots[i], roots[i - 1] + 1);
      }
      expect(task.answer, (roots.last + 1) * (roots.last + 1));
      break;
    case SequenceType.fibonacci:
      expect(values[2], values[0] + values[1]);
      expect(values[3], values[1] + values[2]);
      expect(task.answer, values[2] + values[3]);
      break;
    case SequenceType.growingStep:
      final deltas = <int>[
        values[1] - values[0],
        values[2] - values[1],
        values[3] - values[2],
        task.answer - values[3],
      ];
      expect(deltas[1], deltas[0] + 2);
      expect(deltas[2], deltas[1] + 2);
      expect(deltas[3], deltas[2] + 2);
      break;
  }
}
