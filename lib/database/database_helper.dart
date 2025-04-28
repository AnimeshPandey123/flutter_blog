import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper instance = DatabaseHelper._init();
  
  // Add this method to allow setting the instance in tests
  static void setInstance(DatabaseHelper mockHelper) {
    instance = mockHelper;
  }
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('blogs.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        image_path TEXT NULL,
        summary TEXT NULL,
        is_featured INTEGER DEFAULT 0
      )
    ''');

  }

  Future<void> deleteDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'blogs.db'); // same name used in _initDB
    await deleteDatabase(path);
    _database = null; // reset cached db
    print('Database deleted');
  }
}
