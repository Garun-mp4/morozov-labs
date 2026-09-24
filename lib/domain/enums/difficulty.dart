enum Difficulty { easy, medium, hard }

extension DifficultyX on Difficulty {
  String get dbValue => name;

  String get title => switch (this) {
        Difficulty.easy => 'Легко',
        Difficulty.medium => 'Средне',
        Difficulty.hard => 'Сложно',
      };

  String get description => switch (this) {
        Difficulty.easy => 'Сложение и вычитание с небольшими числами',
        Difficulty.medium => 'Базовые арифметические закономерности',
        Difficulty.hard => 'Все типы, включая особые последовательности',
      };

  static Difficulty? fromDb(String? value) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == value) return difficulty;
    }
    return null;
  }
}
