import '../enums/sequence_type.dart';

class SequenceTask {
  const SequenceTask({
    required this.values,
    required this.answer,
    required this.type,
    required this.explanation,
  });

  final List<int> values;
  final int answer;
  final SequenceType type;
  final String explanation;

  String get signature => '${type.name}:${values.join(',')}:$answer';
}
