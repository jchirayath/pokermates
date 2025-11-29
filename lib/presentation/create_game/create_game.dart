import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/poker_service.dart';
import './widgets/game_basics_section.dart';
import './widgets/player_selection_section.dart';
import './widgets/buyin_configuration_section.dart';
import './widgets/advanced_options_section.dart';

/// Create Game Screen - Multi-step form for scheduling poker games
class CreateGame extends StatefulWidget {
  const CreateGame({super.key});

  @override
  State<CreateGame> createState() => _CreateGameState();
}

class _CreateGameState extends State<CreateGame> {
  final _formKey = GlobalKey<FormState>();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingGroups = true;
  bool _isLoadingLocations = true;
  bool _isLoadingMembers = false;

  // Form data
  String? _selectedGroupId;
  String? _selectedLocationId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0);
  double _buyinAmount = 50.0;
  bool _allowRebuys = false;
  double _rebuyAmount = 50.0;
  String _notes = '';
  List<String> _selectedPlayerIds = [];
  bool _isAdvancedExpanded = false;

  // Data from Supabase
  List<Map<String, dynamic>> _groups = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _availablePlayers = [];

  // Add controllers for text fields
  final TextEditingController _buyinController = TextEditingController(
    text: '50.0',
  );
  final TextEditingController _rebuyController = TextEditingController(
    text: '50.0',
  );
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadGroups(), _loadLocations()]);
  }

  Future<void> _loadGroups() async {
    setState(() => _isLoadingGroups = true);
    try {
      final groups = await PokerService.fetchUserGroups();
      setState(() {
        _groups = groups;
        _isLoadingGroups = false;
      });
    } catch (e) {
      setState(() => _isLoadingGroups = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading groups: $e')));
      }
    }
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoadingLocations = true);
    try {
      final locations = await PokerService.fetchUserLocations();
      setState(() {
        _locations = locations;
        _isLoadingLocations = false;
      });
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading locations: $e')));
      }
    }
  }

  Future<void> _loadGroupMembers(String groupId) async {
    setState(() => _isLoadingMembers = true);
    try {
      final members = await PokerService.fetchGroupMembers(groupId);
      setState(() {
        _availablePlayers = members;
        _isLoadingMembers = false;
      });
    } catch (e) {
      setState(() => _isLoadingMembers = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
      }
    }
  }

  void _onGroupChanged(String? groupId) {
    setState(() {
      _selectedGroupId = groupId;
      _selectedPlayerIds.clear();
      _availablePlayers.clear();
    });

    if (groupId != null) {
      _loadGroupMembers(groupId);
    }
  }

  void _onLocationChanged(String? locationId) {
    setState(() => _selectedLocationId = locationId);
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
  }

  void _onTimeChanged(TimeOfDay time) {
    setState(() => _selectedTime = time);
  }

  void _onBuyinChanged(double amount) {
    setState(() => _buyinAmount = amount);
  }

  void _onAllowRebuysChanged(bool value) {
    setState(() => _allowRebuys = value);
  }

  void _onRebuyAmountChanged(double amount) {
    setState(() => _rebuyAmount = amount);
  }

  void _onNotesChanged(String notes) {
    setState(() => _notes = notes);
  }

  void _onPlayerSelectionChanged(List<String> playerIds) {
    setState(() => _selectedPlayerIds = playerIds);
  }

  Future<void> _createGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGroupId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a group')));
      return;
    }

    if (_selectedLocationId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a location')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await PokerService.createGame(
        groupId: _selectedGroupId!,
        locationId: _selectedLocationId!,
        hostId: PokerService.getCurrentUserId(),
        scheduledAt: scheduledAt,
        buyinAmount: _buyinAmount,
        allowRebuys: _allowRebuys,
        rebuyAmount: _allowRebuys ? _rebuyAmount : null,
        selectedPlayerIds: _selectedPlayerIds,
        notes: _notes.trim().isEmpty ? null : _notes.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Game created successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating game: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create New Game',
        variant: AppBarVariant.standard,
      ),
      body:
          _isLoadingGroups || _isLoadingLocations
              ? const Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GameBasicsSection(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        selectedLocation: _selectedLocationId,
                        selectedHost: null,
                        savedLocations: _locations,
                        groupMembers: _availablePlayers,
                        onDateTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) _onDateChanged(date);
                        },
                        onTimeTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) _onTimeChanged(time);
                        },
                        onLocationTap: () {},
                        onHostChanged: (String? hostId) {},
                      ),
                      SizedBox(height: 3.h),
                      BuyinConfigurationSection(
                        buyinController: _buyinController,
                        allowRebuys: _allowRebuys,
                        rebuyAmountController: _rebuyController,
                        onRebuyChanged: (bool? value) {
                          if (value != null) _onAllowRebuysChanged(value);
                        },
                      ),
                      SizedBox(height: 3.h),
                      if (_selectedGroupId != null && !_isLoadingMembers) ...[
                        PlayerSelectionSection(
                          groupMembers: _availablePlayers,
                          selectedPlayers: _selectedPlayerIds.toSet(),
                          onPlayerToggle: (String playerId) {
                            setState(() {
                              if (_selectedPlayerIds.contains(playerId)) {
                                _selectedPlayerIds.remove(playerId);
                              } else {
                                _selectedPlayerIds.add(playerId);
                              }
                            });
                          },
                        ),
                        SizedBox(height: 3.h),
                      ],
                      if (_isLoadingMembers) ...[
                        const Center(child: CircularProgressIndicator()),
                        SizedBox(height: 3.h),
                      ],
                      AdvancedOptionsSection(
                        isExpanded: _isAdvancedExpanded,
                        onToggle: () {
                          setState(
                            () => _isAdvancedExpanded = !_isAdvancedExpanded,
                          );
                        },
                        selectedSeries: null,
                        selectedRecurrence: null,
                        selectedReminderTime: null,
                        notesController: _notesController,
                        onSeriesChanged: (String? value) {},
                        onRecurrenceChanged: (String? value) {},
                        onReminderChanged: (String? value) {},
                      ),
                      SizedBox(height: 4.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createGame,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                          child:
                              _isLoading
                                  ? SizedBox(
                                    height: 2.h,
                                    width: 2.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'check',
                                        color: theme.colorScheme.onPrimary,
                                        size: 24,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Create Game',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                      ),
                                    ],
                                  ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
    );
  }
}
