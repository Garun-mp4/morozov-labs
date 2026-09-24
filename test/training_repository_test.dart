import 'package:flutter_test/flutter_test.dart';
import 'package:sequence_trainer/data/repositories/training_repository.dart';
import 'package:sequence_trainer/data/services/database_service.dart';
import 'package:sequence_trainer/domain/enums/difficulty.dart';
import 'package:sequence_trainer/domain/enums/sequence_type.dart';
import 'package:sequence_trainer/domain/enums/session_mode.dart';
import 'package:sequence_trainer/domain/enums/session_status.dart';
import 'package:sequence_trainer/domain/models/sequence_task.dart';

void main() {
  late DatabaseService databaseService;
  late TrainingRepository repository;

  setUp(() async {
    databaseService = DatabaseService(inMemory: true);
    await databaseService.initialize();
    repository = TrainingRepository(databaseService);
  });

  tearDown(() => databaseService.close());

  test('полный жизненный цикл сессии сохраняется в SQLite', () async {
    const tasks = [
      SequenceTask(
        values: [2, 4, 6, 8],
        answer: 10,
        type: SequenceType.addition,
        explanation: 'Шаг +2.',
      ),
      SequenceTask(
        values: [20, 15, 10, 5],
        answer: 0,
        type: SequenceType.subtraction,
        explanation: 'Шаг -5.',
      ),
    ];

    final id = await repository.createSession(
      mode: SessionMode.training,
      difficulty: Difficulty.easy,
      tasks: tasks,
    );

    final active = await repository.getActiveSession();
    expect(active?.id, id);
    expect(active?.status, SessionStatus.inProgress);

    final items = await repository.getItems(id);
    expect(items, hasLength(2));
    await repository.saveAnswer(itemId: items[0].id, userAnswer: 10, isCorrect: true);
    await repository.saveAnswer(itemId: items[1].id, userAnswer: 1, isCorrect: false);
    await repository.updateBestStreak(id, 1);
    await repository.completeSession(id);

    final result = await repository.getResult(id);
    expect(result, isNotNull);
    expect(result!.correctCount, 1);
    expect(result.accuracyPercent, 50);
    expect(result.session.status, SessionStatus.completed);

    final stats = await repository.getStatistics();
    expect(stats.totalAnswered, 2);
    expect(stats.totalCorrect, 1);
    expect(stats.bestStreak, 1);

    final history = await repository.getHistory();
    expect(history, hasLength(1));
    expect(history.first.accuracyPercent, 50);
  });

  test('повторное сохранение не перезаписывает уже отправленный ответ', () async {
    const task = SequenceTask(
      values: [2, 4, 6, 8],
      answer: 10,
      type: SequenceType.addition,
      explanation: 'Шаг +2.',
    );
    final id = await repository.createSession(
      mode: SessionMode.training,
      difficulty: Difficulty.easy,
      tasks: const [task],
    );
    final item = (await repository.getItems(id)).single;

    await repository.saveAnswer(
      itemId: item.id,
      userAnswer: 10,
      isCorrect: true,
    );
    await repository.saveAnswer(
      itemId: item.id,
      userAnswer: 999,
      isCorrect: false,
    );

    final stored = (await repository.getItems(id)).single;
    expect(stored.userAnswer, 10);
    expect(stored.isCorrect, isTrue);
  });

  test('удаление сессии каскадно удаляет её задания', () async {
    const task = SequenceTask(
      values: [1, 2, 3, 4],
      answer: 5,
      type: SequenceType.addition,
      explanation: 'Шаг +1.',
    );
    final id = await repository.createSession(
      mode: SessionMode.training,
      difficulty: Difficulty.easy,
      tasks: const [task],
    );
    expect(await repository.getItems(id), hasLength(1));
    await repository.deleteSession(id);
    expect(await repository.getItems(id), isEmpty);
  });
}
