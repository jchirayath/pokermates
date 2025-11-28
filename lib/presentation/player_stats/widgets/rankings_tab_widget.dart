import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RankingsTabWidget extends StatefulWidget {
  final String selectedPlayer;

  const RankingsTabWidget({
    super.key,
    required this.selectedPlayer,
  });

  @override
  State<RankingsTabWidget> createState() => _RankingsTabWidgetState();
}

class _RankingsTabWidgetState extends State<RankingsTabWidget> {
  String _selectedMetric = 'Net Profit';
  final List<String> _metrics = [
    'Net Profit',
    'Win Rate',
    'Total Games',
    'Avg Buy-In',
    'Biggest Win',
  ];

  // Mock rankings data
  List<Map<String, dynamic>> _getRankingsData() {
    switch (_selectedMetric) {
      case 'Net Profit':
        return [
          {
            'rank': 1,
            'name': 'John Smith',
            'value': '\$8,450',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_12edd2a4d-1763295490616.png',
            'semanticLabel':
                'Profile photo of a man with short brown hair wearing a blue shirt',
          },
          {
            'rank': 2,
            'name': 'Michael Chen',
            'value': '\$7,820',
            'movement': 'same',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1a79a1c0a-1763294718604.png',
            'semanticLabel':
                'Profile photo of an Asian man with black hair and glasses',
          },
          {
            'rank': 3,
            'name': 'Sarah Johnson',
            'value': '\$6,950',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1453e1878-1763300003100.png',
            'semanticLabel':
                'Profile photo of a woman with blonde hair and a friendly smile',
          },
          {
            'rank': 4,
            'name': 'David Rodriguez',
            'value': '\$5,230',
            'movement': 'down',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1e13bc62a-1763294059113.png',
            'semanticLabel':
                'Profile photo of a Hispanic man with dark hair and beard',
          },
          {
            'rank': 5,
            'name': 'Emily Williams',
            'value': '\$4,680',
            'movement': 'up',
            'avatar':
                'https://images.unsplash.com/photo-1594332495120-7ee1b6f83b37',
            'semanticLabel':
                'Profile photo of a woman with red hair wearing glasses',
          },
        ];
      case 'Win Rate':
        return [
          {
            'rank': 1,
            'name': 'Sarah Johnson',
            'value': '62.5%',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1453e1878-1763300003100.png',
            'semanticLabel':
                'Profile photo of a woman with blonde hair and a friendly smile',
          },
          {
            'rank': 2,
            'name': 'John Smith',
            'value': '58.3%',
            'movement': 'same',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_12edd2a4d-1763295490616.png',
            'semanticLabel':
                'Profile photo of a man with short brown hair wearing a blue shirt',
          },
          {
            'rank': 3,
            'name': 'Michael Chen',
            'value': '55.8%',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1a79a1c0a-1763294718604.png',
            'semanticLabel':
                'Profile photo of an Asian man with black hair and glasses',
          },
          {
            'rank': 4,
            'name': 'Emily Williams',
            'value': '52.1%',
            'movement': 'down',
            'avatar':
                'https://images.unsplash.com/photo-1594332495120-7ee1b6f83b37',
            'semanticLabel':
                'Profile photo of a woman with red hair wearing glasses',
          },
          {
            'rank': 5,
            'name': 'David Rodriguez',
            'value': '48.9%',
            'movement': 'same',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1e13bc62a-1763294059113.png',
            'semanticLabel':
                'Profile photo of a Hispanic man with dark hair and beard',
          },
        ];
      default:
        return [
          {
            'rank': 1,
            'name': 'John Smith',
            'value': '127',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_12edd2a4d-1763295490616.png',
            'semanticLabel':
                'Profile photo of a man with short brown hair wearing a blue shirt',
          },
          {
            'rank': 2,
            'name': 'Michael Chen',
            'value': '115',
            'movement': 'same',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1a79a1c0a-1763294718604.png',
            'semanticLabel':
                'Profile photo of an Asian man with black hair and glasses',
          },
          {
            'rank': 3,
            'name': 'Sarah Johnson',
            'value': '98',
            'movement': 'up',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1453e1878-1763300003100.png',
            'semanticLabel':
                'Profile photo of a woman with blonde hair and a friendly smile',
          },
          {
            'rank': 4,
            'name': 'David Rodriguez',
            'value': '87',
            'movement': 'down',
            'avatar':
                'https://img.rocket.new/generatedImages/rocket_gen_img_1e13bc62a-1763294059113.png',
            'semanticLabel':
                'Profile photo of a Hispanic man with dark hair and beard',
          },
          {
            'rank': 5,
            'name': 'Emily Williams',
            'value': '76',
            'movement': 'up',
            'avatar':
                'https://images.unsplash.com/photo-1594332495120-7ee1b6f83b37',
            'semanticLabel':
                'Profile photo of a woman with red hair wearing glasses',
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rankingsData = _getRankingsData();

    return Column(
      children: [
        // Metric selector
        Container(
          padding: EdgeInsets.all(4.w),
          color: theme.colorScheme.surface,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _metrics.map((metric) {
                final isSelected = metric == _selectedMetric;
                return Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: ChoiceChip(
                    label: Text(metric),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedMetric = metric;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Rankings list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(4.w),
            itemCount: rankingsData.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final player = rankingsData[index];
              final isCurrentPlayer = player['name'] == widget.selectedPlayer;

              return Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isCurrentPlayer
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentPlayer
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: _getRankColor(player['rank'], theme),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${player['rank']}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: CustomImageWidget(
                        imageUrl: player['avatar'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        semanticLabel: player['semanticLabel'],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    // Player info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            player['name'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isCurrentPlayer
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              _buildMovementIndicator(
                                  theme, player['movement']),
                              SizedBox(width: 1.w),
                              Text(
                                _getMovementText(player['movement']),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Value
                    Text(
                      player['value'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isCurrentPlayer
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank, ThemeData theme) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return theme.colorScheme.primary;
    }
  }

  Widget _buildMovementIndicator(ThemeData theme, String movement) {
    IconData icon;
    Color color;

    switch (movement) {
      case 'up':
        icon = Icons.arrow_upward;
        color = Colors.green;
        break;
      case 'down':
        icon = Icons.arrow_downward;
        color = Colors.red;
        break;
      default:
        icon = Icons.remove;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return CustomIconWidget(
      iconName: icon
          .toString()
          .split('.')
          .last
          .replaceAll('IconData(U+', '')
          .replaceAll(')', ''),
      color: color,
      size: 16,
    );
  }

  String _getMovementText(String movement) {
    switch (movement) {
      case 'up':
        return 'Moving up';
      case 'down':
        return 'Moving down';
      default:
        return 'No change';
    }
  }
}
