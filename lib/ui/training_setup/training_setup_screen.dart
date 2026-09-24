import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../../domain/enums/difficulty.dart';
import '../../logic/sequence_generator.dart';
import '../core/widgets/app_page.dart';
import 'training_setup_view_model.dart';

class TrainingSetupScreen extends StatelessWidget {
  const TrainingSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TrainingSetupViewModel(
        context.read<TrainingRepository>(),
        context.read<SequenceGenerator>(),
      ),
      child: const _TrainingSetupContent(),
    );
  }
}

class _TrainingSetupContent extends StatelessWidget {
  const _TrainingSetupContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrainingSetupViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: 'Новая тренировка',
      child: ListView(
        children: [
          Text('Настройте сессию', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Выберите сложность и количество заданий. После старта весь набор будет сохранён, поэтому тренировку можно продолжить позже.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          Text('Сложность', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          ...Difficulty.values.map((difficulty) {
            final selected = vm.difficulty == difficulty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                color: selected ? theme.colorScheme.primaryContainer : null,
                child: InkWell(
                  key: Key('difficulty_${difficulty.name}'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () async {
                    vm.selectDifficulty(difficulty);
                    await context.read<FeedbackService>().play(FeedbackEvent.selection);
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    title: Text(difficulty.title),
                    subtitle: Text(difficulty.description),
                    trailing: Icon(
                      selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 18),
          Text('Количество заданий', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SegmentedButton<int>(
            key: const Key('question_count_selector'),
            segments: const [
              ButtonSegment(value: 5, label: Text('5')),
              ButtonSegment(value: 10, label: Text('10')),
              ButtonSegment(value: 20, label: Text('20')),
            ],
            selected: {vm.questionCount},
            onSelectionChanged: (selection) async {
              vm.selectCount(selection.first);
              await context.read<FeedbackService>().play(FeedbackEvent.selection);
            },
          ),
          const SizedBox(height: 28),
          if (vm.error != null) ...[
            Text(vm.error!, style: TextStyle(color: theme.colorScheme.error)),
            const SizedBox(height: 12),
          ],
          FilledButton(
            key: const Key('start_training_button'),
            onPressed: vm.creating
                ? null
                : () async {
                    final id = await vm.createTraining();
                    if (id != null && context.mounted) {
                      await context.read<FeedbackService>().play(FeedbackEvent.tap);
                      if (context.mounted) context.go('/training/$id');
                    }
                  },
            child: vm.creating
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Начать тренировку'),
          ),
        ],
      ),
    );
  }
}
