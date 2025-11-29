import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/poker_service.dart';
import './widgets/calendar_widget.dart';
import './widgets/filter_controls_widget.dart';
import './widgets/game_detail_bottom_sheet.dart';
import './widgets/upcoming_games_list_widget.dart';

/// Calendar View Screen for poker game scheduling
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? _selectedGroup;
  String? _selectedGameType;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _allGames = [];
  List<String> _availableGroups = [];
  Map<DateTime, List<Map<String, dynamic>>> _gamesByDate = {};
  List<Map<String, dynamic>> _filteredGames = [];
  String? _error;

  final List<String> _availableGameTypes = [
    'scheduled',
    'in_progress',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGames() async {
    try {
      setState(() => _isLoading = true);

      final games = await PokerService.fetchAllUserGames();

      setState(() {
        _allGames = games;
        _filterGames();
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      debugPrint('Error loading games: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _allGames = []; // Ensure empty list on error
        _filteredGames = [];
      });
    }
  }

  void _organizeGamesByDate() {
    _gamesByDate = {};
    for (var game in _filteredGames) {
      final date = DateTime.parse(game['scheduled_at'] as String);
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (_gamesByDate[normalizedDate] == null) {
        _gamesByDate[normalizedDate] = [];
      }
      _gamesByDate[normalizedDate]!.add(game);
    }
  }

  void _filterGames() {
    setState(() {
      _filteredGames =
          _allGames.where((game) {
            final groupName = game['poker_groups']?['name'] as String? ?? '';
            final status = game['status'] as String? ?? '';
            final hostName =
                game['user_profiles']?['full_name'] as String? ?? '';
            final locationName =
                game['saved_locations']?['name'] as String? ?? '';

            bool matchesGroup =
                _selectedGroup == null || groupName == _selectedGroup;
            bool matchesType =
                _selectedGameType == null || status == _selectedGameType;
            bool matchesSearch =
                _searchController.text.isEmpty ||
                locationName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                hostName.toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

            return matchesGroup && matchesType && matchesSearch;
          }).toList();

      _organizeGamesByDate();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedGroup = null;
      _selectedGameType = null;
      _searchController.clear();
      _filterGames();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final normalizedDay = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
    );
    final gamesOnDay = _gamesByDate[normalizedDay];

    if (gamesOnDay != null && gamesOnDay.isNotEmpty) {
      _showGameDetailsBottomSheet(gamesOnDay.first);
    }
  }

  void _showGameDetailsBottomSheet(Map<String, dynamic> game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => GameDetailBottomSheet(
            game: game,
            onViewDetails: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/game-detail', arguments: game);
            },
            onRSVP: () {
              Navigator.pop(context);
              _toggleRSVP(game);
            },
            onShare: () {
              Navigator.pop(context);
              _shareGame(game);
            },
            onSetReminder: () {
              Navigator.pop(context);
              _setReminder(game);
            },
          ),
    );
  }

  Future<void> _toggleRSVP(Map<String, dynamic> game) async {
    try {
      final participants = game['game_participants'] as List<dynamic>? ?? [];
      final currentConfirmed =
          participants.isNotEmpty
              ? (participants.first['is_confirmed'] as bool? ?? false)
              : false;

      await PokerService.toggleGameRSVP(
        gameId: game['id'] as String,
        isConfirmed: !currentConfirmed,
      );

      await _loadGames();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentConfirmed ? 'RSVP cancelled' : 'RSVP confirmed',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating RSVP: $e')));
      }
    }
  }

  void _shareGame(Map<String, dynamic> game) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game details shared via WhatsApp'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _setReminder(Map<String, dynamic> game) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reminder set for this game'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Search Games', style: theme.textTheme.titleLarge),
          content: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by location, host, or player',
              prefixIcon: CustomIconWidget(
                iconName: 'search',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            onChanged: (_) => _filterGames(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterGames();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcomingGames =
        _filteredGames.where((game) {
            final scheduledAt = DateTime.parse(game['scheduled_at'] as String);
            return scheduledAt.isAfter(DateTime.now());
          }).toList()
          ..sort(
            (a, b) => DateTime.parse(
              a['scheduled_at'] as String,
            ).compareTo(DateTime.parse(b['scheduled_at'] as String)),
          );
    final nextFiveGames = upcomingGames.take(5).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Game Calendar',
        variant: AppBarVariant.standard,
        actions: [
          AppBarAction(
            icon: Icons.search,
            onPressed: _showSearchDialog,
            tooltip: 'Search games',
          ),
          AppBarAction(
            icon: Icons.today,
            onPressed: _navigateToToday,
            tooltip: 'Go to today',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    FilterControlsWidget(
                      selectedGroup: _selectedGroup,
                      selectedGameType: _selectedGameType,
                      availableGroups: _availableGroups,
                      availableGameTypes: _availableGameTypes,
                      onGroupChanged: (value) {
                        setState(() {
                          _selectedGroup = value;
                          _filterGames();
                        });
                      },
                      onGameTypeChanged: (value) {
                        setState(() {
                          _selectedGameType = value;
                          _filterGames();
                        });
                      },
                      onClearFilters: _clearFilters,
                    ),
                    CalendarWidget(
                      focusedDay: _focusedDay,
                      selectedDay: _selectedDay,
                      gamesByDate: _gamesByDate,
                      onDaySelected: _onDaySelected,
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                    SizedBox(height: 2.h),
                    UpcomingGamesListWidget(
                      upcomingGames: nextFiveGames,
                      onGameTap:
                          (game) => Navigator.pushNamed(
                            context,
                            '/game-detail',
                            arguments: game,
                          ),
                      onRSVPToggle: _toggleRSVP,
                      onShareGame: _shareGame,
                      onSetReminder: _setReminder,
                    ),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-game'),
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: const Text('New Game'),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          // Navigation handled by CustomBottomBar
        },
        variant: BottomBarVariant.standard,
      ),
    );
  }
}