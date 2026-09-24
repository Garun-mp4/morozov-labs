import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sequence_trainer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('пользователь проходит тренировку из 5 заданий', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('new_training_button')));
    await tester.pumpAndSettle();

    if (find.text('Начать новую').evaluate().isNotEmpty) {
      await tester.tap(find.text('Начать новую'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('start_training_button')));
    await tester.pumpAndSettle();

    for (var index = 0; index < 5; index++) {
      final field = find.byType(TextFormField);
      expect(field, findsOneWidget);
      await tester.enterText(field, '0');
      await tester.tap(find.byKey(const Key('check_answer_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('next_question_button')));
      await tester.pumpAndSettle();
    }

    expect(find.text('Тренировка завершена'), findsOneWidget);
    expect(find.byKey(const Key('results_home_button')), findsOneWidget);
  });
}
