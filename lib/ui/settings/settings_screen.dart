import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../core/widgets/app_page.dart';
import 'settings_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Сбросить прогресс?'),
        content: const Text(
          'Все тренировки, ответы, история и прогресс уровней будут удалены. Настройки звука и темы сохранятся.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<TrainingRepository>().clearProgress();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('История и прогресс удалены.')),
    );
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    return AppPage(
      title: 'Настройки',
      child: ListView(
        children: [
          Text('Обратная связь', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('sound_toggle'),
                  title: const Text('Звуковые эффекты'),
                  subtitle: const Text('Короткие звуки действий и результатов'),
                  value: vm.soundEnabled,
                  onChanged: (value) async {
                    await vm.setSound(value);
                    if (value && context.mounted) {
                      await context.read<FeedbackService>().play(FeedbackEvent.tap);
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  key: const Key('haptics_toggle'),
                  title: const Text('Тактильный отклик'),
                  subtitle: const Text('Системные виброэффекты Android'),
                  value: vm.hapticsEnabled,
                  onChanged: (value) async {
                    await vm.setHaptics(value);
                    if (value && context.mounted) {
                      await context.read<FeedbackService>().play(FeedbackEvent.selection);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Text('Оформление', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<ThemeMode>(
                key: ValueKey(vm.themeMode),
                initialValue: vm.themeMode,
                decoration: const InputDecoration(labelText: 'Тема приложения'),
                items: const [
                  DropdownMenuItem(value: ThemeMode.system, child: Text('Системная')),
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Светлая')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Тёмная')),
                ],
                onChanged: (value) {
                  if (value != null) vm.setTheme(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text('Данные', style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              title: Text('Сбросить прогресс', style: TextStyle(color: theme.colorScheme.error)),
              subtitle: const Text('Удалить историю тренировок и прогресс уровней'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _resetData(context),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sequence Trainer · лабораторная работа №1 · вариант 10',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
