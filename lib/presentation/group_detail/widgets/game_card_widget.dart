import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Game card widget with expandable details and context menu
class GameCardWidget extends StatefulWidget {
  final Map<String, dynamic> game;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const GameCardWidget({
    super.key,
    required this.game,
    required this.isAdmin,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onTap,
  });

  @override
  State<GameCardWidget> createState() => _GameCardWidgetState();
}

class _GameCardWidgetState extends State<GameCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            onLongPress: widget.isAdmin ? _showContextMenu : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDay(widget.game["date"] as String),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _formatMonth(widget.game["date"] as String),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.game["location"] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'people',
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${widget.game["players"]} Players',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: 'attach_money',
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            Text(
                              widget.game["buyIn"] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Divider(height: 1, color: theme.dividerColor),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    'Total Pot',
                    widget.game["totalPot"] as String,
                    Icons.monetization_on,
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    context,
                    'Winner',
                    widget.game["winner"] as String,
                    Icons.emoji_events,
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    context,
                    'Status',
                    _formatStatus(widget.game["status"] as String),
                    Icons.check_circle,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onTap,
                          icon: CustomIconWidget(
                            iconName: 'visibility',
                            size: 18,
                          ),
                          label: const Text('View Details'),
                        ),
                      ),
                      if (widget.isAdmin) ...[
                        SizedBox(width: 2.w),
                        IconButton(
                          onPressed: _showContextMenu,
                          icon: CustomIconWidget(
                            iconName: 'more_vert',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CustomIconWidget(
          iconName: icon.toString().split('.').last.replaceAll(')', ''),
          size: 20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showContextMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Edit Game'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEdit();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'content_copy',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Duplicate Game'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDuplicate();
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: theme.colorScheme.error,
                  size: 24,
                ),
                title: Text(
                  'Delete Game',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onDelete();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDay(String dateStr) {
    final date = DateTime.parse(dateStr);
    return date.day.toString();
  }

  String _formatMonth(String dateStr) {
    final date = DateTime.parse(dateStr);
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return months[date.month - 1];
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }
}
