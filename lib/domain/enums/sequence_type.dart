enum SequenceType {
  addition,
  subtraction,
  multiplication,
  division,
  squares,
  fibonacci,
  growingStep,
}

extension SequenceTypeX on SequenceType {
  String get dbValue => name;

  String get title => switch (this) {
        SequenceType.addition => 'Сложение',
        SequenceType.subtraction => 'Вычитание',
        SequenceType.multiplication => 'Умножение',
        SequenceType.division => 'Деление',
        SequenceType.squares => 'Квадраты',
        SequenceType.fibonacci => 'Фибоначчи',
        SequenceType.growingStep => 'Растущий шаг',
      };

  static SequenceType fromDb(String value) {
    return SequenceType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => SequenceType.addition,
    );
  }
}
