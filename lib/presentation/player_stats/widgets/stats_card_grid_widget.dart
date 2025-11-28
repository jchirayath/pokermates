import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class StatsCardGridWidget extends StatelessWidget {
  final String selectedPlayer;
  final String dateRange;

  const StatsCardGridWidget({
    super.key,
    required this.selectedPlayer,
    required this.dateRange,
  });

  // Mock stats data
  Map<String, dynamic> _getStatsData() {
    return {
      'totalGames': 127,
      'netProfit': 8450.00,
      'profitTrend': 'up',
      'avgBuyIn': 150.00,
      'biggestWin': 1250.00,
      'biggestLoss': -850.00,
      'winRate': 58.3,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _getStatsData();

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Total Games',
                  '${stats['totalGames']}',
                  Icons.casino_outlined,
                  null,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Net Profit',
                  '\$${stats['netProfit'].toStringAsFixed(0)}',
                  Icons.trending_up,
                  stats['profitTrend'] == 'up' ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Avg Buy-In',
                  '\$${stats['avgBuyIn'].toStringAsFixed(0)}',
                  Icons.attach_money,
                  null,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Win Rate',
                  '${stats['winRate']}%',
                  Icons.emoji_events_outlined,
                  null,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Biggest Win',
                  '\$${stats['biggestWin'].toStringAsFixed(0)}',
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  theme,
                  'Biggest Loss',
                  '\$${stats['biggestLoss'].toStringAsFixed(0)}',
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color? valueColor,
  ) {
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
            children: [
              CustomIconWidget(
                iconName: icon
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('IconData(U+', '')
                    .replaceAll(')', ''),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
