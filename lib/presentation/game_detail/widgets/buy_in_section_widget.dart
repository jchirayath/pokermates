import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BuyInSectionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  final Map<String, dynamic> gameData;

  const BuyInSectionWidget({
    super.key,
    required this.players,
    required this.gameData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate totals
    double totalBuyIn = 0;
    double totalStack = 0;

    for (var player in players) {
      totalBuyIn += player["buyIn"] as double;
      totalStack += player["currentStack"] as double;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Running Totals',
            style: theme.textTheme.titleLarge,
          ),

          SizedBox(height: 2.h),

          // Total Buy-in
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Buy-in',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '\$${totalBuyIn.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Total Stack
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Stack',
                style: theme.textTheme.bodyLarge,
              ),
              Text(
                '\$${totalStack.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),

          SizedBox(height: 1.h),

          // Difference
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Difference',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${(totalStack - totalBuyIn).toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: (totalStack - totalBuyIn) >= 0
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
