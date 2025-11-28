import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar for poker management app
/// Implements clean, professional navigation with contextual actions
/// Supports multiple variants for different screen contexts
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final AppBarVariant variant;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.variant = AppBarVariant.standard,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(kToolbarHeight + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppBarVariant.standard:
        return _buildStandardAppBar(context);
      case AppBarVariant.transparent:
        return _buildTransparentAppBar(context);
      case AppBarVariant.minimal:
        return _buildMinimalAppBar(context);
      case AppBarVariant.prominent:
        return _buildProminentAppBar(context);
    }
  }

  /// Standard app bar with solid background
  Widget _buildStandardAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: Text(
        title,
        style: appBarTheme.titleTextStyle,
      ),
      centerTitle: centerTitle,
      elevation: elevation ?? appBarTheme.elevation,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  /// Transparent app bar for overlay contexts
  Widget _buildTransparentAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          color: foregroundColor ?? Colors.white,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      bottom: bottom,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  /// Minimal app bar with reduced visual weight
  Widget _buildMinimalAppBar(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.appBarTheme.titleTextStyle?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  /// Prominent app bar with larger title for main screens
  Widget _buildProminentAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: Text(
        title,
        style: appBarTheme.titleTextStyle?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation ?? appBarTheme.elevation,
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      bottom: bottom,
      toolbarHeight: 72,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  /// Build leading widget with back button support
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Build action widgets with proper spacing
  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) {
      return null;
    }

    return [
      ...actions!,
      const SizedBox(width: 8),
    ];
  }
}

/// App bar visual variants
enum AppBarVariant {
  /// Standard app bar with solid background and elevation
  standard,

  /// Transparent app bar for overlay contexts
  transparent,

  /// Minimal app bar with reduced visual weight
  minimal,

  /// Prominent app bar with larger title
  prominent,
}

/// Helper widget for app bar action buttons
class AppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const AppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 24,
    );
  }
}

/// Helper widget for app bar text action buttons
class AppBarTextAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const AppBarTextAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? theme.appBarTheme.foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? theme.appBarTheme.foregroundColor,
        ),
      ),
    );
  }
}
