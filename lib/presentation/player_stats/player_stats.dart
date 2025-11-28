import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/date_range_picker_widget.dart';
import './widgets/games_tab_widget.dart';
import './widgets/performance_tab_widget.dart';
import './widgets/player_selector_widget.dart';
import './widgets/profit_loss_graph_widget.dart';
import './widgets/rankings_tab_widget.dart';
import './widgets/stats_card_grid_widget.dart';

class PlayerStats extends StatefulWidget {
  const PlayerStats({super.key});

  @override
  State<PlayerStats> createState() => _PlayerStatsState();
}

class _PlayerStatsState extends State<PlayerStats>
    with SingleTickerProviderStateMixin {
  int _currentBottomNavIndex = 2; // Stats tab active
  int _currentTabIndex = 0; // Performance tab default
  late TabController _tabController;
  String _selectedPlayer = 'John Smith';
  String _selectedDateRange = 'All Time';
  String _selectedGraphPeriod = 'All Time';
  bool _isRefreshing = false;
  DateTime _lastSyncTime = DateTime.now();

  // Mock player list
  final List<String> _players = [
    'John Smith',
    'Michael Chen',
    'Sarah Johnson',
    'David Rodriguez',
    'Emily Williams',
  ];

  // Mock date ranges
  final List<String> _dateRanges = [
    'Last 30 Days',
    'Last 6 Months',
    'Last Year',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastSyncTime = DateTime.now();
    });
  }

  void _handlePlayerChange(String? newPlayer) {
    if (newPlayer != null) {
      setState(() {
        _selectedPlayer = newPlayer;
      });
    }
  }

  void _handleDateRangeChange(String? newRange) {
    if (newRange != null) {
      setState(() {
        _selectedDateRange = newRange;
      });
    }
  }

  void _handleGraphPeriodChange(String newPeriod) {
    setState(() {
      _selectedGraphPeriod = newPeriod;
    });
  }

  void _handleExportReport() {
    // Show export dialog
    showDialog(
      context: context,
      builder: (context) => _buildExportDialog(context),
    );
  }

  Widget _buildExportDialog(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        'Export Annual Report',
        style: theme.textTheme.titleLarge,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate a comprehensive annual report for $_selectedPlayer?',
            style: theme.textTheme.bodyMedium,
          ),
          SizedBox(height: 2.h),
          Text(
            'Report will include:',
            style: theme.textTheme.titleSmall,
          ),
          SizedBox(height: 1.h),
          _buildReportItem(theme, 'Total games played and win rate'),
          _buildReportItem(theme, 'Net profit/loss analysis'),
          _buildReportItem(theme, 'Performance trends and graphs'),
          _buildReportItem(theme, 'Rankings and achievements'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report generated successfully'),
                action: SnackBarAction(
                  label: 'Share',
                  onPressed: () {},
                ),
              ),
            );
          },
          child: Text('Generate'),
        ),
      ],
    );
  }

  Widget _buildReportItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: theme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Player Stats',
        variant: AppBarVariant.standard,
        actions: [
          AppBarAction(
            icon: Icons.file_download_outlined,
            onPressed: _handleExportReport,
            tooltip: 'Export Report',
          ),
          AppBarAction(
            icon: Icons.search,
            onPressed: () {
              // Navigate to search/filter screen
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            // Player selector and date range picker
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.surface,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Column(
                  children: [
                    PlayerSelectorWidget(
                      selectedPlayer: _selectedPlayer,
                      players: _players,
                      onPlayerChanged: _handlePlayerChange,
                    ),
                    SizedBox(height: 2.h),
                    DateRangePickerWidget(
                      selectedRange: _selectedDateRange,
                      dateRanges: _dateRanges,
                      onRangeChanged: _handleDateRangeChange,
                    ),
                  ],
                ),
              ),
            ),

            // Last sync indicator
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'sync',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Last updated: ${_formatLastSync()}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats cards grid
            SliverToBoxAdapter(
              child: StatsCardGridWidget(
                selectedPlayer: _selectedPlayer,
                dateRange: _selectedDateRange,
              ),
            ),

            // Profit/Loss graph
            SliverToBoxAdapter(
              child: ProfitLossGraphWidget(
                selectedPlayer: _selectedPlayer,
                selectedPeriod: _selectedGraphPeriod,
                onPeriodChanged: _handleGraphPeriodChange,
              ),
            ),

            // Tab bar
            SliverToBoxAdapter(
              child: Container(
                color: theme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Performance'),
                    Tab(text: 'Games'),
                    Tab(text: 'Rankings'),
                  ],
                ),
              ),
            ),

            // Tab content
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  PerformanceTabWidget(
                    selectedPlayer: _selectedPlayer,
                    dateRange: _selectedDateRange,
                  ),
                  GamesTabWidget(
                    selectedPlayer: _selectedPlayer,
                    dateRange: _selectedDateRange,
                  ),
                  RankingsTabWidget(
                    selectedPlayer: _selectedPlayer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
        variant: BottomBarVariant.standard,
      ),
    );
  }

  String _formatLastSync() {
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
