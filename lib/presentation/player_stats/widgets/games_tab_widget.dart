import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class GamesTabWidget extends StatefulWidget {
  final String selectedPlayer;
  final String dateRange;

  const GamesTabWidget({
    super.key,
    required this.selectedPlayer,
    required this.dateRange,
  });

  @override
  State<GamesTabWidget> createState() => _GamesTabWidgetState();
}

class _GamesTabWidgetState extends State<GamesTabWidget> {
  final Set<int> _expandedGames = {};

  // Mock games data
  List<Map<String, dynamic>> _getGamesData() {
    return [
      {
        'id': 1,
        'date': '2025-11-25',
        'location': 'Mike\'s House',
        'buyIn': 150.00,
        'cashOut': 425.00,
        'profit': 275.00,
        'duration': '4h 30m',
        'players': 8,
        'notes': 'Great session! Hit a full house on the river.',
      },
      {
        'id': 2,
        'date': '2025-11-18',
        'location': 'Downtown Casino',
        'buyIn': 200.00,
        'cashOut': 180.00,
        'profit': -20.00,
        'duration': '3h 15m',
        'players': 9,
        'notes': 'Tough table, played conservative.',
      },
      {
        'id': 3,
        'date': '2025-11-11',
        'location': 'Sarah\'s Apartment',
        'buyIn': 100.00,
        'cashOut': 350.00,
        'profit': 250.00,
        'duration': '5h 00m',
        'players': 6,
        'notes': 'Best night this month! Multiple big pots.',
      },
      {
        'id': 4,
        'date': '2025-11-04',
        'location': 'Mike\'s House',
        'buyIn': 150.00,
        'cashOut': 125.00,
        'profit': -25.00,
        'duration': '3h 45m',
        'players': 7,
        'notes': 'Bad beats early, couldn\'t recover.',
      },
      {
        'id': 5,
        'date': '2025-10-28',
        'location': 'Downtown Casino',
        'buyIn': 200.00,
        'cashOut': 520.00,
        'profit': 320.00,
        'duration': '6h 20m',
        'players': 10,
        'notes': 'Tournament style, finished 2nd place.',
      },
    ];
  }

  void _toggleExpanded(int gameId) {
    setState(() {
      _expandedGames.contains(gameId)
          ? _expandedGames.remove(gameId)
          : _expandedGames.add(gameId);
    });
  }

  void _handleViewDetail(int gameId) {
    Navigator.pushNamed(context, '/game-detail');
  }

  void _handleAddNote(int gameId) {
    showDialog(
      context: context,
      builder: (context) => _buildAddNoteDialog(context, gameId),
    );
  }

  void _handleShareResult(int gameId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game result shared successfully'),
      ),
    );
  }

  Widget _buildAddNoteDialog(BuildContext context, int gameId) {
    final theme = Theme.of(context);
    final noteController = TextEditingController();

    return AlertDialog(
      title: Text('Add Note', style: theme.textTheme.titleLarge),
      content: TextField(
        controller: noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Enter your notes about this game...',
        ),
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
              const SnackBar(content: Text('Note added successfully')),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gamesData = _getGamesData();

    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: gamesData.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final game = gamesData[index];
        final isExpanded = _expandedGames.contains(game['id']);
        final isProfit = (game['profit'] as double) >= 0;

        return Slidable(
          key: ValueKey(game['id']),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => _handleViewDetail(game['id']),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                icon: Icons.visibility,
                label: 'View',
              ),
              SlidableAction(
                onPressed: (context) => _handleAddNote(game['id']),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                icon: Icons.note_add,
                label: 'Note',
              ),
              SlidableAction(
                onPressed: (context) => _handleShareResult(game['id']),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.share,
                label: 'Share',
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () => _toggleExpanded(game['id']),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: isProfit
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName:
                                    isProfit ? 'trending_up' : 'trending_down',
                                color: isProfit ? Colors.green : Colors.red,
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game['date'],
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'location_on',
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 14,
                                      ),
                                      SizedBox(width: 1.w),
                                      Expanded(
                                        child: Text(
                                          game['location'],
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isProfit ? '+' : ''}\$${game['profit'].toStringAsFixed(0)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: isProfit ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                CustomIconWidget(
                                  iconName: isExpanded
                                      ? 'expand_less'
                                      : 'expand_more',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          SizedBox(height: 2.h),
                          Divider(color: theme.colorScheme.outline),
                          SizedBox(height: 2.h),
                          _buildDetailRow(
                            theme,
                            'Buy-In',
                            '\$${game['buyIn'].toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 1.h),
                          _buildDetailRow(
                            theme,
                            'Cash-Out',
                            '\$${game['cashOut'].toStringAsFixed(2)}',
                          ),
                          SizedBox(height: 1.h),
                          _buildDetailRow(
                            theme,
                            'Duration',
                            game['duration'],
                          ),
                          SizedBox(height: 1.h),
                          _buildDetailRow(
                            theme,
                            'Players',
                            '${game['players']}',
                          ),
                          if (game['notes'] != null &&
                              (game['notes'] as String).isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Container(
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'note',
                                        color: theme.colorScheme.primary,
                                        size: 16,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'Notes',
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    game['notes'],
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
