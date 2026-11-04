import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink)),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }
}
