import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';

/// Critères de tri supportés par [TaskService.listTasks].
enum SortBy { priority, date }

/// Logique métier de gestion des tâches, entre le CLI et le
/// [TaskRepository] (un [Repository]&lt;Task&gt;).
class TaskService {
  final TaskRepository _repository;

  TaskService(this._repository);

  Future<Task> addTask({
    required String title,
    required Priority priority,
    DateTime? deadline,
  }) async {
    final id = await _repository.nextId();
    final task = Task.create(
      id: id,
      title: title,
      priority: priority,
      deadline: deadline,
    );
    await _repository.add(task);
    return task;
  }

  Future<List<Task>> listTasks({SortBy sortBy = SortBy.priority}) async {
    final tasks = await _repository.getAll();
    final sorted = [...tasks];

    switch (sortBy) {
      case SortBy.priority:
        sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case SortBy.date:
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
    }
    return sorted;
  }

  Future<Task> completeTask(int id) async {
    final task = await _repository.getById(id);
    if (task.isDone) {
      throw InvalidTaskException('La tâche $id est déjà terminée');
    }
    task.markDone();
    await _repository.update(task);
    return task;
  }

  Future<void> deleteTask(int id) async {
    await _repository.delete(id);
  }
}
