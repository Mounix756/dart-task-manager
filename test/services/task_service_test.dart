import 'dart:io';

import 'package:dart_task_manager/exceptions/task_exceptions.dart';
import 'package:dart_task_manager/models/priority.dart';
import 'package:dart_task_manager/repositories/task_repository.dart';
import 'package:dart_task_manager/services/task_service.dart';
import 'package:dart_task_manager/storage/json_storage.dart';
import 'package:test/test.dart';

void main() {
  late String tempPath;
  late TaskService service;

  setUp(() {
    tempPath = 'test/.tmp_service_${DateTime.now().microsecondsSinceEpoch}.json';
    service = TaskService(TaskRepository(storage: JsonStorage(filePath: tempPath)));
  });

  tearDown(() async {
    final file = File(tempPath);
    if (await file.exists()) await file.delete();
  });

  test('doit marquer une tâche comme terminée', () async {
    final task = await service.addTask(title: 'Faire la lessive', priority: Priority.low);

    final completed = await service.completeTask(task.id);

    expect(completed.isDone, isTrue);
  });

  test('doit lever TaskNotFoundException en terminant une tâche inconnue', () async {
    expect(
      () => service.completeTask(999),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('doit supprimer une tâche', () async {
    final task = await service.addTask(title: 'Ancienne tâche', priority: Priority.low);

    await service.deleteTask(task.id);

    expect(await service.listTasks(), isEmpty);
  });

  test('doit trier les tâches par priorité, la plus haute en premier', () async {
    await service.addTask(title: 'Basse', priority: Priority.low);
    await service.addTask(
      title: 'Haute',
      priority: Priority.high,
      deadline: DateTime(2026, 8, 20),
    );
    await service.addTask(title: 'Moyenne', priority: Priority.medium);

    final tasks = await service.listTasks(sortBy: SortBy.priority);

    expect(tasks.map((t) => t.title), ['Haute', 'Moyenne', 'Basse']);
  });

  test('doit trier les tâches par date, deadline la plus proche en premier et sans deadline en dernier', () async {
    await service.addTask(
      title: 'Plus tard',
      priority: Priority.medium,
      deadline: DateTime(2026, 9, 1),
    );
    await service.addTask(title: 'Sans deadline', priority: Priority.low);
    await service.addTask(
      title: 'Plus tôt',
      priority: Priority.high,
      deadline: DateTime(2026, 8, 20),
    );

    final tasks = await service.listTasks(sortBy: SortBy.date);

    expect(tasks.map((t) => t.title), ['Plus tôt', 'Plus tard', 'Sans deadline']);
  });
}
