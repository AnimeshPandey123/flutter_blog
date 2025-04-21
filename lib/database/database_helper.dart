import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
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

    // await db.execute('''
    //   CREATE TABLE uploads (
    //     id INTEGER PRIMARY KEY AUTOINCREMENT,
    //     blog_id INTEGER NOT NULL,
    //     status TEXT NOT NULL CHECK(status IN ('pending', 'uploading','uploaded', 'failed')),,
    //     FOREIGN KEY(blog_id) REFERENCES blogs(id) ON DELETE CASCADE,
    //     uploaded_at TEXT NULL,
    //     created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    //     updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    //   )
    // ''');

    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE blog_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        blog_id INTEGER NOT NULL,
        tag_id INTEGER NOT NULL,
        FOREIGN KEY(blog_id) REFERENCES blogs(id) ON DELETE CASCADE,
        FOREIGN KEY(tag_id) REFERENCES tags(id) ON DELETE CASCADE
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
