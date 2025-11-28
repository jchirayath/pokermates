import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdvancedOptionsSection extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? selectedSeries;
  final String? selectedRecurrence;
  final String? selectedReminderTime;
  final TextEditingController notesController;
  final Function(String?) onSeriesChanged;
  final Function(String?) onRecurrenceChanged;
  final Function(String?) onReminderChanged;

  const AdvancedOptionsSection({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    this.selectedSeries,
    this.selectedRecurrence,
    this.selectedReminderTime,
    required this.notesController,
    required this.onSeriesChanged,
    required this.onRecurrenceChanged,
    required this.onReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'tune',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Advanced Options',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: CustomIconWidget(
                      iconName: 'expand_more',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Game Series Selector
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'event_repeat',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSeries,
                              hint: Text(
                                'Select game series (optional)',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              isExpanded: true,
                              icon: CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'none',
                                  child: Text('One-time game',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text('Weekly Series',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: 'biweekly',
                                  child: Text('Bi-weekly Series',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Monthly Series',
                                      style: theme.textTheme.bodyLarge),
                                ),
                              ],
                              onChanged: onSeriesChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (selectedSeries != null && selectedSeries != 'none') ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'info',
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Future games will be automatically created based on this schedule',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // WhatsApp Reminder Selector
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'notifications',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedReminderTime,
                              hint: Text(
                                'WhatsApp reminder (optional)',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              isExpanded: true,
                              icon: CustomIconWidget(
                                iconName: 'arrow_drop_down',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'none',
                                  child: Text('No reminder',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: '1hour',
                                  child: Text('1 hour before',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: '3hours',
                                  child: Text('3 hours before',
                                      style: theme.textTheme.bodyLarge),
                                ),
                                DropdownMenuItem(
                                  value: '1day',
                                  child: Text('1 day before',
                                      style: theme.textTheme.bodyLarge),
                                ),
                              ],
                              onChanged: onReminderChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Notes Field
                  TextFormField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Add special instructions or notes...',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding:
                            const EdgeInsets.only(top: 12, left: 12, right: 12),
                        child: CustomIconWidget(
                          iconName: 'notes',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      helperText: 'Optional game notes or special rules',
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
