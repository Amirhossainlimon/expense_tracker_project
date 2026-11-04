import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/expense_transaction.dart';

Future<bool> confirmDeleteTransaction(BuildContext context, ExpenseTransaction transaction) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(color: AppColors.expenseSoft, borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.expense, size: 25),
      ),
      title: const Text('Delete transaction?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800)),
      content: Text(
        '“${transaction.title}” will be permanently removed from your records.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.muted, height: 1.45),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.expense),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}
