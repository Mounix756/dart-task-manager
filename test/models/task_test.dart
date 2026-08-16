import 'package:dart_task_manager/exceptions/task_exceptions.dart';
import 'package:dart_task_manager/models/normal_task.dart';
import 'package:dart_task_manager/models/priority.dart';
import 'package:dart_task_manager/models/task.dart';
import 'package:dart_task_manager/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('Task.create', () {
    test('doit créer une NormalTask pour une priorité low/medium', () {
      final task = Task.create(id: 1, title: 'Acheter du lait', priority: Priority.low);

      expect(task, isA<NormalTask>());
      expect(task.title, 'Acheter du lait');
      expect(task.isDone, isFalse);
    });

    test('doit créer une UrgentTask pour une priorité high', () {
      final task = Task.create(
        id: 2,
        title: 'Livrer la release',
        priority: Priority.high,
        deadline: DateTime(2026, 8, 20),
      );

      expect(task, isA<UrgentTask>());
      expect(task.priority, Priority.high);
    });

    test('doit lever InvalidTaskException quand le titre est vide', () {
      expect(
        () => Task.create(id: 1, title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('doit lever InvalidTaskException quand une tâche urgente n\'a pas de deadline', () {
      expect(
        () => Task.create(id: 1, title: 'Livrer la release', priority: Priority.high),
        throwsA(isA<InvalidTaskException>()),
      );
    });
  });

  group('Sérialisation JSON', () {
    test('doit reconstruire une tâche identique via toJson/fromJson', () {
      final original = Task.create(
        id: 5,
        title: 'Préparer présentation',
        priority: Priority.high,
        deadline: DateTime(2026, 8, 20),
      );

      final rebuilt = Task.fromJson(original.toJson());

      expect(rebuilt, isA<UrgentTask>());
      expect(rebuilt.id, original.id);
      expect(rebuilt.title, original.title);
      expect(rebuilt.priority, original.priority);
      expect(rebuilt.deadline, original.deadline);
    });
  });

  group('UrgentTask.isOverdue', () {
    test('doit être vrai quand la deadline est passée et la tâche non terminée', () {
      final task = UrgentTask(
        id: 1,
        title: 'Tâche en retard',
        deadline: DateTime(2000, 1, 1),
      );

      expect(task.isOverdue, isTrue);
    });

    test('doit être faux une fois la tâche marquée comme terminée', () {
      final task = UrgentTask(
        id: 1,
        title: 'Tâche en retard',
        deadline: DateTime(2000, 1, 1),
      );

      task.markDone();

      expect(task.isOverdue, isFalse);
    });
  });
}
