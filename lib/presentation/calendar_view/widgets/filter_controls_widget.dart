import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for filtering games by group or type
class FilterControlsWidget extends StatelessWidget {
  final String? selectedGroup;
  final String? selectedGameType;
  final List<String> availableGroups;
  final List<String> availableGameTypes;
  final Function(String?) onGroupChanged;
  final Function(String?) onGameTypeChanged;
  final VoidCallback onClearFilters;

  const FilterControlsWidget({
    super.key,
    required this.selectedGroup,
    required this.selectedGameType,
    required this.availableGroups,
    required this.availableGameTypes,
    required this.onGroupChanged,
    required this.onGameTypeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActiveFilters = selectedGroup != null || selectedGameType != null;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filters',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (hasActiveFilters)
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: CustomIconWidget(
                    iconName: 'clear',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: Text(
                    'Clear',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGroup,
                      hint: Text(
                        'All Groups',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      isExpanded: true,
                      icon: CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Groups',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        ...availableGroups.map((group) {
                          return DropdownMenuItem<String>(
                            value: group,
                            child: Text(
                              group,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: onGroupChanged,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedGameType,
                      hint: Text(
                        'All Types',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      isExpanded: true,
                      icon: CustomIconWidget(
                        iconName: 'arrow_drop_down',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            'All Types',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        ...availableGameTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: onGameTypeChanged,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
