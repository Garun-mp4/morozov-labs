import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../domain/enums/difficulty.dart';
import '../../domain/enums/session_mode.dart';
import '../../utils/formatters.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/loading_state.dart';
import 'history_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HistoryViewModel(context.read<TrainingRepository>())..load(),
      child: const _HistoryContent(),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: 'История',
      child: vm.loading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: vm.load)
              : vm.entries.isEmpty
                  ? const EmptyState(
                      icon: Icons.history_rounded,
                      title: 'История пока пуста',
                      message: 'Завершите первую тренировку — результат появится здесь.',
                    )
                  : ListView.separated(
                      itemCount: vm.entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final entry = vm.entries[index];
                        final session = entry.session;
                        final sessionName = session.mode == SessionMode.level
                            ? 'Уровень ${session.levelId}'
                            : '${session.difficulty?.title ?? 'Тренировка'} · ${session.totalQuestions} заданий';
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => context.push('/history/${session.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(17),
                              child: Row(
                                children: [
                                  CircularProgressIndicator(
                                    value: entry.accuracyPercent / 100,
                                    strokeWidth: 5,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(sessionName, style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 3),
                                        Text(
                                          formatDateTime(session.completedAt ?? session.startedAt),
                                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${entry.correct}/${entry.answered}', style: theme.textTheme.titleMedium),
                                      Text('${entry.accuracyPercent}%', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
