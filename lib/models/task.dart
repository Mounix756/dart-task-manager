import '../exceptions/task_exceptions.dart';
import 'normal_task.dart';
import 'priority.dart';
import 'urgent_task.dart';

/// Type de base pour toutes les tâches gérées par l'application.
///
/// [Task] est volontairement abstraite : une tâche est toujours soit une
/// [NormalTask], soit une [UrgentTask], jamais une [Task] "brute". Les
/// sous-classes décident de l'affichage et des règles supplémentaires
/// (comme l'obligation d'avoir une deadline).
abstract class Task {
  final int id;
  final String title;
  final Priority priority;
  final DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  }) {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('Le titre de la tâche ne peut pas être vide');
    }
  }

  /// Factory qui choisit la bonne sous-classe en fonction de [priority].
  ///
  /// Une tâche de priorité [Priority.high] est urgente par nature : elle
  /// est construite comme une [UrgentTask], qui impose une deadline.
  /// Toutes les autres tâches sont des [NormalTask].
  factory Task.create({
    required int id,
    required String title,
    required Priority priority,
    DateTime? deadline,
    bool isDone = false,
  }) {
    if (priority == Priority.high) {
      return UrgentTask(
        id: id,
        title: title,
        deadline: deadline,
        isDone: isDone,
      );
    }
    return NormalTask(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
      isDone: isDone,
    );
  }

  /// Reconstruit une tâche à partir de sa représentation JSON persistée.
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task.create(
      id: json['id'] as int,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      deadline: json['deadline'] == null
          ? null
          : DateTime.parse(json['deadline'] as String),
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  void markDone() {
    isDone = true;
  }

  /// Marqueur court distinguant le type de tâche dans les listings (ex. "⚠").
  String get statusLabel;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.name,
    'deadline': deadline?.toIso8601String().split('T').first,
    'isDone': isDone,
  };

  @override
  String toString() =>
      '#$id [$statusLabel] $title (${priority.name}'
      '${deadline != null ? ', due $deadline' : ''})';
}
