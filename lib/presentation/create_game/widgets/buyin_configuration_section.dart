import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BuyinConfigurationSection extends StatelessWidget {
  final TextEditingController buyinController;
  final bool allowRebuys;
  final TextEditingController rebuyAmountController;
  final Function(bool?) onRebuyChanged;

  const BuyinConfigurationSection({
    super.key,
    required this.buyinController,
    required this.allowRebuys,
    required this.rebuyAmountController,
    required this.onRebuyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buy-in Configuration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Buy-in Amount
          TextFormField(
            controller: buyinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Buy-in Amount',
              hintText: 'Enter amount',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '\$',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              suffixIcon: buyinController.text.isNotEmpty
                  ? IconButton(
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () => buyinController.clear(),
                    )
                  : null,
              helperText: 'Standard buy-in amount for all players',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter buy-in amount';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Allow Rebuys Toggle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allow Rebuys',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Players can rebuy during the game',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: allowRebuys,
                  onChanged: onRebuyChanged,
                ),
              ],
            ),
          ),

          // Rebuy Amount (shown only if rebuys allowed)
          if (allowRebuys) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: rebuyAmountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: 'Rebuy Amount',
                hintText: 'Enter rebuy amount',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '\$',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                suffixIcon: rebuyAmountController.text.isNotEmpty
                    ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () => rebuyAmountController.clear(),
                      )
                    : null,
                helperText: 'Amount for each rebuy (optional)',
              ),
              validator: (value) {
                if (allowRebuys && (value == null || value.isEmpty)) {
                  return 'Please enter rebuy amount';
                }
                if (value != null && value.isNotEmpty) {
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                }
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }
}
