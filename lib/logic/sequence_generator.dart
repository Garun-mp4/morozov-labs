import 'dart:math';

import '../domain/enums/difficulty.dart';
import '../domain/enums/sequence_type.dart';
import '../domain/models/sequence_task.dart';

class SequenceGenerator {
  SequenceGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<SequenceTask> generateSession({
    required Difficulty difficulty,
    required int count,
  }) {
    final allowed = switch (difficulty) {
      Difficulty.easy => <SequenceType>[
          SequenceType.addition,
          SequenceType.subtraction,
        ],
      Difficulty.medium => <SequenceType>[
          SequenceType.addition,
          SequenceType.subtraction,
          SequenceType.multiplication,
          SequenceType.division,
        ],
      Difficulty.hard => SequenceType.values,
    };
    return _generateUnique(count: count, allowed: allowed, difficulty: difficulty);
  }

  List<SequenceTask> generateLevel({required int levelId, int count = 10}) {
    final types = switch (levelId) {
      1 => <SequenceType>[SequenceType.addition],
      2 => <SequenceType>[SequenceType.subtraction],
      3 => <SequenceType>[SequenceType.multiplication],
      4 => <SequenceType>[SequenceType.division],
      5 => <SequenceType>[
          SequenceType.addition,
          SequenceType.subtraction,
          SequenceType.multiplication,
          SequenceType.division,
        ],
      _ => <SequenceType>[
          SequenceType.squares,
          SequenceType.fibonacci,
          SequenceType.growingStep,
        ],
    };

    final difficulty = switch (levelId) {
      1 || 2 => Difficulty.easy,
      3 || 4 || 5 => Difficulty.medium,
      _ => Difficulty.hard,
    };

    return _generateUnique(count: count, allowed: types, difficulty: difficulty);
  }

  List<SequenceTask> _generateUnique({
    required int count,
    required List<SequenceType> allowed,
    required Difficulty difficulty,
  }) {
    final tasks = <SequenceTask>[];
    final signatures = <String>{};
    var attempts = 0;

    while (tasks.length < count && attempts < count * 100) {
      attempts += 1;
      final type = allowed[_random.nextInt(allowed.length)];
      final task = generate(type: type, difficulty: difficulty);
      if (signatures.add(task.signature)) tasks.add(task);
    }

    if (tasks.length != count) {
      throw StateError('Не удалось сгенерировать уникальный набор заданий.');
    }
    return tasks;
  }

  SequenceTask generate({
    required SequenceType type,
    required Difficulty difficulty,
  }) {
    return switch (type) {
      SequenceType.addition => _addition(difficulty),
      SequenceType.subtraction => _subtraction(difficulty),
      SequenceType.multiplication => _multiplication(difficulty),
      SequenceType.division => _division(difficulty),
      SequenceType.squares => _squares(),
      SequenceType.fibonacci => _fibonacci(),
      SequenceType.growingStep => _growingStep(difficulty),
    };
  }

  SequenceTask _addition(Difficulty difficulty) {
    final start = difficulty == Difficulty.hard
        ? _between(-25, 45)
        : _between(1, difficulty == Difficulty.easy ? 25 : 50);
    final step = _between(2, difficulty == Difficulty.easy ? 8 : 15);
    final values = List<int>.generate(4, (index) => start + step * index);
    return SequenceTask(
      values: values,
      answer: start + step * 4,
      type: SequenceType.addition,
      explanation: 'Каждое следующее число увеличивается на $step.',
    );
  }

  SequenceTask _subtraction(Difficulty difficulty) {
    final step = _between(2, difficulty == Difficulty.easy ? 8 : 15);
    final minStart = step * 4 + (difficulty == Difficulty.hard ? -10 : 5);
    final start = _between(minStart, minStart + 50);
    final values = List<int>.generate(4, (index) => start - step * index);
    return SequenceTask(
      values: values,
      answer: start - step * 4,
      type: SequenceType.subtraction,
      explanation: 'Каждое следующее число уменьшается на $step.',
    );
  }

  SequenceTask _multiplication(Difficulty difficulty) {
    final multiplier = _between(2, difficulty == Difficulty.hard ? 4 : 3);
    final start = _between(1, difficulty == Difficulty.hard ? 5 : 4);
    final values = <int>[];
    var current = start;
    for (var i = 0; i < 4; i++) {
      values.add(current);
      current *= multiplier;
    }
    return SequenceTask(
      values: values,
      answer: current,
      type: SequenceType.multiplication,
      explanation: 'Каждое следующее число умножается на $multiplier.',
    );
  }

  SequenceTask _division(Difficulty difficulty) {
    final divisor = _between(2, difficulty == Difficulty.hard ? 5 : 4);
    final answer = _between(1, difficulty == Difficulty.hard ? 10 : 12);
    final values = <int>[];
    var current = answer;
    for (var i = 0; i < 4; i++) {
      current *= divisor;
      values.insert(0, current);
    }
    return SequenceTask(
      values: values,
      answer: answer,
      type: SequenceType.division,
      explanation: 'Каждое следующее число делится на $divisor.',
    );
  }

  SequenceTask _squares() {
    final start = _between(1, 7);
    final values = List<int>.generate(4, (index) {
      final number = start + index;
      return number * number;
    });
    final next = start + 4;
    return SequenceTask(
      values: values,
      answer: next * next,
      type: SequenceType.squares,
      explanation: 'Это квадраты последовательных целых чисел.',
    );
  }

  SequenceTask _fibonacci() {
    var first = _between(1, 5);
    var second = _between(1, 7);
    final values = <int>[first, second];
    while (values.length < 4) {
      final next = first + second;
      values.add(next);
      first = second;
      second = next;
    }
    return SequenceTask(
      values: values,
      answer: values[2] + values[3],
      type: SequenceType.fibonacci,
      explanation: 'Каждое число равно сумме двух предыдущих.',
    );
  }

  SequenceTask _growingStep(Difficulty difficulty) {
    final start = difficulty == Difficulty.hard ? _between(-8, 12) : _between(1, 10);
    final firstStep = _between(1, 4);
    final values = <int>[start];
    var current = start;
    var step = firstStep;
    for (var i = 0; i < 3; i++) {
      current += step;
      values.add(current);
      step += 2;
    }
    final answer = current + step;
    return SequenceTask(
      values: values,
      answer: answer,
      type: SequenceType.growingStep,
      explanation:
          'Шаг увеличивается на 2: +$firstStep, +${firstStep + 2}, +${firstStep + 4}, +${firstStep + 6}.',
    );
  }

  int _between(int min, int max) => min + _random.nextInt(max - min + 1);
}
