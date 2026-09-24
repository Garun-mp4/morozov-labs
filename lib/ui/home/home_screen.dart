import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/metric_tile.dart';
import 'home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(context.read<TrainingRepository>())..load(),
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  Future<void> _startNew(BuildContext context, HomeViewModel vm) async {
    if (vm.activeSession != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Начать новую тренировку?'),
          content: const Text(
            'При запуске новой сессии текущая незавершённая тренировка будет отмечена как прерванная. Вы можете продолжить её сейчас или перейти к настройке новой.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Начать новую')),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    await context.read<FeedbackService>().play(FeedbackEvent.tap);
    if (context.mounted) context.push('/training/setup');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      showAppBar: false,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
      child: vm.loading
          ? const LoadingState()
          : vm.error != null
              ? ErrorState(message: vm.error!, onRetry: vm.load)
              : ListView(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.functions_rounded, color: theme.colorScheme.onPrimary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SEQUENCE', style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 1.3)),
                              Text(
                                'Тренажёр числовых последовательностей',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    Text('Тренируйте логику,\nа не угадывание.', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 12),
                    Text(
                      'Находите закономерности, получайте объяснение после каждого ответа и следите за прогрессом.',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    if (vm.activeSession != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.play_circle_outline_rounded, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text('Незавершённая тренировка', style: theme.textTheme.titleMedium),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('${vm.activeSession!.totalQuestions} заданий · прогресс сохранён'),
                              const SizedBox(height: 16),
                              FilledButton(
                                key: const Key('continue_training_button'),
                                onPressed: () => context.push('/training/${vm.activeSession!.id}'),
                                child: const Text('Продолжить'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
                      key: const Key('new_training_button'),
                      onPressed: () => _startNew(context, vm),
                      child: const Text('Новая тренировка'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        MetricTile(value: '${vm.statistics.accuracyPercent}%', label: 'точность', icon: Icons.track_changes_rounded),
                        const SizedBox(width: 12),
                        MetricTile(value: '${vm.statistics.bestStreak}', label: 'лучшая серия', icon: Icons.local_fire_department_outlined),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Меню', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    _MenuTile(
                      icon: Icons.stairs_rounded,
                      title: 'Уровни',
                      subtitle: '6 этапов с постепенным усложнением',
                      onTap: () => context.push('/levels'),
                    ),
                    _MenuTile(
                      icon: Icons.insights_outlined,
                      title: 'Статистика',
                      subtitle: 'Точность и результаты по типам заданий',
                      onTap: () => context.push('/statistics'),
                    ),
                    _MenuTile(
                      icon: Icons.history_rounded,
                      title: 'История',
                      subtitle: 'Разбор завершённых тренировок',
                      onTap: () => context.push('/history'),
                    ),
                    _MenuTile(
                      icon: Icons.tune_rounded,
                      title: 'Настройки',
                      subtitle: 'Звук, вибрация, тема и данные',
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
