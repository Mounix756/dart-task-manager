/// Levée quand une tâche avec un id donné est introuvable dans le repository.
class TaskNotFoundException implements Exception {
  final String message;

  TaskNotFoundException(this.message);

  @override
  String toString() => 'TaskNotFoundException: $message';
}

/// Levée quand une tâche est construite ou mise à jour avec des données
/// invalides (ex. titre vide, ou [UrgentTask] sans sa deadline obligatoire).
class InvalidTaskException implements Exception {
  final String message;

  InvalidTaskException(this.message);

  @override
  String toString() => 'InvalidTaskException: $message';
}

/// Levée quand la lecture ou l'écriture du fichier de stockage JSON échoue.
class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}
