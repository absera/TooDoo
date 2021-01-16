import 'package:path/path.dart' show join;
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseName = "toodoo.db";
  static final _databaseVersion = 1;

  static final table = 'toodoo';

  static final columnId = '_id';
  static final columnTitle = 'title';
  static final columnBody = 'body';
  static final columnCompleted = 'completed';
  static final columnUrgency = 'urgency';
  static final columnImportance = 'importance';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    var db_path = await getDatabasesPath();
    String path = join(db_path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnTitle TEXT NOT NULL,
            $columnBody TEXT NOT NULL,
            $columnCompleted INTEGER NOT NULL,
            $columnUrgency INTEGER NOT NULL,
            $columnImportance INTEGER NOT NULL
          )
          ''');
  }
}
