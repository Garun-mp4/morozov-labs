import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sequence_trainer/ui/core/widgets/sequence_display.dart';

void main() {
  testWidgets('SequenceDisplay показывает четыре числа и знак вопроса', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SequenceDisplay(values: [2, 4, 6, 8]),
        ),
      ),
    );

    expect(find.text('2'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('?'), findsOneWidget);
  });
}
