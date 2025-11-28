import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../game_detail.dart';

class PlayerCardWidget extends StatelessWidget {
  final Map<String, dynamic> player;
  final GameStatus gameStatus;

  const PlayerCardWidget({
    super.key,
    required this.player,
    required this.gameStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buyIn = player["buyIn"] as double;
    final cashOut = player["cashOut"] as double;
    final currentStack = player["currentStack"] as double;
    final rebuys = player["rebuys"] as int;
    final netProfit = player["netProfit"] as double;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Player Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: CustomImageWidget(
              imageUrl: player["avatar"] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              semanticLabel: player["semanticLabel"] as String,
            ),
          ),

          SizedBox(width: 3.w),

          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player["name"] as String,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                if (gameStatus == GameStatus.scheduled)
                  Text(
                    'Buy-in: \$${buyIn.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (gameStatus == GameStatus.inProgress)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy-in: \$${buyIn.toStringAsFixed(2)}${rebuys > 0 ? ' (+$rebuys rebuys)' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Stack: \$${currentStack.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                if (gameStatus == GameStatus.completed)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buy-in: \$${buyIn.toStringAsFixed(2)} | Cash-out: \$${cashOut.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Net: ',
                            style: theme.textTheme.bodyMedium,
                          ),
                          Text(
                            '${netProfit >= 0 ? '+' : ''}\$${netProfit.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: netProfit >= 0
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Action Indicator
          if (gameStatus == GameStatus.inProgress)
            CustomIconWidget(
              iconName: 'chevron_left',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 24,
            ),
        ],
      ),
    );
  }
}
