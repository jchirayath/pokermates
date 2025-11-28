import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Login Screen for PokerMates
/// Enables secure multi-provider OAuth authentication optimized for mobile poker players
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  AuthProvider? _loadingProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    _buildLogoSection(theme),
                    SizedBox(height: 6.h),
                    _buildWelcomeText(theme),
                    SizedBox(height: 4.h),
                    _buildAuthButtons(theme),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 3.h),
                      _buildErrorMessage(theme),
                    ],
                    SizedBox(height: 4.h),
                    _buildTermsText(theme),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build poker chip logo section
  Widget _buildLogoSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.onPrimary,
                    width: 2,
                  ),
                ),
              ),
              // Inner circle with poker symbols
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'casino',
                    color: theme.colorScheme.onPrimary,
                    size: 12.w,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'PM',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build welcome text section
  Widget _buildWelcomeText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Welcome to PokerMates',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Manage your poker games, track stats,\nand coordinate with your group',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Build authentication buttons
  Widget _buildAuthButtons(ThemeData theme) {
    return Column(
      children: [
        _buildOAuthButton(
          theme: theme,
          provider: AuthProvider.google,
          label: 'Continue with Google',
          iconName: 'g_translate',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: Colors.grey.shade300,
        ),
        SizedBox(height: 2.h),
        _buildOAuthButton(
          theme: theme,
          provider: AuthProvider.facebook,
          label: 'Continue with Facebook',
          iconName: 'facebook',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
        ),
      ],
    );
  }

  /// Build individual OAuth button
  Widget _buildOAuthButton({
    required ThemeData theme,
    required AuthProvider provider,
    required String label,
    required String iconName,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    final isLoading = _isLoading && _loadingProvider == provider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () => _handleOAuthLogin(provider),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          height: 7.h,
          constraints: BoxConstraints(
            minHeight: 56,
            maxHeight: 64,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 6.w,
                    height: 6.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  CustomIconWidget(
                    iconName: iconName,
                    color: textColor,
                    size: 6.w,
                  ),
                SizedBox(width: 3.w),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build error message
  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build terms and privacy text
  Widget _buildTermsText(ThemeData theme) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  /// Handle OAuth login
  Future<void> _handleOAuthLogin(AuthProvider provider) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingProvider = provider;
      _errorMessage = null;
    });

    try {
      // Simulate OAuth authentication
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication success
      final bool isFirstTimeUser = DateTime.now().second % 2 == 0;

      if (!mounted) return;

      // Provide haptic feedback
      _showSuccessFeedback();

      // Navigate based on user status
      if (isFirstTimeUser) {
        // First time user - show onboarding or go to groups dashboard
        Navigator.pushReplacementNamed(context, '/groups-dashboard');
      } else {
        // Returning user - go directly to groups dashboard
        Navigator.pushReplacementNamed(context, '/groups-dashboard');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _getErrorMessage(e, provider);
        _isLoading = false;
        _loadingProvider = null;
      });
    }
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error, AuthProvider provider) {
    final providerName =
        provider == AuthProvider.google ? 'Google' : 'Facebook';

    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet and try again.';
    } else if (error.toString().contains('cancelled')) {
      return '$providerName sign-in was cancelled. Please try again.';
    } else {
      return 'Unable to sign in with $providerName. Please try again later.';
    }
  }

  /// Show success feedback
  void _showSuccessFeedback() {
    // In a real app, this would trigger haptic feedback
    // HapticFeedback.mediumImpact();
  }
}

/// Authentication provider enum
enum AuthProvider {
  google,
  facebook,
}
