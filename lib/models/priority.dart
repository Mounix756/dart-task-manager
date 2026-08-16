/// Niveau de priorité d'une [Task].
enum Priority {
  low,
  medium,
  high;

  /// Parse une priorité à partir de sa représentation textuelle (JSON/CLI).
  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (p) => p.name == value.toLowerCase().trim(),
      orElse: () => throw ArgumentError('Priorité inconnue : $value'),
    );
  }
}
