import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';

/// Lit et écrit la liste des tâches dans un fichier JSON local.
class JsonStorage {
  final String filePath;

  JsonStorage({this.filePath = 'data/tasks.json'});

  Future<List<Task>> readTasks() async {
    final file = File(filePath);
    if (!await file.exists()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];

      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw StorageException('Fichier de tâches corrompu ($filePath) : ${e.message}');
    } on IOException catch (e) {
      throw StorageException('Échec de lecture de $filePath : $e');
    }
  }

  Future<void> writeTasks(List<Task> tasks) async {
    try {
      final file = File(filePath);
      await file.parent.create(recursive: true);
      final jsonList = tasks.map((task) => task.toJson()).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(jsonList));
    } on IOException catch (e) {
      throw StorageException('Échec d\'écriture de $filePath : $e');
    }
  }
}
