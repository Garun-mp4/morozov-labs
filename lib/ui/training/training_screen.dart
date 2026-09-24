import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/training_repository.dart';
import '../../data/services/feedback_service.dart';
import '../../domain/models/session_item.dart';
import '../../logic/signed_integer_input_formatter.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/loading_state.dart';
import '../core/widgets/sequence_display.dart';
import 'training_view_model.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({required this.sessionId, super.key});

  final int sessionId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TrainingViewModel(
        context.read<TrainingRepository>(),
        context.read<FeedbackService>(),
        sessionId,
      )..load(),
      child: const _TrainingContent(),
    );
  }
}

class _TrainingContent extends StatefulWidget {
  const _TrainingContent();

  @override
  State<_TrainingContent> createState() => _TrainingContentState();
}

class _TrainingContentState extends State<_TrainingContent> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int? _lastItemId;
  String? _manualError;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из тренировки?'),
        content: const Text(
          'Все уже отправленные ответы сохранены. Продолжить можно будет из главного меню.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Остаться')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Сохранить и выйти')),
        ],
      ),
    );
    return result ?? false;
  }

  void _syncQuestion(TrainingViewModel vm) {
    final item = vm.currentItem;
    if (item == null || _lastItemId == item.id) return;
    _lastItemId = item.id;
    _controller.text = item.userAnswer?.toString() ?? '';
    _manualError = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !item.isAnswered) _focusNode.requestFocus();
    });
  }

  Future<void> _submit(TrainingViewModel vm) async {
    if (vm.answerRevealed) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final error = await vm.submitAnswer(_controller.text);
    if (!mounted) return;
    setState(() => _manualError = error);
    if (error == null) _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TrainingViewModel>();
    _syncQuestion(vm);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (vm.isCompleted) {
          if (context.mounted) context.go('/');
          return;
        }
        if (await _confirmExit() && context.mounted) context.go('/');
      },
      child: AppPage(
        title: vm.loading || vm.items.isEmpty
            ? 'Тренировка'
            : 'Задание ${vm.progressNumber} из ${vm.items.length}',
        child: vm.loading
            ? const LoadingState()
            : vm.error != null
                ? ErrorState(message: vm.error!, onRetry: vm.load)
                : _buildTask(context, vm),
      ),
    );
  }

  Widget _buildTask(BuildContext context, TrainingViewModel vm) {
    final item = vm.currentItem;
    if (item == null) {
      return const Center(child: Text('В тренировке нет заданий.'));
    }
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final progress = (vm.currentIndex + (item.isAnswered ? 1 : 0)) / vm.items.length;

    return ListView(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: 7,
            value: progress.clamp(0.0, 1.0).toDouble(),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 34),
        Text('Какое число следующее?', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: 28),
        SequenceDisplay(values: item.values),
        const SizedBox(height: 32),
        Form(
          key: _formKey,
          child: TextFormField(
            key: Key('answer_field_${item.id}'),
            controller: _controller,
            focusNode: _focusNode,
            enabled: !vm.answerRevealed,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            textInputAction: TextInputAction.done,
            inputFormatters: <TextInputFormatter>[SignedIntegerInputFormatter()],
            decoration: const InputDecoration(
              labelText: 'Ваш ответ',
              hintText: 'Введите целое число',
            ),
            validator: (value) {
              if (_manualError != null) return _manualError;
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Введите ответ';
              if (int.tryParse(text) == null) return 'Введите целое число';
              return null;
            },
            onFieldSubmitted: (_) => _submit(vm),
          ),
        ),
        const SizedBox(height: 16),
        if (!vm.answerRevealed)
          FilledButton(
            key: const Key('check_answer_button'),
            onPressed: vm.submitting ? null : () => _submit(vm),
            child: vm.submitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Проверить'),
          )
        else ...[
          AnimatedSwitcher(
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
            child: _AnswerFeedback(item: item),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('next_question_button'),
            onPressed: vm.submitting
                ? null
                : () async {
              if (vm.isLast) {
                await vm.playCompletionFeedback();
                if (context.mounted) context.go('/results/${vm.sessionId}');
              } else {
                vm.nextQuestion();
                setState(() {
                  _lastItemId = null;
                  _manualError = null;
                });
              }
            },
            child: Text(vm.isLast ? 'Посмотреть результат' : 'Следующее задание'),
          ),
        ],
      ],
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({required this.item});

  final SessionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = item.isCorrect == true;
    final color = correct ? theme.colorScheme.primary : theme.colorScheme.error;

    return Semantics(
      liveRegion: true,
      child: Card(
        color: color.withValues(alpha: 0.10),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color),
                  const SizedBox(width: 10),
                  Text(correct ? 'Верно!' : 'Неверно', style: theme.textTheme.titleLarge?.copyWith(color: color)),
                ],
              ),
              if (!correct) ...[
                const SizedBox(height: 12),
                Text('Правильный ответ: ${item.correctAnswer}', style: theme.textTheme.titleMedium),
              ],
              const SizedBox(height: 8),
              Text(item.explanation, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
