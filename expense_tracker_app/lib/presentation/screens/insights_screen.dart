
import 'package:flutter/material.dart';

import '../../core/constants/app_categories.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers/transaction_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_heading.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.provider});

  final TransactionProvider provider;

  @override
  Widget build(BuildContext context) {
    final categoryTotals =
    provider.currentMonthExpensesByCategory().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final highestCategory =
    categoryTotals.isEmpty ? 0.0 : categoryTotals.first.value;

    final weekDays = List<DateTime>.generate(7, (index) {
      final today = DateTime.now();
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - index));
    });

    final weekValues = weekDays.map(provider.expenseForDay).toList();

    final maxDay = weekValues.fold<double>(
      0,
          (max, value) => value > max ? value : max,
    );

    final thisMonthHasEntries =
        provider.currentMonthTransactions.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final horizontalPadding = screenWidth >= 1000
            ? 32.0
            : screenWidth >= 600
            ? 28.0
            : 16.0;

        final contentWidth = screenWidth >= 1100 ? 850.0 : 850.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                112,
              ),
              children: [
                const Text(
                  'Your money story',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatMonthYear(DateTime.now()),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                _MonthOverviewCard(
                  income: provider.currentMonthIncome,
                  expense: provider.currentMonthExpense,
                ),

                const SizedBox(height: 24),

                const SectionHeading(title: 'Spending this week'),
                const SizedBox(height: 13),

                _WeeklySpendingCard(
                  weekDays: weekDays,
                  weekValues: weekValues,
                  maxDay: maxDay,
                ),

                const SizedBox(height: 24),

                const SectionHeading(title: 'Expense by category'),
                const SizedBox(height: 12),

                if (!thisMonthHasEntries)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const EmptyState(
                      title: 'Insights are on the way',
                      message:
                      'Add a few transactions this month and your spending breakdown will appear here.',
                      icon: Icons.insights_rounded,
                    ),
                  )
                else if (categoryTotals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'No expenses recorded this month yet.',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  _CategoryBreakdownCard(
                    categoryTotals: categoryTotals,
                    totalExpense: provider.currentMonthExpense,
                    screenWidth: screenWidth,
                  ),

                const SizedBox(height: 8),

                if (highestCategory > 0)
                  Text(
                    'Top category this month: ${categoryTotals.first.key}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WeeklySpendingCard extends StatelessWidget {
  const _WeeklySpendingCard({
    required this.weekDays,
    required this.weekValues,
    required this.maxDay,
  });

  final List<DateTime> weekDays;
  final List<double> weekValues;
  final double maxDay;

  @override
  Widget build(BuildContext context) {
    final total = weekValues.fold<double>(
      0,
          (sum, value) => sum + value,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatCurrency(total),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total expenses over the last 7 days',
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final chartHeight = constraints.maxWidth < 280
                  ? 112.0
                  : 132.0;

              final barWidth = constraints.maxWidth < 300
                  ? 12.0
                  : constraints.maxWidth < 450
                  ? 16.0
                  : 22.0;

              return SizedBox(
                height: chartHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(weekDays.length, (index) {
                    final value = weekValues[index];

                    final fraction = maxDay == 0
                        ? 0.0
                        : value / maxDay;

                    final barHeight =
                    value == 0 ? 5.0 : 12 + (fraction * 62);

                    final isToday = index == 6;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 18,
                              width: double.infinity,
                              child: value > 0
                                  ? FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatCompactCurrency(value),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                                  : null,
                            ),

                            const SizedBox(height: 3),

                            Container(
                              height: barHeight,
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(
                                  .19 + (fraction * .38),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            const SizedBox(height: 7),

                            SizedBox(
                              height: 16,
                              width: double.infinity,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  formatWeekday(weekDays[index]),
                                  style: TextStyle(
                                    color: isToday
                                        ? AppColors.primary
                                        : AppColors.muted,
                                    fontSize: 9.5,
                                    fontWeight: isToday
                                        ? FontWeight.w900
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonthOverviewCard extends StatelessWidget {
  const _MonthOverviewCard({
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final total = income + expense;

    final incomeFlex = total == 0
        ? 1
        : ((income / total) * 1000).round().clamp(1, 1000);

    final expenseFlex = total == 0
        ? 1
        : ((expense / total) * 1000).round().clamp(1, 1000);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This month at a glance',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _MonthValue(
                  label: 'Income',
                  value: income,
                  color: AppColors.income,
                  icon: Icons.south_west_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 46,
                color: AppColors.line,
              ),
              Expanded(
                child: _MonthValue(
                  label: 'Expenses',
                  value: expense,
                  color: AppColors.expense,
                  icon: Icons.north_east_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  flex: incomeFlex,
                  child: Container(
                    height: 7,
                    color: AppColors.income,
                  ),
                ),
                Expanded(
                  flex: expenseFlex,
                  child: Container(
                    height: 7,
                    color: AppColors.expense,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 9),

          Text(
            total == 0
                ? 'Add transactions to compare your monthly cash flow.'
                : 'Net this month: ${formatCurrency(income - expense)}',
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthValue extends StatelessWidget {
  const _MonthValue({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatCurrency(value),
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({
    required this.categoryTotals,
    required this.totalExpense,
    required this.screenWidth,
  });

  final List<MapEntry<String, double>> categoryTotals;
  final double totalExpense;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: categoryTotals.map((entry) {
          final color = AppCategories.colorFor(entry.key);

          final ratio = totalExpense == 0
              ? 0.0
              : entry.value / totalExpense;

          return Padding(
            padding: const EdgeInsets.only(bottom: 17),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: color.withOpacity(.11),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        AppCategories.iconFor(entry.key),
                        color: color,
                        size: 16,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatCurrency(entry.value),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0).toDouble(),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF0F1F6),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),

                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(ratio * 100).toStringAsFixed(0)}% of expenses',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
