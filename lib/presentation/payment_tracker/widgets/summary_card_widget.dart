import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SummaryCardWidget extends StatelessWidget {
  final double totalOwedToMe;
  final double totalIOwe;
  final double netPosition;

  const SummaryCardWidget({
    super.key,
    required this.totalOwedToMe,
    required this.totalIOwe,
    required this.netPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isPositive = netPosition >= 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPositive
                ? [
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondary.withValues(alpha: 0.8),
                  ]
                : [
                    theme.colorScheme.error,
                    theme.colorScheme.error.withValues(alpha: 0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'Owed to Me',
                    totalOwedToMe,
                    CustomIconWidget(
                      iconName: 'arrow_downward',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 8.h,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    context,
                    'I Owe',
                    totalIOwe,
                    CustomIconWidget(
                      iconName: 'arrow_upward',
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net Position',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: isPositive ? 'trending_up' : 'trending_down',
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${isPositive ? '+' : ''}\$${netPosition.abs().toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    double amount,
    Widget icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        icon,
        SizedBox(height: 1.h),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 0.5.h),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
