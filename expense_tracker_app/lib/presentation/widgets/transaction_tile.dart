import 'package:flutter/material.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/expense_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDelete,
  });

  final ExpenseTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final income = transaction.isIncome;
    final categoryColor = AppCategories.colorFor(transaction.category);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(color: categoryColor.withOpacity(.11), borderRadius: BorderRadius.circular(15)),
                child: Icon(AppCategories.iconFor(transaction.category), color: categoryColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    const SizedBox(height: 5),
                    Text('${transaction.category}  ·  ${formatDate(transaction.date)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: AppColors.muted, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${income ? '+' : '−'}${formatCurrency(transaction.amount)}',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: income ? AppColors.income : AppColors.expense),
                  ),
                  const SizedBox(height: 5),
                  Text(income ? 'Income' : 'Expense', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: income ? AppColors.income : AppColors.expense)),
                ],
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete transaction',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.muted, size: 19),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
