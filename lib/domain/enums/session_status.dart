enum SessionStatus { inProgress, completed, abandoned }

extension SessionStatusX on SessionStatus {
  String get dbValue => switch (this) {
        SessionStatus.inProgress => 'in_progress',
        SessionStatus.completed => 'completed',
        SessionStatus.abandoned => 'abandoned',
      };

  static SessionStatus fromDb(String value) {
    return switch (value) {
      'completed' => SessionStatus.completed,
      'abandoned' => SessionStatus.abandoned,
      _ => SessionStatus.inProgress,
    };
  }
}
