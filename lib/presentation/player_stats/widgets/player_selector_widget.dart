import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PlayerSelectorWidget extends StatelessWidget {
  final String selectedPlayer;
  final List<String> players;
  final ValueChanged<String?> onPlayerChanged;

  const PlayerSelectorWidget({
    super.key,
    required this.selectedPlayer,
    required this.players,
    required this.onPlayerChanged,
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
            iconName: 'person',
            color: theme.colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPlayer,
                isExpanded: true,
                icon: CustomIconWidget(
                  iconName: 'arrow_drop_down',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                style: theme.textTheme.titleMedium,
                items: players.map((String player) {
                  return DropdownMenuItem<String>(
                    value: player,
                    child: Text(player),
                  );
                }).toList(),
                onChanged: onPlayerChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
