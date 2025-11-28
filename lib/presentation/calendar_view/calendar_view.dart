import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
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

  // Mock data for games
  final List<Map<String, dynamic>> _allGames = [
    {
      'id': 1,
      'title': 'Friday Night Poker',
      'date': DateTime.now().add(const Duration(days: 2, hours: 19)),
      'location': 'Mike\'s Place, 123 Oak Street',
      'host': 'Mike Johnson',
      'confirmedPlayers': 8,
      'isRSVPed': true,
      'group': 'Downtown Crew',
      'type': 'Texas Hold\'em',
      'description':
          'Weekly Friday night game with \$50 buy-in. Bring your A-game!',
    },
    {
      'id': 2,
      'title': 'Weekend Tournament',
      'date': DateTime.now().add(const Duration(days: 5, hours: 14)),
      'location': 'Community Center, 456 Maple Ave',
      'host': 'Sarah Williams',
      'confirmedPlayers': 12,
      'isRSVPed': false,
      'group': 'Weekend Warriors',
      'type': 'Tournament',
      'description':
          'Monthly tournament with \$100 buy-in and guaranteed prize pool.',
    },
    {
      'id': 3,
      'title': 'Casual Home Game',
      'date': DateTime.now().add(const Duration(days: 7, hours: 18)),
      'location': 'Tom\'s House, 789 Pine Road',
      'host': 'Tom Anderson',
      'confirmedPlayers': 6,
      'isRSVPed': true,
      'group': 'Downtown Crew',
      'type': 'Cash Game',
      'description':
          'Friendly cash game, \$20 buy-in. Pizza and drinks provided!',
    },
    {
      'id': 4,
      'title': 'High Stakes Night',
      'date': DateTime.now().add(const Duration(days: 10, hours: 20)),
      'location': 'Private Club, 321 Cedar Lane',
      'host': 'David Chen',
      'confirmedPlayers': 10,
      'isRSVPed': false,
      'group': 'High Rollers',
      'type': 'Texas Hold\'em',
      'description':
          'High stakes game for experienced players. \$500 minimum buy-in.',
    },
    {
      'id': 5,
      'title': 'Monthly Championship',
      'date': DateTime.now().add(const Duration(days: 15, hours: 15)),
      'location': 'Grand Hotel, 555 Main Street',
      'host': 'Lisa Martinez',
      'confirmedPlayers': 20,
      'isRSVPed': true,
      'group': 'Weekend Warriors',
      'type': 'Tournament',
      'description':
          'Monthly championship series. \$200 buy-in with rebuys allowed.',
    },
  ];

  final List<String> _availableGroups = [
    'Downtown Crew',
    'Weekend Warriors',
    'High Rollers',
  ];

  final List<String> _availableGameTypes = [
    'Texas Hold\'em',
    'Tournament',
    'Cash Game',
  ];

  Map<DateTime, List<Map<String, dynamic>>> _gamesByDate = {};
  List<Map<String, dynamic>> _filteredGames = [];

  @override
  void initState() {
    super.initState();
    _initializeGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeGames() {
    _filteredGames = List.from(_allGames);
    _organizeGamesByDate();
  }

  void _organizeGamesByDate() {
    _gamesByDate = {};
    for (var game in _filteredGames) {
      final date = game['date'] as DateTime;
      final normalizedDate = DateTime(date.year, date.month, date.day);

      if (_gamesByDate[normalizedDate] == null) {
        _gamesByDate[normalizedDate] = [];
      }
      _gamesByDate[normalizedDate]!.add(game);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredGames = _allGames.where((game) {
        bool matchesGroup =
            _selectedGroup == null || game['group'] == _selectedGroup;
        bool matchesType =
            _selectedGameType == null || game['type'] == _selectedGameType;
        bool matchesSearch = _searchController.text.isEmpty ||
            (game['title'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (game['location'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            (game['host'] as String)
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());

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
      _applyFilters();
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    final normalizedDay =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
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
      builder: (context) => GameDetailBottomSheet(
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

  void _toggleRSVP(Map<String, dynamic> game) {
    setState(() {
      final gameIndex = _allGames.indexWhere((g) => g['id'] == game['id']);
      if (gameIndex != -1) {
        _allGames[gameIndex]['isRSVPed'] =
            !(game['isRSVPed'] as bool? ?? false);
        _applyFilters();
      }
    });

    final isRSVPed = game['isRSVPed'] as bool? ?? false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isRSVPed ? 'RSVP cancelled' : 'RSVP confirmed'),
        duration: const Duration(seconds: 2),
      ),
    );
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
            onChanged: (_) => _applyFilters(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _searchController.clear();
                _applyFilters();
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
    final upcomingGames = _filteredGames
        .where((game) => (game['date'] as DateTime).isAfter(DateTime.now()))
        .toList()
      ..sort(
          (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
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
      body: SingleChildScrollView(
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
                  _applyFilters();
                });
              },
              onGameTypeChanged: (value) {
                setState(() {
                  _selectedGameType = value;
                  _applyFilters();
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
              onGameTap: (game) => Navigator.pushNamed(
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
