import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DateRangePickerWidget extends StatelessWidget {
  final String selectedRange;
  final List<String> dateRanges;
  final ValueChanged<String?> onRangeChanged;

  const DateRangePickerWidget({
    super.key,
    required this.selectedRange,
    required this.dateRanges,
    required this.onRangeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'calendar_today',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRange,
                isExpanded: true,
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                style: theme.textTheme.titleMedium,
                items: dateRanges.map((String range) {
                  return DropdownMenuItem<String>(
                    value: range,
                    child: Text(range),
                  );
                }).toList(),
                onChanged: onRangeChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
