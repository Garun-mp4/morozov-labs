import 'package:flutter/foundation.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/models/session_item.dart';
import '../../domain/models/training_session.dart';
import '../../logic/answer_validator.dart';
import '../../logic/training_math.dart';

class TrainingViewModel extends ChangeNotifier {
  TrainingViewModel(this._repository, this._feedback, this.sessionId);

  final TrainingRepository _repository;
  final FeedbackService _feedback;
  final int sessionId;

  bool loading = true;
  String? error;
  TrainingSession? session;
  List<SessionItem> items = const [];
  int currentIndex = 0;
  bool answerRevealed = false;
  bool submitting = false;

  SessionItem? get currentItem =>
      items.isEmpty || currentIndex >= items.length ? null : items[currentIndex];
  bool get isLast => items.isNotEmpty && currentIndex == items.length - 1;
  int get correctCount => items.where((item) => item.isCorrect == true).length;
  int get progressNumber => items.isEmpty ? 0 : currentIndex + 1;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final loadedSession = await _repository.getSession(sessionId);
      if (loadedSession == null) {
        error = 'Тренировка не найдена.';
        return;
      }
      session = loadedSession;
      items = await _repository.getItems(sessionId);
      if (loadedSession.status == SessionStatus.inProgress &&
          items.isNotEmpty &&
          items.every((item) => item.isAnswered)) {
        await _repository.completeSession(sessionId);
        session = await _repository.getSession(sessionId);
      }
      final firstUnanswered = items.indexWhere((item) => !item.isAnswered);
      if (firstUnanswered >= 0) {
        currentIndex = firstUnanswered;
        answerRevealed = false;
      } else {
        currentIndex = items.isEmpty ? 0 : items.length - 1;
        answerRevealed = items.isNotEmpty;
      }
    } catch (_) {
      error = 'Не удалось открыть тренировку.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<String?> submitAnswer(String rawValue) async {
    if (submitting) return null;
    final validation = AnswerValidator.validate(rawValue);
    if (validation != null) return validation;
    final item = currentItem;
    if (item == null || item.isAnswered) return null;

    submitting = true;
    notifyListeners();
    try {
      final answer = int.parse(rawValue.trim());
      final correct = answer == item.correctAnswer;
      final now = DateTime.now();

      await _repository.saveAnswer(
        itemId: item.id,
        userAnswer: answer,
        isCorrect: correct,
      );

      final updatedItems = List<SessionItem>.from(items);
      updatedItems[currentIndex] = item.copyWith(
        userAnswer: answer,
        isCorrect: correct,
        answeredAt: now,
      );
      items = updatedItems;

      final best = TrainingMath.bestStreak(items);
      await _repository.updateBestStreak(sessionId, best);

      answerRevealed = true;
      notifyListeners();
      await _feedback.play(correct ? FeedbackEvent.correct : FeedbackEvent.wrong);

      if (isLast && items.every((entry) => entry.isAnswered)) {
        await _repository.completeSession(sessionId);
        session = await _repository.getSession(sessionId);
      }
      return null;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (!answerRevealed || isLast) return;
    currentIndex += 1;
    answerRevealed = items[currentIndex].isAnswered;
    notifyListeners();
  }

  Future<void> playCompletionFeedback() async {
    final perfect = items.isNotEmpty && correctCount == items.length;
    await _feedback.play(perfect ? FeedbackEvent.perfect : FeedbackEvent.complete);
  }

  bool get isCompleted => session?.status == SessionStatus.completed;
}
