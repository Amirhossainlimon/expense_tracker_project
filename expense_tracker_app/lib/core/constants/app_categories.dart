import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppCategories {
  static const all = <String>[
    'Food & Dining',
    'Transport',
    'Shopping',
    'Bills & Utilities',
    'Health',
    'Education',
    'Salary',
    'Freelance',
    'Business',
    'Investment',
    'Gift',
    'Other',
  ];

  static IconData iconFor(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant_rounded;
      case 'Transport':
        return Icons.directions_car_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills & Utilities':
        return Icons.receipt_long_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Education':
        return Icons.school_rounded;
      case 'Salary':
        return Icons.account_balance_wallet_rounded;
      case 'Freelance':
        return Icons.laptop_mac_rounded;
      case 'Business':
        return Icons.storefront_rounded;
      case 'Investment':
        return Icons.trending_up_rounded;
      case 'Gift':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color colorFor(String category) {
    switch (category) {
      case 'Food & Dining':
        return const Color(0xFFE69A43);
      case 'Transport':
        return const Color(0xFF4D91D7);
      case 'Shopping':
        return const Color(0xFF9A78D9);
      case 'Bills & Utilities':
        return const Color(0xFFDB7186);
      case 'Health':
        return const Color(0xFFE56D79);
      case 'Education':
        return const Color(0xFF4E9D9B);
      case 'Salary':
        return AppColors.income;
      case 'Freelance':
        return const Color(0xFF5986C7);
      case 'Business':
        return const Color(0xFF9374C9);
      case 'Investment':
        return const Color(0xFF3FA68C);
      case 'Gift':
        return const Color(0xFFDC8BB3);
      default:
        return AppColors.primary;
    }
  }
}
