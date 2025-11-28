import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PerformanceTabWidget extends StatelessWidget {
  final String selectedPlayer;
  final String dateRange;

  const PerformanceTabWidget({
    super.key,
    required this.selectedPlayer,
    required this.dateRange,
  });

  // Mock performance data
  List<Map<String, dynamic>> _getPerformanceData() {
    return [
      {
        'metric': 'Average Session Length',
        'value': '4.2 hours',
        'progress': 0.7,
        'groupAvg': '3.8 hours',
        'comparison': 'above',
      },
      {
        'metric': 'Hands Played',
        'value': '2,847',
        'progress': 0.85,
        'groupAvg': '2,200',
        'comparison': 'above',
      },
      {
        'metric': 'ROI (Return on Investment)',
        'value': '23.5%',
        'progress': 0.65,
        'groupAvg': '18.2%',
        'comparison': 'above',
      },
      {
        'metric': 'Consistency Score',
        'value': '8.2/10',
        'progress': 0.82,
        'groupAvg': '7.1/10',
        'comparison': 'above',
      },
      {
        'metric': 'Best Streak',
        'value': '7 wins',
        'progress': 0.58,
        'groupAvg': '5 wins',
        'comparison': 'above',
      },
      {
        'metric': 'Avg Profit per Session',
        'value': '\$66.50',
        'progress': 0.72,
        'groupAvg': '\$52.30',
        'comparison': 'above',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final performanceData = _getPerformanceData();

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: performanceData.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final item = performanceData[index];
        return _buildPerformanceCard(context, theme, item);
      },
    );
  }

  Widget _buildPerformanceCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> data,
  ) {
    final isAboveAverage = data['comparison'] == 'above';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data['metric'],
                  style: theme.textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: isAboveAverage
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName:
                          isAboveAverage ? 'trending_up' : 'trending_down',
                      color: isAboveAverage ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      isAboveAverage ? 'Above' : 'Below',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isAboveAverage ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            data['value'],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: data['progress'],
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                'Group Average: ',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                data['groupAvg'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
