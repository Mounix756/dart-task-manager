import 'dart:io';

import 'package:dart_task_manager/exceptions/task_exceptions.dart';
import 'package:dart_task_manager/models/priority.dart';
import 'package:dart_task_manager/models/task.dart';
import 'package:dart_task_manager/repositories/task_repository.dart';
import 'package:dart_task_manager/storage/json_storage.dart';
import 'package:test/test.dart';

void main() {
  late String tempPath;
  late TaskRepository repository;

  setUp(() {
    tempPath = 'test/.tmp_repo_${DateTime.now().microsecondsSinceEpoch}.json';
    repository = TaskRepository(storage: JsonStorage(filePath: tempPath));
  });

  tearDown(() async {
    final file = File(tempPath);
    if (await file.exists()) await file.delete();
  });

  test('doit ajouter une tâche et la retrouver par son id', () async {
    final task = Task.create(id: 1, title: 'Écrire les tests', priority: Priority.medium);
    await repository.add(task);

    final fetched = await repository.getById(1);

    expect(fetched.title, 'Écrire les tests');
  });

  test('doit lever TaskNotFoundException pour un id inconnu', () async {
    expect(
      () => repository.getById(42),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('doit supprimer une tâche', () async {
    final task = Task.create(id: 1, title: 'Tâche temporaire', priority: Priority.low);
    await repository.add(task);

    await repository.delete(1);

    expect(await repository.getAll(), isEmpty);
  });

  test('doit persister les tâches sur disque et les recharger dans un nouveau repository', () async {
    final task = Task.create(id: 1, title: 'Tâche persistée', priority: Priority.low);
    await repository.add(task);

    final reloaded = TaskRepository(storage: JsonStorage(filePath: tempPath));
    final tasks = await reloaded.getAll();

    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Tâche persistée');
  });
}
