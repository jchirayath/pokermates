import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Settings section widget for group configuration
class SettingsSectionWidget extends StatefulWidget {
  final int groupId;

  const SettingsSectionWidget({
    super.key,
    required this.groupId,
  });

  @override
  State<SettingsSectionWidget> createState() => _SettingsSectionWidgetState();
}

class _SettingsSectionWidgetState extends State<SettingsSectionWidget> {
  bool _whatsappEnabled = true;
  bool _autoReminders = true;
  String _defaultLocation = "John's House";
  String _defaultBuyIn = "\$50";

  final List<String> _locations = [
    "John's House",
    "Mike's Apartment",
    "Community Center",
    "Sarah's Place",
  ];

  final List<String> _buyInOptions = [
    "\$25",
    "\$50",
    "\$75",
    "\$100",
    "\$150",
    "\$200",
  ];

  final List<Map<String, dynamic>> _paymentPlatforms = [
    {"name": "Venmo", "enabled": true, "icon": "account_balance_wallet"},
    {"name": "PayPal", "enabled": true, "icon": "payment"},
    {"name": "CashApp", "enabled": false, "icon": "attach_money"},
    {"name": "Apple Pay", "enabled": true, "icon": "apple"},
    {"name": "Google Pay", "enabled": false, "icon": "google"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'WhatsApp Integration'),
        _buildWhatsAppSettings(theme),
        SizedBox(height: 3.h),
        _buildSectionHeader(context, 'Game Defaults'),
        _buildGameDefaults(theme),
        SizedBox(height: 3.h),
        _buildSectionHeader(context, 'Payment Platforms'),
        _buildPaymentPlatforms(theme),
        SizedBox(height: 3.h),
        _buildSectionHeader(context, 'Recurring Games'),
        _buildRecurringGames(theme),
        SizedBox(height: 3.h),
        _buildDangerZone(theme),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildWhatsAppSettings(ThemeData theme) {
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
          SwitchListTile(
            value: _whatsappEnabled,
            onChanged: (value) {
              setState(() => _whatsappEnabled = value);
            },
            title: const Text('Enable WhatsApp Reminders'),
            subtitle: const Text('Send game reminders via WhatsApp'),
            secondary: CustomIconWidget(
              iconName: 'chat',
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          if (_whatsappEnabled) ...[
            Divider(height: 1, color: theme.dividerColor),
            SwitchListTile(
              value: _autoReminders,
              onChanged: (value) {
                setState(() => _autoReminders = value);
              },
              title: const Text('Automatic Reminders'),
              subtitle: const Text('Send reminders 24 hours before game'),
              secondary: CustomIconWidget(
                iconName: 'schedule',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameDefaults(ThemeData theme) {
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
          ListTile(
            leading: CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: const Text('Default Location'),
            subtitle: Text(_defaultLocation),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            onTap: () => _showLocationPicker(theme),
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'attach_money',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: const Text('Default Buy-In'),
            subtitle: Text(_defaultBuyIn),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            onTap: () => _showBuyInPicker(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentPlatforms(ThemeData theme) {
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
        children: _paymentPlatforms.asMap().entries.map((entry) {
          final index = entry.key;
          final platform = entry.value;
          return Column(
            children: [
              if (index > 0) Divider(height: 1, color: theme.dividerColor),
              SwitchListTile(
                value: platform["enabled"] as bool,
                onChanged: (value) {
                  setState(() {
                    _paymentPlatforms[index]["enabled"] = value;
                  });
                },
                title: Text(platform["name"] as String),
                subtitle: Text(
                  (platform["enabled"] as bool) ? 'Enabled' : 'Disabled',
                ),
                secondary: CustomIconWidget(
                  iconName: platform["icon"] as String,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecurringGames(ThemeData theme) {
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
          ListTile(
            leading: CustomIconWidget(
              iconName: 'event_repeat',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: const Text('Weekly Game Template'),
            subtitle: const Text('Friday nights at 7:00 PM'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Recurring game template settings')),
              );
            },
          ),
          Divider(height: 1, color: theme.dividerColor),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'add_circle',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: const Text('Add Recurring Game'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add recurring game')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CustomIconWidget(
              iconName: 'warning',
              color: theme.colorScheme.error,
              size: 24,
            ),
            title: Text(
              'Danger Zone',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(
              height: 1, color: theme.colorScheme.error.withValues(alpha: 0.3)),
          ListTile(
            leading: CustomIconWidget(
              iconName: 'delete_forever',
              color: theme.colorScheme.error,
              size: 24,
            ),
            title: Text(
              'Delete All Games',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently delete all game history'),
            trailing: CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.error,
              size: 24,
            ),
            onTap: _showDeleteAllGamesConfirmation,
          ),
        ],
      ),
    );
  }

  void _showLocationPicker(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  'Select Default Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._locations.map((location) {
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: _defaultLocation == location
                        ? 'radio_button_checked'
                        : 'radio_button_unchecked',
                    color: _defaultLocation == location
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  title: Text(location),
                  onTap: () {
                    setState(() => _defaultLocation = location);
                    Navigator.pop(context);
                  },
                );
              }),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'add_circle',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                title: Text(
                  'Add New Location',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new location')),
                  );
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showBuyInPicker(ThemeData theme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  'Select Default Buy-In',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._buyInOptions.map((buyIn) {
                return ListTile(
                  leading: CustomIconWidget(
                    iconName: _defaultBuyIn == buyIn
                        ? 'radio_button_checked'
                        : 'radio_button_unchecked',
                    color: _defaultBuyIn == buyIn
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  title: Text(buyIn),
                  onTap: () {
                    setState(() => _defaultBuyIn = buyIn);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteAllGamesConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Games'),
        content: const Text(
            'Are you sure you want to delete all game history? This action cannot be undone and will permanently remove all game data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All games deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
