import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

class ExpenseLocalDataSource {
  static Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nafqa.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE expenses(
            id INTEGER PRIMARY KEY,
            user_id TEXT,
            amount REAL,
            category TEXT,
            date TEXT,
            note TEXT,
            is_synced INTEGER NOT NULL DEFAULT 1
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE expenses ADD COLUMN is_synced INTEGER NOT NULL DEFAULT 1',
          );
        }
      },
    );
  }

  Future<List<Expense>> getExpenses(String userId) async {
    final db = await _db;
    final maps = await db.query(
      'expenses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<List<Expense>> getUnsyncedExpenses() async {
    final db = await _db;
    final maps = await db.query(
      'expenses',
      where: 'is_synced = ?',
      whereArgs: [0],
    );
    return maps.map((map) => Expense.fromJson(map)).toList();
  }

  Future<void> cacheExpenses(List<Expense> expenses) async {
    final db = await _db;
    final batch = db.batch();
    for (final expense in expenses) {
      batch.insert(
        'expenses',
        expense.toLocalJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// بعد ما مصروف offline ينجح يترفع، بنشيل النسخة المؤقتة ونحط الحقيقية
  Future<void> replaceLocalId(int oldId, Expense syncedExpense) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [oldId]);
    await db.insert(
      'expenses',
      syncedExpense.toLocalJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpense(int id) async {
    final db = await _db;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('expenses');
  }
}
