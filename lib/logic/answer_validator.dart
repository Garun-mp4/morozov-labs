class AnswerValidator {
  const AnswerValidator._();

  static String? validate(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Введите ответ';
    if (!RegExp(r'^-?\d+$').hasMatch(trimmed)) {
      return 'Введите целое число';
    }
    if (int.tryParse(trimmed) == null) {
      return 'Число слишком большое';
    }
    return null;
  }
}
