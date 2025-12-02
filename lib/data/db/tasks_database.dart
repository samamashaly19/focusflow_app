// lib/data/db/tasks_database.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class TasksDatabase {
  static final TasksDatabase instance = TasksDatabase._init();
  static Database? _database;
  TasksDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      isCompleted INTEGER NOT NULL
    )
    ''');
  }

  Future<TaskModel> createTask(TaskModel task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    task.id = id;
    return task;
  }

  Future<List<TaskModel>> readAllTasks() async {
    final db = await instance.database;
    final orderBy = 'date ASC, time ASC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<int> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw Exception('Cannot update task without an id');
    }
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
