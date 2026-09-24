import 'package:flutter_test/flutter_test.dart';
import 'package:sequence_trainer/logic/answer_validator.dart';

void main() {
  test('принимает целые положительные и отрицательные значения', () {
    expect(AnswerValidator.validate('42'), isNull);
    expect(AnswerValidator.validate('-17'), isNull);
    expect(AnswerValidator.validate('  8  '), isNull);
  });

  test('отклоняет пустые, дробные и нечисловые ответы', () {
    expect(AnswerValidator.validate(''), isNotNull);
    expect(AnswerValidator.validate('-'), isNotNull);
    expect(AnswerValidator.validate('4.5'), isNotNull);
    expect(AnswerValidator.validate('12a'), isNotNull);
  });
}
