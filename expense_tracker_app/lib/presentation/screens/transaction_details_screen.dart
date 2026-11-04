import 'package:flutter/material.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/providers/transaction_provider.dart';
import '../widgets/delete_confirmation.dart';
import 'transaction_form_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.transaction, required this.provider});

  final ExpenseTransaction transaction;
  final TransactionProvider provider;

  Future<void> _edit(BuildContext context, ExpenseTransaction current) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TransactionFormScreen(provider: provider, transaction: current),
      ),
    );
  }

  Future<void> _delete(BuildContext context, ExpenseTransaction current) async {
    final confirmed = await confirmDeleteTransaction(context, current);
    if (!confirmed || !context.mounted || current.id == null) return;
    await provider.deleteTransaction(current.id!);
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final current = provider.findById(transaction.id) ?? transaction;
        final income = current.isIncome;
        final color = income ? AppColors.income : AppColors.expense;
        final softColor = income ? AppColors.incomeSoft : AppColors.expenseSoft;
        final categoryColor = AppCategories.colorFor(current.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction details'),
            leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_rounded)),
            actions: [
              IconButton(onPressed: () => _edit(context, current), tooltip: 'Edit transaction', icon: const Icon(Icons.edit_outlined, color: AppColors.primary)),
              const SizedBox(width: 6),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 23),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
                child: Column(
                  children: [
                    Container(width: 62, height: 62, decoration: BoxDecoration(color: categoryColor.withOpacity(.12), borderRadius: BorderRadius.circular(21)), child: Icon(AppCategories.iconFor(current.category), color: categoryColor, size: 27)),
                    const SizedBox(height: 14),
                    Text(current.title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('${income ? '+' : '−'}${formatCurrency(current.amount)}', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.6)),
                    const SizedBox(height: 11),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: softColor, borderRadius: BorderRadius.circular(20)),
                      child: Text(income ? 'INCOME' : 'EXPENSE', style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: Column(
                  children: [
                    _DetailRow(icon: Icons.category_outlined, label: 'Category', value: current.category, iconColor: categoryColor),
                    const Divider(height: 25),
                    _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: formatDate(current.date)),
                    const Divider(height: 25),
                    _DetailRow(icon: Icons.swap_horiz_rounded, label: 'Transaction type', value: income ? 'Income' : 'Expense', valueColor: color),
                    const Divider(height: 25),
                    _DetailRow(icon: Icons.numbers_rounded, label: 'Reference ID', value: '#${current.id ?? '—'}'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => _edit(context, current),
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit transaction'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _delete(context, current),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Delete transaction'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  foregroundColor: AppColors.expense,
                  side: const BorderSide(color: Color(0xFFF3C9CE)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label, required this.value, this.iconColor, this.valueColor});

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(11)), child: Icon(icon, size: 16, color: iconColor ?? AppColors.muted)),
        const SizedBox(width: 11),
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w600))),
        Text(value, textAlign: TextAlign.right, style: TextStyle(color: valueColor ?? AppColors.ink, fontSize: 11.5, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
