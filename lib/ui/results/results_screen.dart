import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/enums/sequence_type.dart';
import '../../domain/models/session_item.dart';
import '../../utils/formatters.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/metric_tile.dart';
import 'results_view_model.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({
    required this.sessionId,
    super.key,
    this.fromHistory = false,
  });

  final int sessionId;
  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ResultsViewModel(
        context.read<TrainingRepository>(),
        sessionId,
      )..load(),
      child: _ResultsContent(fromHistory: fromHistory),
    );
  }
}

class _ResultsContent extends StatelessWidget {
  const _ResultsContent({required this.fromHistory});

  final bool fromHistory;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ResultsViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: fromHistory ? 'Результат тренировки' : 'Тренировка завершена',
      child: vm.loading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: vm.load)
              : Builder(
                  builder: (context) {
                    final result = vm.result!;
                    final perfect = result.correctCount == result.answeredCount && result.answeredCount > 0;
                    final title = perfect
                        ? 'Идеальный результат'
                        : result.accuracyPercent >= 80
                            ? 'Отличная работа'
                            : result.accuracyPercent >= 60
                                ? 'Хороший прогресс'
                                : 'Продолжайте тренировку';

                    return ListView(
                      children: [
                        const SizedBox(height: 8),
                        _ResultHero(
                          perfect: perfect,
                          title: title,
                          score: '${result.correctCount} / ${result.answeredCount}',
                          accuracy: '${result.accuracyPercent}% правильных ответов',
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            MetricTile(value: '${result.session.bestStreak}', label: 'лучшая серия'),
                            const SizedBox(width: 10),
                            MetricTile(value: '${result.incorrectCount}', label: 'ошибок'),
                            const SizedBox(width: 10),
                            MetricTile(value: formatDuration(result.duration), label: 'время'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text('Ответы', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 10),
                        ...result.items.map((item) => _AnswerRow(item: item)),
                        const SizedBox(height: 24),
                        if (!fromHistory) ...[
                          FilledButton(
                            key: const Key('results_home_button'),
                            onPressed: () => context.go('/'),
                            child: const Text('На главную'),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => context.go('/training/setup'),
                            child: const Text('Ещё одна тренировка'),
                          ),
                        ] else
                          FilledButton.tonal(
                            onPressed: () => context.pop(),
                            child: const Text('Назад к истории'),
                          ),
                      ],
                    );
                  },
                ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.perfect,
    required this.title,
    required this.score,
    required this.accuracy,
  });

  final bool perfect;
  final String title;
  final String score;
  final String accuracy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.94, end: 1.0),
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: reduceMotion ? 1.0 : ((value - 0.94) / 0.06).clamp(0.0, 1.0),
          child: Transform.scale(scale: value, child: child),
        );
      },
      child: Column(
        children: [
          Icon(
            perfect
                ? Icons.workspace_premium_rounded
                : Icons.check_circle_outline_rounded,
            size: 54,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            score,
            style: theme.textTheme.displaySmall?.copyWith(fontSize: 46),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            accuracy,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({required this.item});

  final SessionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = item.isCorrect == true;
    final color = correct ? theme.colorScheme.primary : theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Card(
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.10),
            foregroundColor: color,
            child: Icon(correct ? Icons.check_rounded : Icons.close_rounded),
          ),
          title: Text('${item.values.join('  ')}  ?'),
          subtitle: Text(
            correct
                ? 'Ответ: ${item.userAnswer}'
                : 'Ваш ответ: ${item.userAnswer} · правильно: ${item.correctAnswer}',
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.explanation, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('Тип: ${item.type.title}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
