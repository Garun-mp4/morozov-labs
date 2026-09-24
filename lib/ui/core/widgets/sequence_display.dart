import 'package:flutter/material.dart';

class SequenceDisplay extends StatelessWidget {
  const SequenceDisplay({required this.values, super.key});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = <String>[...values.map((value) => '$value'), '?'];

    return Semantics(
      label: 'Последовательность: ${values.join(', ')}, неизвестное число',
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: tokens.map((token) {
          final isQuestion = token == '?';
          return Container(
            constraints: const BoxConstraints(minWidth: 58, minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isQuestion
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              token,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isQuestion ? theme.colorScheme.onPrimaryContainer : null,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
