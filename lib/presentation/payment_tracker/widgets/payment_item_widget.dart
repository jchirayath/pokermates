import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PaymentItemWidget extends StatelessWidget {
  final Map<String, dynamic> payment;
  final VoidCallback onSendReminder;
  final VoidCallback onMarkPaid;
  final VoidCallback onEditAmount;

  const PaymentItemWidget({
    super.key,
    required this.payment,
    required this.onSendReminder,
    required this.onMarkPaid,
    required this.onEditAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOwedToMe = payment['type'] == 'owed_to_me';
    final isCompleted = payment['type'] == 'completed';
    final isOverdue = payment['isOverdue'] == true;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        enabled: !isCompleted,
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onSendReminder(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.notifications_outlined,
              label: 'Remind',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
            SlidableAction(
              onPressed: (context) => onMarkPaid(),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              icon: Icons.check_circle_outline,
              label: 'Paid',
            ),
            SlidableAction(
              onPressed: (context) => onEditAmount(),
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? theme.colorScheme.error.withValues(alpha: 0.5)
                  : theme.dividerColor,
              width: isOverdue ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(3.w),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: payment['avatar'] as String,
                        width: 12.w,
                        height: 12.w,
                        fit: BoxFit.cover,
                        semanticLabel: payment['semanticLabel'] as String,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment['playerName'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          payment['gameReference'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName:
                                isOwedToMe ? 'arrow_downward' : 'arrow_upward',
                            size: 16,
                            color: isOwedToMe
                                ? theme.colorScheme.secondary
                                : theme.colorScheme.error,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '\$${(payment['amount'] as num).toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isOwedToMe
                                  ? theme.colorScheme.secondary
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                                  theme, payment['status'] as String)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          payment['status'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getStatusColor(
                                theme, payment['status'] as String),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _formatDate(payment['dueDate'] as DateTime),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isOverdue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      if (isOverdue) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'OVERDUE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'payment',
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        payment['paymentMethod'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme, String status) {
    switch (status) {
      case 'Completed':
        return theme.colorScheme.secondary;
      case 'Sent':
        return theme.colorScheme.primary;
      case 'Disputed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.tertiary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Due Today';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else if (difference == -1) {
      return 'Due Yesterday';
    } else if (difference > 0) {
      return 'Due in $difference days';
    } else {
      return '${difference.abs()} days overdue';
    }
  }
}
