/// Contrat CRUD générique implémenté par les repositories concrets.
///
/// Déclarée comme une classe abstraite ne contenant que des membres
/// abstraits, elle agit comme une interface pure, implémentée
/// (et non étendue) par [TaskRepository].
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T> getById(int id);
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(int id);
}
