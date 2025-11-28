import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class GameNotesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> gameNotes;
  final TextEditingController noteController;
  final VoidCallback onAddNote;

  const GameNotesWidget({
    super.key,
    required this.gameNotes,
    required this.noteController,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Notes',
            style: theme.textTheme.titleLarge,
          ),

          SizedBox(height: 2.h),

          // Add Note Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  ),
                  maxLines: 2,
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'send',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                onPressed: onAddNote,
                tooltip: 'Add Note',
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Notes List
          if (gameNotes.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Text(
                  'No notes yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gameNotes.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final note = gameNotes[index];
                final timestamp = note["timestamp"] as DateTime;
                final timeFormat = DateFormat('MMM d, h:mm a');

                return Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            note["author"] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            timeFormat.format(timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        note["note"] as String,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
