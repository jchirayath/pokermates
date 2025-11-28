import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/group_card_widget.dart';

/// Groups Dashboard - Primary hub for poker group management
/// Displays user's poker groups in vertical scrolling card layout
/// Implements bottom tab navigation with Groups, Games, Stats, Profile tabs
class GroupsDashboard extends StatefulWidget {
  const GroupsDashboard({super.key});

  @override
  State<GroupsDashboard> createState() => _GroupsDashboardState();
}

class _GroupsDashboardState extends State<GroupsDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isRefreshing = false;

  // Mock data for poker groups
  final List<Map<String, dynamic>> _allGroups = [
    {
      "id": 1,
      "name": "Friday Night Poker",
      "memberCount": 8,
      "memberAvatars": [
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_13a65a919-1763293485191.png",
          "semanticLabel":
              "Profile photo of a man with short brown hair wearing a casual shirt"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_19df3b9f3-1763299821151.png",
          "semanticLabel":
              "Profile photo of a woman with long blonde hair smiling"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_13f4b3d4d-1763295780084.png",
          "semanticLabel": "Profile photo of a man with glasses and dark hair"
        },
      ],
      "nextGame": DateTime.now().add(const Duration(days: 2)),
      "hasNotification": true,
      "recentActivity": "New game scheduled",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      "id": 2,
      "name": "Weekend Warriors",
      "memberCount": 12,
      "memberAvatars": [
        {
          "url":
              "https://images.unsplash.com/photo-1695309972118-9fe68f1728b7",
          "semanticLabel": "Profile photo of a woman with curly red hair"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1186909d6-1763293633420.png",
          "semanticLabel": "Profile photo of a man with a beard and cap"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1ee2bcef3-1763301295581.png",
          "semanticLabel": "Profile photo of a woman with short dark hair"
        },
      ],
      "nextGame": DateTime.now().add(const Duration(days: 5)),
      "hasNotification": false,
      "recentActivity": "Payment received",
      "lastUpdated": DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      "id": 3,
      "name": "High Rollers Club",
      "memberCount": 6,
      "memberAvatars": [
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1f2746db7-1763296313857.png",
          "semanticLabel":
              "Profile photo of a man in a suit with slicked back hair"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_176e07230-1763293461602.png",
          "semanticLabel": "Profile photo of a woman with elegant styling"
        },
      ],
      "nextGame": DateTime.now().add(const Duration(days: 7)),
      "hasNotification": true,
      "recentActivity": "Pending invitation",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 12)),
    },
    {
      "id": 4,
      "name": "Casual Tuesday Games",
      "memberCount": 10,
      "memberAvatars": [
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1e6d09531-1763299977907.png",
          "semanticLabel": "Profile photo of a young man with casual attire"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1b1395d19-1763301528319.png",
          "semanticLabel": "Profile photo of a woman with glasses"
        },
        {
          "url":
              "https://img.rocket.new/generatedImages/rocket_gen_img_1fccc499d-1763294878077.png",
          "semanticLabel": "Profile photo of a man with a friendly smile"
        },
      ],
      "nextGame": DateTime.now().add(const Duration(days: 3)),
      "hasNotification": false,
      "recentActivity": "Stats updated",
      "lastUpdated": DateTime.now().subtract(const Duration(hours: 6)),
    },
  ];

  List<Map<String, dynamic>> get _filteredGroups {
    if (_searchQuery.isEmpty) {
      return _allGroups;
    }
    return _allGroups
        .where((group) => (group["name"] as String)
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);

    // Simulate network sync with haptic feedback
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Groups synced successfully'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleSearch(String query) {
    setState(() => _searchQuery = query);
  }

  void _handleGroupTap(Map<String, dynamic> group) {
    Navigator.pushNamed(
      context,
      '/group-detail',
      arguments: group,
    );
  }

  void _handleCreateGroup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCreateGroupSheet(),
    );
  }

  Widget _buildCreateGroupSheet() {
    final theme = Theme.of(context);

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Create New Group',
              style: theme.textTheme.headlineSmall,
            ),
            SizedBox(height: 3.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Group Name',
                hintText: 'Enter group name',
                prefixIcon: CustomIconWidget(
                  iconName: 'group',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter group description',
                prefixIcon: CustomIconWidget(
                  iconName: 'description',
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Group created successfully'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                child: const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My Groups',
        variant: AppBarVariant.standard,
        actions: [
          AppBarAction(
            icon: Icons.notifications_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _handleSearch,
              decoration: InputDecoration(
                hintText: 'Search groups...',
                prefixIcon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.5.h,
                ),
              ),
            ),
          ),

          // Groups list
          Expanded(
            child: _filteredGroups.isEmpty
                ? EmptyStateWidget(
                    onCreateGroup: _handleCreateGroup,
                  )
                : RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: _filteredGroups.length,
                      itemBuilder: (context, index) {
                        final group = _filteredGroups[index];
                        return GroupCardWidget(
                          group: group,
                          onTap: () => _handleGroupTap(group),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreateGroup,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: const Text('Create Group'),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation through parent widget
        },
        variant: BottomBarVariant.standard,
      ),
    );
  }
}
