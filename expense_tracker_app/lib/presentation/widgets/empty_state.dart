import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.receipt_long_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        final isCompact = availableHeight < 220;
        final isVeryCompact = availableHeight < 145;

        final iconSize =
            isVeryCompact
                ? 44.0
                : isCompact
                ? 56.0
                : 76.0;

        final iconRadius =
            isVeryCompact
                ? 15.0
                : isCompact
                ? 19.0
                : 25.0;

        final verticalPadding =
            isVeryCompact
                ? 8.0
                : isCompact
                ? 12.0
                : 24.0;

        final titleSize = isVeryCompact ? 14.0 : 17.0;
        final messageSize = isVeryCompact ? 11.0 : 13.0;

        final spacing =
            isVeryCompact
                ? 5.0
                : isCompact
                ? 8.0
                : 14.0;

        return Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: AppColors.violetSoft,
                        borderRadius: BorderRadius.circular(iconRadius),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                        size: iconSize * 0.45,
                      ),
                    ),

                    SizedBox(height: spacing),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),

                    SizedBox(height: isVeryCompact ? 3 : 7),

                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: messageSize,
                        height: 1.4,
                        color: AppColors.muted,
                      ),
                    ),

                    if (actionLabel != null && onAction != null) ...[
                      SizedBox(height: spacing),
                      FilledButton.icon(
                        onPressed: onAction,
                        icon: const Icon(Icons.add_rounded),
                        label: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
