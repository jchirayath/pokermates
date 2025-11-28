import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom sheet displaying detailed game information
class GameDetailBottomSheet extends StatelessWidget {
  final Map<String, dynamic> game;
  final VoidCallback onViewDetails;
  final VoidCallback onRSVP;
  final VoidCallback onShare;
  final VoidCallback onSetReminder;

  const GameDetailBottomSheet({
    super.key,
    required this.game,
    required this.onViewDetails,
    required this.onRSVP,
    required this.onShare,
    required this.onSetReminder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameDate = game['date'] as DateTime;
    final isRSVPed = game['isRSVPed'] as bool? ?? false;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  game['title'] as String,
                  style: theme.textTheme.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isRSVPed)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildInfoRow(
            context,
            icon: 'calendar_today',
            label: 'Date & Time',
            value:
                '${gameDate.day}/${gameDate.month}/${gameDate.year} at ${gameDate.hour}:${gameDate.minute.toString().padLeft(2, '0')}',
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            context,
            icon: 'location_on',
            label: 'Location',
            value: game['location'] as String,
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            context,
            icon: 'person',
            label: 'Host',
            value: game['host'] as String,
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            context,
            icon: 'people',
            label: 'Players',
            value: '${game['confirmedPlayers']} confirmed',
          ),
          if (game['description'] != null &&
              (game['description'] as String).isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              'Description',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              game['description'] as String,
              style: theme.textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRSVP,
                  icon: CustomIconWidget(
                    iconName: isRSVPed ? 'cancel' : 'check_circle',
                    color: isRSVPed
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                    size: 20,
                  ),
                  label: Text(isRSVPed ? 'Cancel RSVP' : 'RSVP'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isRSVPed
                        ? theme.colorScheme.error
                        : theme.colorScheme.secondary,
                    side: BorderSide(
                      color: isRSVPed
                          ? theme.colorScheme.error
                          : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: onShare,
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Share'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: onSetReminder,
                  icon: CustomIconWidget(
                    iconName: 'notifications',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Remind'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
