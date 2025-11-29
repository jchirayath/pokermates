import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/poker_service.dart';
import './widgets/advanced_options_section.dart';
import './widgets/buyin_configuration_section.dart';
import './widgets/game_basics_section.dart';
import './widgets/player_selection_section.dart';

class CreateGame extends StatefulWidget {
  const CreateGame({super.key});

  @override
  State<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  final _formKey = GlobalKey<FormState>();
  final _buyinController = TextEditingController();
  final _rebuyAmountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedLocation;
  String? _selectedHost;
  bool _allowRebuys = false;
  Set<String> _selectedPlayers = {};
  bool _advancedOptionsExpanded = false;
  String? _selectedSeries;
  String? _selectedReminderTime;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  String? _selectedGroupId;
  List<Map<String, dynamic>> _savedLocations = [];
  List<Map<String, dynamic>> _groupMembers = [];
  bool _isLoadingLocations = true;
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadLocations();
    // Get groupId from route arguments if navigated from group detail
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['groupId'] != null) {
      _selectedGroupId = args['groupId'] as String;
      await _loadGroupMembers();
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);

    try {
      final locations = await PokerService.fetchUserLocations();
      setState(() {
        _savedLocations = locations;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading locations: $e')),
        );
      }
    }
  }

  Future<void> _loadGroupMembers() async {
    if (_selectedGroupId == null) return;

    setState(() => _isLoadingMembers = true);

    try {
      final members = await PokerService.fetchGroupMembers(_selectedGroupId!);
      setState(() {
        _groupMembers = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() => _isLoadingMembers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading group members: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _buyinController.dispose();
    _rebuyAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _markAsChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _markAsChanged();
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _markAsChanged();
      });
    }
  }

  Future<void> _selectLocation() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationSelectorSheet(
        locations: _savedLocations,
        selectedLocation: _selectedLocation,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _markAsChanged();
      });
    }
  }

  void _togglePlayer(String playerId) {
    setState(() {
      if (_selectedPlayers.contains(playerId)) {
        _selectedPlayers.remove(playerId);
      } else {
        _selectedPlayers.add(playerId);
      }
      _markAsChanged();
    });
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return false;
    }

    if (_selectedHost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a host')),
      );
      return false;
    }

    if (_selectedPlayers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 players')),
      );
      return false;
    }

    return true;
  }

  Future<void> _createGame() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final buyinAmount = double.tryParse(_buyinController.text) ?? 0;
      final rebuyAmount = _allowRebuys && _rebuyAmountController.text.isNotEmpty
          ? double.tryParse(_rebuyAmountController.text)
          : null;

      final scheduledDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await PokerService.createGame(
        groupId: _selectedGroupId!,
        locationId: _selectedLocation!,
        hostId: _selectedHost!,
        scheduledAt: scheduledDateTime,
        buyinAmount: buyinAmount,
        allowRebuys: _allowRebuys,
        rebuyAmount: rebuyAmount,
        selectedPlayerIds: _selectedPlayers.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasUnsavedChanges = false;
      });

      // Show success dialog
      await showDialog(
        context: context,
        builder: (context) => _SuccessDialog(
          onViewGame: () {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, '/game-detail');
          },
          onCreateAnother: () {
            Navigator.pop(context);
            _resetForm();
          },
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating game: $e')),
        );
      }
    }
  }

  void _resetForm() {
    setState(() {
      _buyinController.clear();
      _rebuyAmountController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedLocation = null;
      _selectedHost = null;
      _allowRebuys = false;
      _selectedPlayers.clear();
      _advancedOptionsExpanded = false;
      _selectedSeries = null;
      _selectedReminderTime = null;
      _hasUnsavedChanges = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
            'You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Create Game',
          showBackButton: true,
          variant: AppBarVariant.standard,
          actions: [
            AppBarTextAction(
              label: 'Save Template',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Template saved successfully')),
                );
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GameBasicsSection(
                    selectedDate: _selectedDate,
                    selectedTime: _selectedTime,
                    selectedLocation: _selectedLocation,
                    selectedHost: _selectedHost,
                    savedLocations: _savedLocations,
                    groupMembers: _groupMembers,
                    onDateTap: _selectDate,
                    onTimeTap: _selectTime,
                    onLocationTap: _selectLocation,
                    onHostChanged: (value) {
                      setState(() {
                        _selectedHost = value;
                        _markAsChanged();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  BuyinConfigurationSection(
                    buyinController: _buyinController,
                    allowRebuys: _allowRebuys,
                    rebuyAmountController: _rebuyAmountController,
                    onRebuyChanged: (value) {
                      setState(() {
                        _allowRebuys = value ?? false;
                        _markAsChanged();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  PlayerSelectionSection(
                    groupMembers: _groupMembers,
                    selectedPlayers: _selectedPlayers,
                    onPlayerToggle: _togglePlayer,
                  ),
                  const SizedBox(height: 16),
                  AdvancedOptionsSection(
                    isExpanded: _advancedOptionsExpanded,
                    onToggle: () {
                      setState(() =>
                          _advancedOptionsExpanded = !_advancedOptionsExpanded);
                    },
                    selectedSeries: _selectedSeries,
                    selectedRecurrence: null,
                    selectedReminderTime: _selectedReminderTime,
                    notesController: _notesController,
                    onSeriesChanged: (value) {
                      setState(() {
                        _selectedSeries = value;
                        _markAsChanged();
                      });
                    },
                    onRecurrenceChanged: (value) {},
                    onReminderChanged: (value) {
                      setState(() {
                        _selectedReminderTime = value;
                        _markAsChanged();
                      });
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Creating game...',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createGame,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Text(
                _isLoading ? 'Creating...' : 'Create Game',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationSelectorSheet extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final String? selectedLocation;

  const _LocationSelectorSheet({
    required this.locations,
    this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListView.separated(
              shrinkWrap: true,
              itemCount: locations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final location = locations[index];
                final isSelected = selectedLocation == location['name'];

                return ListTile(
                  leading: CustomIconWidget(
                    iconName: 'location_on',
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  title: Text(
                    location['name'] as String,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    location['address'] as String,
                    style: theme.textTheme.bodySmall,
                  ),
                  trailing: isSelected
                      ? CustomIconWidget(
                          iconName: 'check_circle',
                          color: theme.colorScheme.primary,
                          size: 24,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, location['name']),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onViewGame;
  final VoidCallback onCreateAnother;

  const _SuccessDialog({
    required this.onViewGame,
    required this.onCreateAnother,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'check',
              color: theme.colorScheme.primary,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Game Created!',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your poker game has been successfully created and players have been notified.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCreateAnother,
          child: const Text('Create Another'),
        ),
        ElevatedButton(
          onPressed: onViewGame,
          child: const Text('View Game'),
        ),
      ],
    );
  }
}
