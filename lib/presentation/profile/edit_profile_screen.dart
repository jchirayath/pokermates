import 'package:flutter/material.dart';

import '../../services/profile_service.dart';
import '../../services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  final SupabaseService _supabaseService = SupabaseService.instance;

  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _postalCodeController;
  late TextEditingController _countryController;

  String? _selectedGameType;
  String? _selectedSkillLevel;
  bool _isSubmitting = false;
  bool _isCheckingUsername = false;
  String? _usernameError;

  final List<String> _gameTypes = [
    'Texas Hold\'em',
    'Omaha',
    'Seven Card Stud',
    'Five Card Draw',
    'Mixed Games',
  ];

  final List<String> _skillLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(
      text: widget.profile['full_name'] ?? '',
    );
    _usernameController = TextEditingController(
      text: widget.profile['username'] ?? '',
    );
    _bioController = TextEditingController(text: widget.profile['bio'] ?? '');
    _phoneController = TextEditingController(
      text: widget.profile['phone_number'] ?? '',
    );
    _addressLine1Controller = TextEditingController(
      text: widget.profile['address_line1'] ?? '',
    );
    _addressLine2Controller = TextEditingController(
      text: widget.profile['address_line2'] ?? '',
    );
    _cityController = TextEditingController(text: widget.profile['city'] ?? '');
    _stateController = TextEditingController(
      text: widget.profile['state'] ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.profile['postal_code'] ?? '',
    );
    _countryController = TextEditingController(
      text: widget.profile['country'] ?? '',
    );
    _selectedGameType = widget.profile['preferred_game_type'];
    _selectedSkillLevel = widget.profile['skill_level'];
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.isEmpty || username == widget.profile['username']) {
      setState(() => _usernameError = null);
      return;
    }

    setState(() => _isCheckingUsername = true);

    final isAvailable = await _profileService.isUsernameAvailable(
      username,
      excludeUserId: _supabaseService.client.auth.currentUser?.id,
    );

    setState(() {
      _isCheckingUsername = false;
      _usernameError = isAvailable ? null : 'Username is already taken';
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final result = await _profileService.updateProfile(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        username:
            _usernameController.text.trim().isEmpty
                ? null
                : _usernameController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        addressLine1:
            _addressLine1Controller.text.trim().isEmpty
                ? null
                : _addressLine1Controller.text.trim(),
        addressLine2:
            _addressLine2Controller.text.trim().isEmpty
                ? null
                : _addressLine2Controller.text.trim(),
        city:
            _cityController.text.trim().isEmpty
                ? null
                : _cityController.text.trim(),
        state:
            _stateController.text.trim().isEmpty
                ? null
                : _stateController.text.trim(),
        postalCode:
            _postalCodeController.text.trim().isEmpty
                ? null
                : _postalCodeController.text.trim(),
        country:
            _countryController.text.trim().isEmpty
                ? null
                : _countryController.text.trim(),
        preferredGameType: _selectedGameType,
        skillLevel: _selectedSkillLevel,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildContactSection(),
            const SizedBox(height: 24),
            _buildAddressSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'Choose a unique username',
                prefixIcon: const Icon(Icons.alternate_email),
                suffixIcon:
                    _isCheckingUsername
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : null,
                errorText: _usernameError,
              ),
              onChanged: (value) {
                _checkUsernameAvailability(value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself',
                prefixIcon: Icon(Icons.edit),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
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
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
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
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1',
                hintText: 'Street address',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2',
                hintText: 'Apartment, suite, etc.',
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Postal Code',
                      prefixIcon: Icon(Icons.pin_drop),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      prefixIcon: Icon(Icons.flag),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
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
            DropdownButtonFormField<String>(
              value: _selectedGameType,
              decoration: const InputDecoration(
                labelText: 'Preferred Game Type',
                prefixIcon: Icon(Icons.casino),
              ),
              items:
                  _gameTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
              onChanged: (value) {
                setState(() => _selectedGameType = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSkillLevel,
              decoration: const InputDecoration(
                labelText: 'Skill Level',
                prefixIcon: Icon(Icons.stars),
              ),
              items:
                  _skillLevels.map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
              onChanged: (value) {
                setState(() => _selectedSkillLevel = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _saveProfile,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child:
          _isSubmitting
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Text('Save Changes'),
    );
  }
}
