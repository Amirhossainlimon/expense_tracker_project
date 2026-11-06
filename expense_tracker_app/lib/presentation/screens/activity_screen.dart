
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/expense_transaction.dart';
import '../../data/providers/transaction_provider.dart';
import '../widgets/delete_confirmation.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_details_screen.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.provider});

  final TransactionProvider provider;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _filter = 'All';
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseTransaction> _filteredTransactions() {
    return widget.provider.transactions.where((transaction) {
      final matchesType = _filter == 'All' ||
          (_filter == 'Income' && transaction.isIncome) ||
          (_filter == 'Expense' && !transaction.isIncome);

      final query = _search.trim().toLowerCase();

      final matchesSearch = query.isEmpty ||
          transaction.title.toLowerCase().contains(query) ||
          transaction.category.toLowerCase().contains(query);

      return matchesType && matchesSearch;
    }).toList();
  }

  void _openDetails(ExpenseTransaction transaction) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailsScreen(
          transaction: transaction,
          provider: widget.provider,
        ),
      ),
    );
  }

  Future<void> _delete(ExpenseTransaction transaction) async {
    final confirmed = await confirmDeleteTransaction(
      context,
      transaction,
    );

    if (!confirmed || !mounted || transaction.id == null) return;

    await widget.provider.deleteTransaction(transaction.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        final horizontalPadding = screenWidth >= 1000
            ? 32.0
            : screenWidth >= 600
            ? 26.0
            : 16.0;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                98,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your activity',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${widget.provider.transactions.length} transactions saved on this device',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _search = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by title or category',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.muted,
                      ),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _search = '');
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                        ),
                      )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Income', 'Expense'].map((filter) {
                      final selected = _filter == filter;

                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) {
                          setState(() => _filter = filter);
                        },
                        labelStyle: TextStyle(
                          color: selected
                              ? AppColors.primary
                              : AppColors.muted,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primary.withOpacity(.18)
                              : AppColors.line,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: filtered.isEmpty
                        ? EmptyState(
                      title: widget.provider.transactions.isEmpty
                          ? 'Nothing here yet'
                          : 'No matching transactions',
                      message: widget.provider.transactions.isEmpty
                          ? 'Your income and expenses will appear here after you add them.'
                          : 'Try another search or switch the transaction filter.',
                      icon: Icons.manage_search_rounded,
                    )
                        : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final transaction = filtered[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: TransactionTile(
                            transaction: transaction,
                            onTap: () => _openDetails(transaction),
                            onDelete: () => _delete(transaction),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
