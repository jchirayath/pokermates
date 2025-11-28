import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen for PokerMates application
/// Provides branded app launch experience while initializing poker game services
/// and determining user authentication status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup logo scale and fade animations
  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  /// Initialize app services and determine navigation route
  Future<void> _initializeApp() async {
    try {
      // Simulate checking OAuth authentication tokens
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        setState(() => _statusMessage = 'Loading preferences...');
      }

      // Simulate loading user preferences
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        setState(() => _statusMessage = 'Syncing game data...');
      }

      // Simulate syncing cached game data
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() => _statusMessage = 'Preparing services...');
      }

      // Simulate preparing WhatsApp integration services
      await Future.delayed(const Duration(milliseconds: 500));

      // Check authentication status and navigate
      await _navigateToNextScreen();
    } catch (e) {
      // Handle initialization errors
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _statusMessage = 'Connection error. Tap to retry.';
        });
      }
    }
  }

  /// Determine next screen based on authentication status
  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Simulate authentication check
    final bool isAuthenticated = false; // Mock: user not authenticated
    final bool isFirstTime = true; // Mock: first time user

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // Navigation logic:
    // - Authenticated users → Groups Dashboard
    // - First time users → Onboarding (using Login as placeholder)
    // - Returning non-authenticated users → Login screen
    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/groups-dashboard');
    } else if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/login-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/login-screen');
    }
  }

  /// Handle retry on connection error
  void _handleRetry() {
    setState(() {
      _isInitializing = true;
      _statusMessage = 'Retrying...';
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildAnimatedLogo(theme),
              SizedBox(height: 8.h),
              _buildStatusIndicator(theme),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated poker-themed logo
  Widget _buildAnimatedLogo(ThemeData theme) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Poker chip icon as logo
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring segments
                      ...List.generate(8, (index) {
                        final angle = (index * 45.0) * (3.14159 / 180);
                        return Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.secondary,
                                width: 1.5.w,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Center circle with spade icon
                      Container(
                        width: 18.w,
                        height: 18.w,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'casino',
                            color: theme.colorScheme.onPrimary,
                            size: 8.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                // App name
                Text(
                  'PokerMates',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Manage Your Game',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build loading indicator and status message
  Widget _buildStatusIndicator(ThemeData theme) {
    if (!_isInitializing) {
      // Show retry button on error
      return GestureDetector(
        onTap: _handleRetry,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'refresh',
                color: theme.colorScheme.onPrimary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  _statusMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading indicator
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 0.8.w,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onPrimary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          _statusMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
