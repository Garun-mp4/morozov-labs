import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../../logic/sequence_generator.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/loading_state.dart';
import 'levels_view_model.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LevelsViewModel(
        context.read<TrainingRepository>(),
        context.read<SequenceGenerator>(),
      )..load(),
      child: const _LevelsContent(),
    );
  }
}

class _LevelsContent extends StatelessWidget {
  const _LevelsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LevelsViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: 'Уровни',
      child: vm.loading
          ? const LoadingState()
          : vm.error != null && vm.levels.isEmpty
              ? ErrorState(message: vm.error!, onRetry: vm.load)
              : ListView(
                  children: [
                    Text('Путь обучения', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Следующий уровень открывается после результата не ниже 70% на предыдущем.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ...vm.levels.map((level) {
                      final working = vm.creatingLevel == level.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: !level.unlocked || vm.creatingLevel != null
                                ? null
                                : () async {
                                    final repository = context.read<TrainingRepository>();
                                    final active = await repository.getActiveSession();
                                    if (!context.mounted) return;
                                    if (active != null) {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: const Text('Начать уровень?'),
                                          content: const Text(
                                            'Текущая незавершённая тренировка будет отмечена как прерванная. Уже отправленные ответы останутся в базе данных.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(dialogContext, false),
                                              child: const Text('Отмена'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.pop(dialogContext, true),
                                              child: const Text('Начать уровень'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed != true || !context.mounted) return;
                                    }
                                    await context.read<FeedbackService>().play(FeedbackEvent.tap);
                                    final id = await vm.startLevel(level.id);
                                    if (id != null && context.mounted) {
                                      context.go('/training/$id');
                                    }
                                  },
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: level.unlocked
                                          ? theme.colorScheme.primaryContainer
                                          : theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: Alignment.center,
                                    child: working
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                        : level.unlocked
                                            ? Text('${level.id}', style: theme.textTheme.titleLarge)
                                            : const Icon(Icons.lock_outline_rounded),
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(level.title, style: theme.textTheme.titleMedium),
                                        const SizedBox(height: 3),
                                        Text(level.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (level.bestScore > 0)
                                    Text('${level.bestScore}%', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary))
                                  else if (level.unlocked)
                                    const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
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
