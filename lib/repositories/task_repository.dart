import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import '../storage/json_storage.dart';
import 'repository.dart';

/// Implémentation concrète de [Repository] pour [Task], adossée à un
/// fichier via [JsonStorage].
///
/// Les tâches sont mises en cache en mémoire après la première lecture et
/// la liste entière est réécrite sur disque à chaque mutation, ce qui est
/// simple et largement suffisant pour un fichier de tâches local.
class TaskRepository implements Repository<Task> {
  final JsonStorage _storage;
  List<Task>? _cache;

  TaskRepository({JsonStorage? storage}) : _storage = storage ?? JsonStorage();

  Future<List<Task>> _load() async {
    return _cache ??= await _storage.readTasks();
  }

  Future<int> nextId() async {
    final tasks = await _load();
    if (tasks.isEmpty) return 1;
    return tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<List<Task>> getAll() async => List.unmodifiable(await _load());

  @override
  Future<Task> getById(int id) async {
    final tasks = await _load();
    for (final task in tasks) {
      if (task.id == id) return task;
    }
    throw TaskNotFoundException('Aucune tâche avec l\'id $id');
  }

  @override
  Future<void> add(Task item) async {
    final tasks = await _load();
    tasks.add(item);
    await _storage.writeTasks(tasks);
  }

  @override
  Future<void> update(Task item) async {
    final tasks = await _load();
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskNotFoundException('Aucune tâche avec l\'id ${item.id}');
    }
    tasks[index] = item;
    await _storage.writeTasks(tasks);
  }

  @override
  Future<void> delete(int id) async {
    final tasks = await _load();
    final removed = tasks.any((t) => t.id == id);
    if (!removed) {
      throw TaskNotFoundException('Aucune tâche avec l\'id $id');
    }
    tasks.removeWhere((t) => t.id == id);
    await _storage.writeTasks(tasks);
  }
}
