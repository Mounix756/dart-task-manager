import '../exceptions/task_exceptions.dart';
import 'priority.dart';
import 'task.dart';

/// Une tâche de priorité haute. Les tâches urgentes exigent toujours une
/// deadline afin que l'application puisse prévenir l'utilisateur quand
/// celle-ci approche ou est dépassée.
class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    required DateTime? deadline,
    super.isDone,
  }) : super(priority: Priority.high, deadline: deadline) {
    if (deadline == null) {
      throw InvalidTaskException('Une tâche urgente nécessite une deadline');
    }
  }

  /// True si la deadline est déjà passée et que la tâche n'est pas terminée.
  bool get isOverdue =>
      !isDone && deadline != null && deadline!.isBefore(DateTime.now());

  @override
  String get statusLabel {
    if (isDone) return '✅';
    return isOverdue ? '⚠' : '⬜';
  }
}
