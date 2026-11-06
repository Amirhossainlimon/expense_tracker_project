
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import '../models/expense_transaction.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _databaseName = 'expense_tracker.db';
  static const String tableName = 'transactions';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    late String databasePath;

    if (kIsWeb) {
      // Use browser-compatible SQLite on Web
      databaseFactory = databaseFactoryFfiWeb;
      databasePath = _databaseName;
    } else {
      // Keep existing SQLite implementation on Android/iOS
      final databasesPath = await getDatabasesPath();
      databasePath = path.join(databasesPath, _databaseName);
    }

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL CHECK (amount > 0),
            category TEXT NOT NULL,
            type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
            date TEXT NOT NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_transactions_date ON $tableName(date)',
        );

        await db.execute(
          'CREATE INDEX idx_transactions_type ON $tableName(type)',
        );
      },
    );

    return _database!;
  }

  Future<List<ExpenseTransaction>> getTransactions() async {
    final db = await database;

    final rows = await db.query(
      tableName,
      orderBy: 'date DESC, id DESC',
    );

    return rows.map(ExpenseTransaction.fromMap).toList();
  }

  Future<int> insertTransaction(ExpenseTransaction transaction) async {
    final db = await database;

    return db.insert(
      tableName,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> updateTransaction(ExpenseTransaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('A transaction ID is required for an update.');
    }

    final db = await database;

    return db.update(
      tableName,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;

    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
