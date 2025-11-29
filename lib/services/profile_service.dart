import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import './supabase_service.dart';

class ProfileService {
  SupabaseClient get _client => SupabaseService.instance.client;

  // Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response =
          await _client
              .from('user_profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Get current user's profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      return await getUserProfile(currentUser.id);
    } catch (e) {
      debugPrint('Error fetching current user profile: $e');
      return null;
    }
  }

  // Create user profile
  Future<Map<String, dynamic>?> createProfile({
    required String userId,
    required String fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? preferredGameType,
    String? skillLevel,
  }) async {
    try {
      final data = {
        'id': userId,
        'full_name': fullName,
        'username': username,
        'bio': bio,
        'avatar_url': avatarUrl,
        'phone_number': phoneNumber,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
        'preferred_game_type': preferredGameType,
        'skill_level': skillLevel,
      };

      // Remove null values
      data.removeWhere((key, value) => value == null);

      final response =
          await _client.from('user_profiles').insert(data).select().single();

      return response;
    } catch (e) {
      print('Error creating profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>?> updateProfile({
    required String userId,
    String? fullName,
    String? username,
    String? bio,
    String? avatarUrl,
    String? phoneNumber,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? preferredGameType,
    String? skillLevel,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (fullName != null) data['full_name'] = fullName;
      if (username != null) data['username'] = username;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      if (phoneNumber != null) data['phone_number'] = phoneNumber;
      if (addressLine1 != null) data['address_line1'] = addressLine1;
      if (addressLine2 != null) data['address_line2'] = addressLine2;
      if (city != null) data['city'] = city;
      if (state != null) data['state'] = state;
      if (postalCode != null) data['postal_code'] = postalCode;
      if (country != null) data['country'] = country;
      if (preferredGameType != null)
        data['preferred_game_type'] = preferredGameType;
      if (skillLevel != null) data['skill_level'] = skillLevel;

      if (data.isEmpty) return null;

      final response =
          await _client
              .from('user_profiles')
              .update(data)
              .eq('id', userId)
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error updating profile: $e');
      return null;
    }
  }

  // Delete user profile
  Future<bool> deleteProfile(String userId) async {
    try {
      await _client.from('user_profiles').delete().eq('id', userId);

      return true;
    } catch (e) {
      print('Error deleting profile: $e');
      return false;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(
    String username, {
    String? excludeUserId,
  }) async {
    try {
      var query = _client
          .from('user_profiles')
          .select('id')
          .eq('username', username);

      if (excludeUserId != null) {
        query = query.neq('id', excludeUserId);
      }

      final response = await query.maybeSingle();
      return response == null;
    } catch (e) {
      print('Error checking username availability: $e');
      return false;
    }
  }

  // Search profiles by name or username
  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching profiles: $e');
      return [];
    }
  }
}
