import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/transaction_provider.dart';
import 'presentation/screens/main_shell.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late final TransactionProvider _provider;
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();

    _provider = TransactionProvider();
    _initialization = _provider.loadTransactions();
  }

  void _retryInitialization() {
    setState(() {
      _initialization = _provider.loadTransactions();
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CashTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            return StartupErrorScreen(
              message: snapshot.error.toString(),
              onRetry: _retryInitialization,
            );
          }

          return MainShell(provider: _provider);
        },
      ),
    );
  }
}

// ======================================================
// CASH TRACK SPLASH SCREEN
// ======================================================

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color green = Color(0xFF10B981);
  static const Color dark = Color(0xFF172B4D);
  static const Color grey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO
                  Container(
                    width: 145,
                    height: 145,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF8),
                      borderRadius: BorderRadius.circular(34),
                      border: Border.all(
                        color: const Color(0xFFD1FAE5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: green.withOpacity(0.12),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'asset/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 76,
                          color: green,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // APP NAME
                  const Text(
                    'CashTrack',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: dark,
                      letterSpacing: -1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // TAGLINE
                  const Text(
                    'Track Your Money. Control Your Future.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: grey,
                    ),
                  ),

                  const SizedBox(height: 45),

                  // LOADING INDICATOR
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(green),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Preparing your finances...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// STARTUP ERROR SCREEN
// ======================================================

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const Color green = Color(0xFF10B981);
  static const Color dark = Color(0xFF172B4D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ERROR ICON
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 46,
                      color: Color(0xFFEF4444),
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Something went wrong!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: dark,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'CashTrack could not load your transactions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF64748B),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ERROR DETAILS
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: SelectableText(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // RETRY BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'CashTrack • Personal Finance Manager',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
