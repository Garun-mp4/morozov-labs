enum SessionMode { training, level }

extension SessionModeX on SessionMode {
  String get dbValue => name;

  String get title => switch (this) {
        SessionMode.training => 'Тренировка',
        SessionMode.level => 'Уровень',
      };

  static SessionMode fromDb(String value) {
    return SessionMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => SessionMode.training,
    );
  }
}
