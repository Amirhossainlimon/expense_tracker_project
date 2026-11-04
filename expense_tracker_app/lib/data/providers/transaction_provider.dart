import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/expense_transaction.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({DatabaseHelper? database}) : _database = database ?? DatabaseHelper.instance;

  final DatabaseHelper _database;
  List<ExpenseTransaction> _transactions = [];
  bool _isLoading = true;

  List<ExpenseTransaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _isLoading;

  double get totalIncome => _sum(_transactions.where((item) => item.isIncome));
  double get totalExpense => _sum(_transactions.where((item) => !item.isIncome));
  double get balance => totalIncome - totalExpense;

  List<ExpenseTransaction> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((item) => item.date.year == now.year && item.date.month == now.month).toList();
  }

  double get currentMonthIncome => _sum(currentMonthTransactions.where((item) => item.isIncome));
  double get currentMonthExpense => _sum(currentMonthTransactions.where((item) => !item.isIncome));

  double _sum(Iterable<ExpenseTransaction> items) {
    return items.fold<double>(0, (total, item) => total + item.amount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    try {
      _transactions = await _database.getTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(ExpenseTransaction transaction) async {
    await _database.insertTransaction(transaction);
    await _reload();
  }

  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    await _database.updateTransaction(transaction);
    await _reload();
  }

  Future<void> deleteTransaction(int id) async {
    await _database.deleteTransaction(id);
    await _reload();
  }

  ExpenseTransaction? findById(int? id) {
    if (id == null) return null;
    for (final item in _transactions) {
      if (item.id == id) return item;
    }
    return null;
  }

  double expenseForDay(DateTime day) {
    return _sum(_transactions.where((item) =>
        !item.isIncome &&
        item.date.year == day.year &&
        item.date.month == day.month &&
        item.date.day == day.day));
  }

  Map<String, double> currentMonthExpensesByCategory() {
    final totals = <String, double>{};
    for (final item in currentMonthTransactions.where((item) => !item.isIncome)) {
      totals.update(item.category, (value) => value + item.amount, ifAbsent: () => item.amount);
    }
    return totals;
  }

  Future<void> _reload() async {
    _transactions = await _database.getTransactions();
    notifyListeners();
  }
}
