import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/data/models/expense_transaction.dart';

void main() {
  group('ExpenseTransaction', () {
    test('serializes the transaction fields for SQLite', () {
      final transaction = ExpenseTransaction(
        id: 7,
        title: 'Monthly salary',
        amount: 25000,
        category: 'Salary',
        type: 'income',
        date: DateTime(2026, 11, 1),
      );

      final map = transaction.toMap();

      expect(map['title'], 'Monthly salary');
      expect(map['amount'], 25000.0);
      expect(map['category'], 'Salary');
      expect(map['type'], 'income');
      expect(map['date'], DateTime(2026, 11, 1).toIso8601String());
      expect(map.containsKey('id'), isFalse);
    });

    test('restores a transaction from a SQLite row', () {
      final transaction = ExpenseTransaction.fromMap({
        'id': 12,
        'title': 'Lunch',
        'amount': 180.5,
        'category': 'Food & Dining',
        'type': 'expense',
        'date': '2026-11-03T12:30:00.000',
      });

      expect(transaction.id, 12);
      expect(transaction.title, 'Lunch');
      expect(transaction.amount, 180.5);
      expect(transaction.isIncome, isFalse);
      expect(transaction.date, DateTime(2026, 11, 3, 12, 30));
    });
  });
}
