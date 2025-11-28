import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying list of upcoming games with swipe actions
class UpcomingGamesListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> upcomingGames;
  final Function(Map<String, dynamic>) onGameTap;
  final Function(Map<String, dynamic>) onRSVPToggle;
  final Function(Map<String, dynamic>) onShareGame;
  final Function(Map<String, dynamic>) onSetReminder;

  const UpcomingGamesListWidget({
    super.key,
    required this.upcomingGames,
    required this.onGameTap,
    required this.onRSVPToggle,
    required this.onShareGame,
    required this.onSetReminder,
  });

  String _getCountdownText(DateTime gameDate) {
    final now = DateTime.now();
    final difference = gameDate.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Starting soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Text(
            'Upcoming Games',
            style: theme.textTheme.titleLarge,
          ),
        ),
        SizedBox(height: 1.h),
        upcomingGames.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'event_busy',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No upcoming games scheduled',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: upcomingGames.length,
                itemBuilder: (context, index) {
                  final game = upcomingGames[index];
                  final gameDate = game['date'] as DateTime;
                  final isRSVPed = game['isRSVPed'] as bool? ?? false;

                  return Slidable(
                    key: ValueKey(game['id']),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => onRSVPToggle(game),
                          backgroundColor: isRSVPed
                              ? theme.colorScheme.error
                              : theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          icon: isRSVPed ? Icons.cancel : Icons.check_circle,
                          label: isRSVPed ? 'Cancel' : 'RSVP',
                        ),
                        SlidableAction(
                          onPressed: (_) => onShareGame(game),
                          backgroundColor: theme.colorScheme.tertiary,
                          foregroundColor: theme.colorScheme.onTertiary,
                          icon: Icons.share,
                          label: 'Share',
                        ),
                        SlidableAction(
                          onPressed: (_) => onSetReminder(game),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          icon: Icons.notifications,
                          label: 'Remind',
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      child: InkWell(
                        onTap: () => onGameTap(game),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          game['title'] as String,
                                          style: theme.textTheme.titleMedium,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          _getCountdownText(gameDate),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.tertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isRSVPed)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.w,
                                        vertical: 0.5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomIconWidget(
                                            iconName: 'check_circle',
                                            color: theme.colorScheme.secondary,
                                            size: 16,
                                          ),
                                          SizedBox(width: 1.w),
                                          Text(
                                            'RSVP\'d',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                              color:
                                                  theme.colorScheme.secondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'calendar_today',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      '${gameDate.day}/${gameDate.month}/${gameDate.year} at ${gameDate.hour}:${gameDate.minute.toString().padLeft(2, '0')}',
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'location_on',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      game['location'] as String,
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'person',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Expanded(
                                    child: Text(
                                      'Host: ${game['host'] as String}',
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'people',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${game['confirmedPlayers']} players confirmed',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
