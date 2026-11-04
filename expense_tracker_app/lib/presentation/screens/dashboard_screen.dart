import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/providers/transaction_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_heading.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.provider,
    required this.onViewAll,
    required this.onAdd,
  });

  final TransactionProvider provider;
  final VoidCallback onViewAll;
  final VoidCallback onAdd;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openDetails(BuildContext context, ExpenseTransaction transaction) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(transaction: transaction, provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recent = provider.transactions.take(4).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 112),
      children: [
        Text(_greeting(), style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Your money, in focus.', style: TextStyle(color: AppColors.ink, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.6)),
        const SizedBox(height: 18),
        _BalanceCard(balance: provider.balance, monthExpense: provider.currentMonthExpense),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total income',
                value: provider.totalIncome,
                icon: Icons.south_west_rounded,
                color: AppColors.income,
                background: AppColors.incomeSoft,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                label: 'Total expense',
                value: provider.totalExpense,
                icon: Icons.north_east_rounded,
                color: AppColors.expense,
                background: AppColors.expenseSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        SectionHeading(title: 'Recent activity', actionLabel: 'See all', onAction: onViewAll),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
            child: EmptyState(
              title: 'No transactions yet',
              message: 'Add your first income or expense to start seeing your money clearly.',
              actionLabel: 'Add transaction',
              onAction: onAdd,
            ),
          )
        else
          ...recent.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: TransactionTile(
                transaction: transaction,
                onTap: () => _openDetails(context, transaction),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _QuickTipCard(),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.monthExpense});

  final double balance;
  final double monthExpense;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7770F4), Color(0xFF5148CF)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.22), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Stack(
        children: [
          Positioned(right: -55, top: -68, child: _Orb(size: 175, opacity: .08)),
          Positioned(right: 38, bottom: -105, child: _Orb(size: 150, opacity: .07)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Current balance', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.15), borderRadius: BorderRadius.circular(30)),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 5),
                        Text('ALL TIME', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .8)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(formatCurrency(balance), style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -.8)),
              ),
              const SizedBox(height: 22),
              Container(height: 1, color: Colors.white.withOpacity(.18)),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Colors.white70, size: 15),
                  const SizedBox(width: 7),
                  const Text('Spent this month', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(formatCurrency(monthExpense), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(opacity)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color, required this.background});

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(21)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 30, height: 30, decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 17)),
              const Spacer(),
              Icon(Icons.more_horiz_rounded, color: AppColors.muted.withOpacity(.65), size: 18),
            ],
          ),
          const SizedBox(height: 13),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatCurrency(value), style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -.3)),
          ),
        ],
      ),
    );
  }
}

class _QuickTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFEDEBFF), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 23),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'A small habit makes a big difference. Record each transaction as it happens.',
              style: TextStyle(color: Color(0xFF504A9D), fontSize: 11.5, height: 1.45, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
