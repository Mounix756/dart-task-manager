import 'task.dart';

/// Une tâche classique (priorité low ou medium). Sa deadline est optionnelle.
class NormalTask extends Task {
  NormalTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone,
  });

  @override
  String get statusLabel => isDone ? '✅' : '⬜';
}
