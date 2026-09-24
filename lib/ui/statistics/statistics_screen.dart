import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/enums/sequence_type.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/metric_tile.dart';
import 'statistics_view_model.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StatisticsViewModel(context.read<TrainingRepository>())..load(),
      child: const _StatisticsContent(),
    );
  }
}

class _StatisticsContent extends StatelessWidget {
  const _StatisticsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StatisticsViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: 'Статистика',
      child: vm.loading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: vm.load)
              : vm.data.completedSessions == 0
                  ? const EmptyState(
                      icon: Icons.insights_outlined,
                      title: 'Пока нет статистики',
                      message: 'Она появится после первой завершённой тренировки.',
                    )
                  : ListView(
                      children: [
                        Text('Общий прогресс', style: theme.textTheme.headlineMedium),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            MetricTile(value: '${vm.data.totalAnswered}', label: 'решено'),
                            const SizedBox(width: 10),
                            MetricTile(value: '${vm.data.totalCorrect}', label: 'правильно'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            MetricTile(value: '${vm.data.accuracyPercent}%', label: 'точность'),
                            const SizedBox(width: 10),
                            MetricTile(value: '${vm.data.bestStreak}', label: 'лучшая серия'),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Text('По типам заданий', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 12),
                        ...SequenceType.values.where(vm.data.byType.containsKey).map((type) {
                          final stats = vm.data.byType[type]!;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(type.title, style: theme.textTheme.titleMedium)),
                                        Text('${stats.accuracyPercent}%', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    LinearProgressIndicator(
                                      value: stats.accuracy,
                                      minHeight: 7,
                                      borderRadius: BorderRadius.circular(99),
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${stats.correct} из ${stats.total} правильно',
                                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
    );
  }
}
