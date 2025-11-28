import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Empty state widget displayed when user has no poker groups
/// Shows poker table illustration with call-to-action to create first group
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreateGroup;

  const EmptyStateWidget({
    super.key,
    required this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Poker table illustration
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'casino',
                  color: theme.colorScheme.primary,
                  size: 80,
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Title
            Text(
              'No Groups Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),

            // Description
            Text(
              'Create your first poker group to start organizing games, tracking stats, and managing payments with your friends.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // Create group button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateGroup,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
                label: const Text('Create Your First Group'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Features list
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you can do:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildFeatureItem(
                    context,
                    icon: 'calendar_today',
                    title: 'Schedule Games',
                    description: 'Create recurring or one-time poker games',
                  ),
                  SizedBox(height: 1.5.h),
                  _buildFeatureItem(
                    context,
                    icon: 'bar_chart',
                    title: 'Track Statistics',
                    description: 'Monitor player performance and earnings',
                  ),
                  SizedBox(height: 1.5.h),
                  _buildFeatureItem(
                    context,
                    icon: 'attach_money',
                    title: 'Manage Payments',
                    description: 'Handle buy-ins and cash-outs easily',
                  ),
                  SizedBox(height: 1.5.h),
                  _buildFeatureItem(
                    context,
                    icon: 'notifications',
                    title: 'WhatsApp Reminders',
                    description: 'Automated game notifications',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
