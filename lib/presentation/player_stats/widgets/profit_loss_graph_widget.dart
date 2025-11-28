import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProfitLossGraphWidget extends StatefulWidget {
  final String selectedPlayer;
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const ProfitLossGraphWidget({
    super.key,
    required this.selectedPlayer,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  State<ProfitLossGraphWidget> createState() => _ProfitLossGraphWidgetState();
}

class _ProfitLossGraphWidgetState extends State<ProfitLossGraphWidget> {
  final List<String> _periods = ['30 Days', '6 Months', '1 Year', 'All Time'];

  // Mock graph data
  List<FlSpot> _getGraphData() {
    switch (widget.selectedPeriod) {
      case '30 Days':
        return [
          const FlSpot(0, 100),
          const FlSpot(1, 250),
          const FlSpot(2, 180),
          const FlSpot(3, 420),
          const FlSpot(4, 380),
          const FlSpot(5, 550),
          const FlSpot(6, 480),
        ];
      case '6 Months':
        return [
          const FlSpot(0, 500),
          const FlSpot(1, 1200),
          const FlSpot(2, 900),
          const FlSpot(3, 1800),
          const FlSpot(4, 2200),
          const FlSpot(5, 2800),
        ];
      case '1 Year':
        return [
          const FlSpot(0, 1000),
          const FlSpot(1, 2500),
          const FlSpot(2, 2000),
          const FlSpot(3, 3500),
          const FlSpot(4, 4200),
          const FlSpot(5, 5500),
          const FlSpot(6, 6200),
          const FlSpot(7, 6800),
          const FlSpot(8, 7500),
          const FlSpot(9, 7200),
          const FlSpot(10, 8000),
          const FlSpot(11, 8450),
        ];
      default: // All Time
        return [
          const FlSpot(0, 0),
          const FlSpot(1, 1500),
          const FlSpot(2, 1200),
          const FlSpot(3, 2800),
          const FlSpot(4, 3500),
          const FlSpot(5, 4200),
          const FlSpot(6, 5000),
          const FlSpot(7, 5800),
          const FlSpot(8, 6500),
          const FlSpot(9, 7200),
          const FlSpot(10, 7800),
          const FlSpot(11, 8450),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.all(4.w),
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
              Text(
                'Profit/Loss Trend',
                style: theme.textTheme.titleLarge,
              ),
              CustomIconWidget(
                iconName: 'zoom_in',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Period selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periods.map((period) {
                final isSelected = period == widget.selectedPeriod;
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        widget.onPeriodChanged(period);
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 3.h),
          // Graph
          SizedBox(
            height: 30.h,
            child: Semantics(
              label:
                  'Profit and Loss Line Chart showing trend over ${widget.selectedPeriod}',
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2000,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${(value / 1000).toStringAsFixed(0)}k',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  minX: 0,
                  maxX: _getGraphData().length.toDouble() - 1,
                  minY: 0,
                  maxY: 10000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getGraphData(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: theme.colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '\$${spot.y.toStringAsFixed(0)}',
                            TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
