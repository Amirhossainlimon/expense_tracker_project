import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/providers/transaction_provider.dart';
import 'activity_screen.dart';
import 'dashboard_screen.dart';
import 'insights_screen.dart';
import 'transaction_form_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.provider});

  final TransactionProvider provider;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  Future<void> _openAddTransaction() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TransactionFormScreen(provider: widget.provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Expense Tracker', 'Transactions', 'Insights'];

    return AnimatedBuilder(
      animation: widget.provider,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 20,
            title: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF8279FF), AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(titles[_selectedIndex]),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 18),
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppColors.violetSoft, borderRadius: BorderRadius.circular(13)),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardScreen(provider: widget.provider, onViewAll: () => setState(() => _selectedIndex = 1), onAdd: _openAddTransaction),
                ActivityScreen(provider: widget.provider),
                InsightsScreen(provider: widget.provider),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddTransaction,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 5,
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text('Add transaction', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          bottomNavigationBar: NavigationBar(
            height: 70,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.grid_view_rounded), selectedIcon: Icon(Icons.grid_view_rounded), label: 'Overview'),
              NavigationDestination(icon: Icon(Icons.swap_horiz_rounded), selectedIcon: Icon(Icons.swap_horiz_rounded), label: 'Activity'),
              NavigationDestination(icon: Icon(Icons.insights_rounded), selectedIcon: Icon(Icons.insights_rounded), label: 'Insights'),
            ],
          ),
        );
      },
    );
  }
}
