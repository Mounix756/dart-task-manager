# Dart Task Manager

Application de gestion de tâches en ligne de commande, écrite en Dart pur (sans Flutter).

> Projet réalisé et présenté dans le cadre du **FlutterFire Summer Camp 2026**.

## Fonctionnalités

- Ajouter une tâche avec un titre, une priorité (`low` / `medium` / `high`) et une deadline optionnelle
- Lister toutes les tâches, triées par priorité ou par deadline
- Marquer une tâche comme terminée
- Supprimer une tâche
- Persistance des données dans un fichier JSON local (`data/tasks.json`) : les tâches survivent entre deux exécutions

## Installation

```bash
git clone <git@github.com:Mounix756/dart-task-manager.git>
cd dart-task-manager
dart pub get
```

## Lancer l'application

```bash
dart run bin/task_manager.dart
```

Un menu interactif s'affiche :

```
=== TASK MANAGER ===

1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter

Votre choix :
```

Exemple de listing :

```
ID  Titre                    Priorité   Deadline     Statut
1   Préparer présentation    HIGH       20/08/2026   ⬜
2   Acheter du lait          LOW        --           ✅
```

## Lancer les tests

```bash
dart test
```

La suite compte 16 tests couvrant les modèles, le repository et la couche service
(`test/models`, `test/repositories`, `test/services`).

## Architecture

```
lib/
├── models/
│   ├── priority.dart      # enum Priority (low/medium/high)
│   ├── task.dart          # abstract class Task + factories Task.create/fromJson
│   ├── normal_task.dart   # NormalTask extends Task
│   └── urgent_task.dart   # UrgentTask extends Task (deadline obligatoire)
├── repositories/
│   ├── repository.dart      # abstract class Repository<T> (interface)
│   └── task_repository.dart # TaskRepository implements Repository<Task>
├── services/
│   └── task_service.dart  # logique métier : add/list/complete/delete, tri
├── storage/
│   └── json_storage.dart  # lecture/écriture de data/tasks.json
└── exceptions/
    └── task_exceptions.dart # TaskNotFoundException, InvalidTaskException, StorageException

bin/
└── task_manager.dart      # point d'entrée CLI (boucle de menu, stdin/stdout)

test/
├── models/task_test.dart
├── repositories/task_repository_test.dart
└── services/task_service_test.dart
```

### Pourquoi une `Task` abstraite avec `NormalTask`/`UrgentTask`

Dans cette application, une tâche de priorité haute est toujours urgente : elle
doit obligatoirement avoir une deadline pour que l'outil puisse la signaler comme
en retard (`⚠`). `Task` est abstraite et expose une factory `Task.create(...)` qui
retourne une `UrgentTask` quand `priority == high`, et une `NormalTask` sinon. Le
constructeur d'`UrgentTask` lève une `InvalidTaskException` si aucune deadline
n'est fournie, et il redéfinit `statusLabel` pour afficher un marqueur d'alerte en
cas de retard. Cela permet d'imposer la règle métier ("une tâche urgente a besoin
d'une deadline") directement via le typage, plutôt que par des `if` éparpillés
dans le CLI.

### Interface `Repository<T>` et generics

`Repository<T>` est une classe abstraite générique déclarant `getAll`, `getById`,
`add`, `update` et `delete`. `TaskRepository implements Repository<Task>`, et
s'appuie sur `JsonStorage`. Passer par une interface découple ici le contrat
CRUD de l'implémentation JSON spécifique : un autre `Repository<Task>` (par
exemple adossé à une base de données) pourrait la remplacer sans toucher à
`TaskService`.

### Gestion des erreurs

Trois exceptions personnalisées couvrent les cas d'échec de l'application :

- `TaskNotFoundException` — récupération/complétion/suppression d'un id de tâche
  qui n'existe pas
- `InvalidTaskException` — données de tâche invalides (titre vide, tâche urgente
  sans deadline, tâche déjà terminée qu'on essaie de re-terminer)
- `StorageException` — le fichier JSON est illisible/corrompu ou impossible à
  écrire

Le CLI intercepte ces trois exceptions au niveau supérieur et affiche un message
clair au lieu de planter.

## Format JSON

`data/tasks.json` (créé automatiquement à la première sauvegarde) :

```json
[
  {
    "id": 1,
    "title": "Préparer présentation",
    "priority": "high",
    "deadline": "2026-08-20",
    "isDone": false
  }
]
```

## Choix techniques

- Aucune dépendance externe hormis `test` et `lints` (dev dependencies) : tout le
  reste repose sur `dart:io` / `dart:convert`.
- Le repository met les tâches en cache en mémoire après la première lecture et
  réécrit tout le fichier JSON à chaque mutation. C'est simple et largement
  suffisant pour une liste de tâches locale ; une vraie base de données ferait
  des écritures incrémentales.
- Les dates sont stockées au format ISO `yyyy-mm-dd` dans le JSON et affichées
  au format `dd/mm/yyyy` dans le CLI.
