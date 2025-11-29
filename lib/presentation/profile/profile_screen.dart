import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/profile_service.dart';
import '../../services/supabase_service.dart';
import './edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabaseService = SupabaseService.instance;
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      // Get current user
      final currentUser = _supabaseService.client.auth.currentUser;

      // Create profile if it doesn't exist
      final profile = await _profileService.getCurrentUserProfile();

      if (profile == null) {
        if (currentUser != null) {
          final newProfile = await _profileService.createProfile(
            userId: currentUser.id,
            fullName: currentUser.email?.split('@')[0] ?? 'User',
            username: currentUser.email?.split('@')[0],
          );
          setState(() {
            _profile = newProfile;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sign Out'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (shouldSignOut == true) {
      await _supabaseService.client.auth.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfile,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _profile == null
              ? const Center(child: Text('No profile found'))
              : RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildInfoSection(),
                      const SizedBox(height: 24),
                      _buildAddressSection(),
                      const SizedBox(height: 24),
                      _buildPreferencesSection(),
                      const SizedBox(height: 24),
                      _buildEditButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(51),
            backgroundImage:
                _profile!['avatar_url'] != null
                    ? NetworkImage(_profile!['avatar_url'])
                    : null,
            child:
                _profile!['avatar_url'] == null
                    ? Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    )
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            _profile!['full_name'] ?? 'No Name',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (_profile!['username'] != null) ...[
            const SizedBox(height: 4),
            Text(
              '@${_profile!['username']}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
          ],
          if (_profile!['bio'] != null) ...[
            const SizedBox(height: 12),
            Text(
              _profile!['bio'],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email,
              'Email',
              _supabaseService.client.auth.currentUser?.email ?? 'Not set',
            ),
            if (_profile!['phone_number'] != null) ...[
              const Divider(height: 24),
              _buildInfoRow(Icons.phone, 'Phone', _profile!['phone_number']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    final hasAddress =
        _profile!['address_line1'] != null ||
        _profile!['city'] != null ||
        _profile!['state'] != null ||
        _profile!['country'] != null;

    if (!hasAddress) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'Address', _buildAddressString()),
          ],
        ),
      ),
    );
  }

  String _buildAddressString() {
    final parts = <String>[];
    if (_profile!['address_line1'] != null)
      parts.add(_profile!['address_line1']);
    if (_profile!['address_line2'] != null)
      parts.add(_profile!['address_line2']);
    if (_profile!['city'] != null) parts.add(_profile!['city']);
    if (_profile!['state'] != null) parts.add(_profile!['state']);
    if (_profile!['postal_code'] != null) parts.add(_profile!['postal_code']);
    if (_profile!['country'] != null) parts.add(_profile!['country']);
    return parts.join(', ');
  }

  Widget _buildPreferencesSection() {
    final hasPreferences =
        _profile!['preferred_game_type'] != null ||
        _profile!['skill_level'] != null;

    if (!hasPreferences) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Poker Preferences',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_profile!['preferred_game_type'] != null) ...[
              _buildInfoRow(
                Icons.casino,
                'Preferred Game',
                _profile!['preferred_game_type'],
              ),
            ],
            if (_profile!['skill_level'] != null) ...[
              if (_profile!['preferred_game_type'] != null)
                const Divider(height: 24),
              _buildInfoRow(
                Icons.stars,
                'Skill Level',
                _profile!['skill_level'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfileScreen(profile: _profile!),
            ),
          );

          if (result == true) {
            _loadProfile();
          }
        },
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profile'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
