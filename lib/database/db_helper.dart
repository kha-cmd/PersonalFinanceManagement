import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/income.dart';
import '../models/fixed_expense.dart';
import '../models/daily_spend.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'expense_manager.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  // ---------------- CREATE TABLES ----------------
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE income (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_income REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE fixed_expense (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        status TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_spending (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // ------------- UPGRADE DATABASE IF OLD VERSION ----------
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute("ALTER TABLE fixed_expense ADD COLUMN date TEXT NOT NULL DEFAULT ''");
    }
  }

  // =======================================================
  //                     INCOME METHODS
  // =======================================================
  Future<int> insertIncome(Income income) async {
    final dbClient = await db;
    return await dbClient.insert('income', income.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Income>> getAllIncome() async {
    final dbClient = await db;
    final res = await dbClient.query('income', orderBy: 'date DESC');
    return res.map((r) => Income.fromMap(r)).toList();
  }

  Future<double> getLatestIncome() async {
    final dbClient = await db;
    final res = await dbClient.rawQuery(
        'SELECT total_income FROM income ORDER BY id DESC LIMIT 1');

    if (res.isNotEmpty && res.first['total_income'] != null) {
      return (res.first['total_income'] as num).toDouble();
    }
    return 0.0;
  }

  // =======================================================
  //                 FIXED EXPENSE METHODS
  // =======================================================
  Future<int> insertFixedExpense(FixedExpense fe) async {
    final dbClient = await db;
    return await dbClient.insert('fixed_expense', fe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateFixedExpense(FixedExpense fe) async {
    final dbClient = await db;
    return await dbClient.update(
      'fixed_expense',
      fe.toMap(),
      where: 'id = ?',
      whereArgs: [fe.id],
    );
  }

  Future<int> deleteFixedExpense(int id) async {
    final dbClient = await db;
    return await dbClient.delete('fixed_expense', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<FixedExpense>> getAllFixedExpenses() async {
    final dbClient = await db;
    final res = await dbClient.query('fixed_expense', orderBy: 'id DESC');
    return res.map((r) => FixedExpense.fromMap(r)).toList();
  }

  Future<double> totalFixedExpenses() async {
    final dbClient = await db;
    final res = await dbClient
        .rawQuery('SELECT SUM(amount) as total FROM fixed_expense');

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // =======================================================
  //                DAILY SPENDING METHODS
  // =======================================================
  Future<int> insertDailySpend(DailySpend ds) async {
    final dbClient = await db;
    return await dbClient.insert('daily_spending', ds.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDailySpend(DailySpend ds) async {
    final dbClient = await db;
    return await dbClient.update(
      'daily_spending',
      ds.toMap(),
      where: 'id = ?',
      whereArgs: [ds.id],
    );
  }

  Future<int> deleteDailySpend(int id) async {
    final dbClient = await db;
    return await dbClient.delete('daily_spending', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<DailySpend>> getAllDailySpends() async {
    final dbClient = await db;
    final res = await dbClient.query('daily_spending', orderBy: 'date DESC');
    return res.map((r) => DailySpend.fromMap(r)).toList();
  }

  Future<double> totalDailySpendingByCategory(String category) async {
    final dbClient = await db;
    final res = await dbClient.rawQuery(
        'SELECT SUM(amount) as total FROM daily_spending WHERE category = ?',
        [category]);

    if (res.isNotEmpty && res.first['total'] != null) {
      return (res.first['total'] as num).toDouble();
    }
    return 0.0;
  }
}
