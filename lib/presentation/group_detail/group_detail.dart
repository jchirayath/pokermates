import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/game_card_widget.dart';
import './widgets/member_card_widget.dart';
import './widgets/settings_section_widget.dart';

/// Group Detail Screen - Comprehensive poker group management
/// Provides tabbed interface for members, games, and settings management
class GroupDetail extends StatefulWidget {
  const GroupDetail({super.key});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAdmin = true; // Mock admin status
  bool _isLoading = false;

  // Mock group data
  final Map<String, dynamic> _groupData = {
    "id": 1,
    "name": "Friday Night Poker",
    "memberCount": 8,
    "createdDate": "2024-03-15",
    "description": "Weekly poker games with friends",
  };

  // Mock members data
  final List<Map<String, dynamic>> _members = [
    {
      "id": 1,
      "name": "John Smith",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_119edae7e-1763296718356.png",
      "semanticLabel":
          "Professional headshot of a man with short brown hair wearing a blue shirt",
      "joinDate": "2024-03-15",
      "isAdmin": true,
      "totalGames": 24,
      "totalWinnings": "\$1,250"
    },
    {
      "id": 2,
      "name": "Sarah Johnson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_18fea03cd-1763298755013.png",
      "semanticLabel":
          "Professional headshot of a woman with long dark hair wearing a white blouse",
      "joinDate": "2024-03-20",
      "isAdmin": false,
      "totalGames": 18,
      "totalWinnings": "\$850"
    },
    {
      "id": 3,
      "name": "Michael Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1a9bc19f1-1763292173746.png",
      "semanticLabel":
          "Professional headshot of a man with short black hair wearing a gray suit",
      "joinDate": "2024-04-01",
      "isAdmin": false,
      "totalGames": 15,
      "totalWinnings": "\$620"
    },
    {
      "id": 4,
      "name": "Emily Davis",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_12a5f64ae-1763295538130.png",
      "semanticLabel":
          "Professional headshot of a woman with blonde hair wearing a black top",
      "joinDate": "2024-04-10",
      "isAdmin": false,
      "totalGames": 12,
      "totalWinnings": "\$480"
    },
  ];

  // Mock games data
  final List<Map<String, dynamic>> _games = [
    {
      "id": 1,
      "date": "2024-11-22",
      "location": "John's House",
      "buyIn": "\$50",
      "players": 6,
      "totalPot": "\$300",
      "winner": "Sarah Johnson",
      "status": "completed"
    },
    {
      "id": 2,
      "date": "2024-11-15",
      "location": "Mike's Apartment",
      "buyIn": "\$50",
      "players": 7,
      "totalPot": "\$350",
      "winner": "John Smith",
      "status": "completed"
    },
    {
      "id": 3,
      "date": "2024-11-08",
      "location": "Community Center",
      "buyIn": "\$50",
      "players": 8,
      "totalPot": "\$400",
      "winner": "Michael Chen",
      "status": "completed"
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _isAdmin ? 3 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: _groupData["name"] as String,
        showBackButton: true,
        actions: [
          if (_isAdmin)
            AppBarAction(
              icon: Icons.edit,
              onPressed: _editGroupDetails,
              tooltip: 'Edit Group',
            ),
          AppBarAction(
            icon: Icons.more_vert,
            onPressed: _showGroupOptions,
            tooltip: 'More Options',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildGroupHeader(theme),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(theme),
                _buildGamesTab(theme),
                if (_isAdmin) _buildSettingsTab(theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _addMember,
              icon: CustomIconWidget(
                iconName: 'person_add',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              label: Text(
                'Add Member',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            )
          : _tabController.index == 1
              ? FloatingActionButton.extended(
                  onPressed: _createGame,
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  label: Text(
                    'New Game',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildGroupHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_groupData["memberCount"]} Members',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Created ${_formatDate(_groupData["createdDate"] as String)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'casino',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                SizedBox(width: 1.w),
                Text(
                  '${_games.length} Games',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'people',
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Members'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'casino',
                  size: 20,
                ),
                SizedBox(width: 1.w),
                Text('Games'),
              ],
            ),
          ),
          if (_isAdmin)
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'settings',
                    size: 20,
                  ),
                  SizedBox(width: 1.w),
                  Text('Settings'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMembersTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshMembers,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 1.h),
              itemCount: _members.length,
              itemBuilder: (context, index) {
                return MemberCardWidget(
                  member: _members[index],
                  isAdmin: _isAdmin,
                  onRemove: () => _removeMember(_members[index]),
                  onMakeAdmin: () => _makeAdmin(_members[index]),
                  onViewStats: () => _viewMemberStats(_members[index]),
                );
              },
            ),
    );
  }

  Widget _buildGamesTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshGames,
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : _games.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'casino',
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No games yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Create your first game to get started',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 1.h),
                  itemCount: _games.length,
                  itemBuilder: (context, index) {
                    return GameCardWidget(
                      game: _games[index],
                      isAdmin: _isAdmin,
                      onEdit: () => _editGame(_games[index]),
                      onDuplicate: () => _duplicateGame(_games[index]),
                      onDelete: () => _deleteGame(_games[index]),
                      onTap: () => _viewGameDetails(_games[index]),
                    );
                  },
                ),
    );
  }

  Widget _buildSettingsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: SettingsSectionWidget(
        groupId: _groupData["id"] as int,
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 30) {
      return '$difference days ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  Future<void> _refreshMembers() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _refreshGames() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _editGroupDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Group'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
              ),
              controller:
                  TextEditingController(text: _groupData["name"] as String),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
              ),
              maxLines: 3,
              controller: TextEditingController(
                  text: _groupData["description"] as String),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGroupOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Share Group'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share functionality')),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'archive',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                title: const Text('Archive Group'),
                onTap: () {
                  Navigator.pop(context);
                  _showArchiveConfirmation();
                },
              ),
              if (_isAdmin)
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'delete',
                    color: theme.colorScheme.error,
                    size: 24,
                  ),
                  title: Text(
                    'Delete Group',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showArchiveConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Group'),
        content: const Text(
            'Are you sure you want to archive this group? You can restore it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group archived successfully')),
              );
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
            'Are you sure you want to delete this group? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Member',
                  style: theme.textTheme.titleLarge,
                ),
                SizedBox(height: 2.h),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter member name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Member added successfully')),
                          );
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _removeMember(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
            'Are you sure you want to remove ${member["name"]} from the group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _members.remove(member);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member["name"]} removed from group')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _makeAdmin(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Admin'),
        content: Text(
            'Are you sure you want to make ${member["name"]} an admin? They will have full control over the group.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                member["isAdmin"] = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${member["name"]} is now an admin')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _viewMemberStats(Map<String, dynamic> member) {
    Navigator.pushNamed(context, '/player-stats', arguments: member);
  }

  void _createGame() {
    Navigator.pushNamed(context, '/create-game',
        arguments: {"groupId": _groupData["id"]});
  }

  void _editGame(Map<String, dynamic> game) {
    Navigator.pushNamed(context, '/create-game', arguments: {
      "groupId": _groupData["id"],
      "gameId": game["id"],
      "isEdit": true
    });
  }

  void _duplicateGame(Map<String, dynamic> game) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game duplicated successfully')),
    );
  }

  void _deleteGame(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text(
            'Are you sure you want to delete this game? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _games.remove(game);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewGameDetails(Map<String, dynamic> game) {
    Navigator.pushNamed(context, '/game-detail', arguments: game);
  }
}
