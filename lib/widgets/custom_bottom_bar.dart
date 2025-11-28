import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// Custom bottom navigation bar for poker management app
/// Implements bottom-heavy interaction design for thumb-friendly navigation
/// Supports platform-adaptive styling and smooth transitions
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final BottomBarVariant variant;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.standard,
  });

  /// Navigation items mapped from Mobile Navigation Hierarchy
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      label: 'Games',
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today,
      route: '/calendar-view',
    ),
    BottomNavItem(
      label: 'Groups',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: '/groups-dashboard',
    ),
    BottomNavItem(
      label: 'Stats',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      route: '/player-stats',
    ),
    BottomNavItem(
      label: 'Payments',
      icon: Icons.attach_money_outlined,
      activeIcon: Icons.attach_money,
      route: '/payment-tracker',
    ),
    BottomNavItem(
      label: 'Profile',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      route: '/login-screen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case BottomBarVariant.standard:
        return _buildStandardBottomBar(context);
      case BottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case BottomBarVariant.minimal:
        return _buildMinimalBottomBar(context);
    }
  }

  /// Standard bottom navigation bar with full labels
  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleNavigation(context, index),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor:
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? theme
                                    .bottomNavigationBarTheme.selectedItemColor
                                : theme.bottomNavigationBarTheme
                                    .unselectedItemColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: (isSelected
                                  ? theme.bottomNavigationBarTheme
                                      .selectedLabelStyle
                                  : theme.bottomNavigationBarTheme
                                      .unselectedLabelStyle) ??
                              TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? theme.bottomNavigationBarTheme
                                        .selectedItemColor
                                    : theme.bottomNavigationBarTheme
                                        .unselectedItemColor,
                              ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Floating bottom bar with rounded corners and elevation
  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: theme.bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleNavigation(context, index),
                  borderRadius: BorderRadius.circular(16),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor:
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected
                                ? theme
                                    .bottomNavigationBarTheme.selectedItemColor
                                : theme.bottomNavigationBarTheme
                                    .unselectedItemColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: (isSelected
                                  ? theme.bottomNavigationBarTheme
                                      .selectedLabelStyle
                                  : theme.bottomNavigationBarTheme
                                      .unselectedLabelStyle) ??
                              TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? theme.bottomNavigationBarTheme
                                        .selectedItemColor
                                    : theme.bottomNavigationBarTheme
                                        .unselectedItemColor,
                              ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Minimal bottom bar with icons only
  Widget _buildMinimalBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => _handleNavigation(context, index),
                  splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  highlightColor:
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected
                            ? theme.bottomNavigationBarTheme.selectedItemColor
                            : theme
                                .bottomNavigationBarTheme.unselectedItemColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Handle navigation with smooth transitions
  void _handleNavigation(BuildContext context, int index) {
    if (currentIndex != index) {
      onTap(index);

      // Navigate to the selected route
      final route = _navItems[index].route;
      Navigator.pushReplacementNamed(
        context,
        route,
      );
    }
  }
}

/// Bottom bar visual variants
enum BottomBarVariant {
  /// Standard bottom bar with full labels and icons
  standard,

  /// Floating bottom bar with rounded corners
  floating,

  /// Minimal bottom bar with icons only
  minimal,
}
