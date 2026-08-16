import 'dart:io';

import 'package:dart_task_manager/exceptions/task_exceptions.dart';
import 'package:dart_task_manager/models/priority.dart';
import 'package:dart_task_manager/models/urgent_task.dart';
import 'package:dart_task_manager/repositories/task_repository.dart';
import 'package:dart_task_manager/services/task_service.dart';

Future<void> main() async {
  final service = TaskService(TaskRepository());
  var running = true;

  while (running) {
    _printMenu();
    final choice = stdin.readLineSync()?.trim();

    try {
      switch (choice) {
        case '1':
          await _addTask(service);
        case '2':
          await _listTasks(service);
        case '3':
          await _completeTask(service);
        case '4':
          await _deleteTask(service);
        case '5':
          running = false;
          print('Au revoir !');
        default:
          print('Choix invalide.\n');
      }
    } on InvalidTaskException catch (e) {
      print('Erreur : ${e.message}\n');
    } on TaskNotFoundException catch (e) {
      print('Erreur : ${e.message}\n');
    } on StorageException catch (e) {
      print('Erreur de stockage : ${e.message}\n');
    }
  }
}

void _printMenu() {
  print('=== TASK MANAGER ===\n');
  print('1. Ajouter une tâche');
  print('2. Lister les tâches');
  print('3. Marquer une tâche comme terminée');
  print('4. Supprimer une tâche');
  print('5. Quitter');
  stdout.write('\nVotre choix : ');
}

Future<void> _addTask(TaskService service) async {
  stdout.write('Titre : ');
  final title = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Priorité (low/medium/high) : ');
  final priorityInput = stdin.readLineSync()?.trim() ?? '';
  final priority = Priority.fromString(priorityInput);

  stdout.write('Deadline (yyyy-mm-dd, laisser vide si aucune) : ');
  final deadlineInput = stdin.readLineSync()?.trim() ?? '';
  final deadline = deadlineInput.isEmpty ? null : DateTime.parse(deadlineInput);

  final task = await service.addTask(
    title: title,
    priority: priority,
    deadline: deadline,
  );
  print('\n✓ Tâche "${task.title}" ajoutée (#${task.id}).\n');
}

Future<void> _listTasks(TaskService service) async {
  stdout.write('Trier par (priority/date) [priority] : ');
  final sortInput = stdin.readLineSync()?.trim().toLowerCase() ?? '';
  final sortBy = sortInput == 'date' ? SortBy.date : SortBy.priority;

  final tasks = await service.listTasks(sortBy: sortBy);
  print('');
  if (tasks.isEmpty) {
    print('Aucune tâche pour le moment.\n');
    return;
  }

  print(
    '${'ID'.padRight(4)}${'Titre'.padRight(25)}${'Priorité'.padRight(11)}'
    '${'Deadline'.padRight(13)}Statut',
  );
  for (final task in tasks) {
    final deadlineLabel = task.deadline == null
        ? '--'
        : _formatDate(task.deadline!);
    final marker = task is UrgentTask && task.isOverdue ? ' ${task.statusLabel}' : '';
    print(
      '${task.id.toString().padRight(4)}${task.title.padRight(25)}'
      '${task.priority.name.toUpperCase().padRight(11)}'
      '${deadlineLabel.padRight(13)}${task.isDone ? "✅" : "⬜"}$marker',
    );
  }
  print('');
}

Future<void> _completeTask(TaskService service) async {
  stdout.write('Choisir l\'ID : ');
  final id = int.parse(stdin.readLineSync()?.trim() ?? '');
  final task = await service.completeTask(id);
  print('\n✓ Tâche "${task.title}" terminée.\n');
}

Future<void> _deleteTask(TaskService service) async {
  stdout.write('Choisir l\'ID : ');
  final id = int.parse(stdin.readLineSync()?.trim() ?? '');
  await service.deleteTask(id);
  print('\n✓ Tâche supprimée.\n');
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
