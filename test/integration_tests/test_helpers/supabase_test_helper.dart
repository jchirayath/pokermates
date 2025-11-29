import 'package:supabase_flutter/supabase_flutter.dart';

/// Test helper for Supabase integration tests
/// Provides common utilities and setup methods for test execution
class SupabaseTestHelper {
  static SupabaseClient get client => Supabase.instance.client;

  /// Creates a test user profile for testing purposes
  /// Returns the created user profile ID
  static Future<String> createTestUserProfile({
    required String fullName,
    String? username,
    String? email,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No authenticated user found');
    }

    final response = await client
        .from('user_profiles')
        .insert({
          'id': userId,
          'full_name': fullName,
          'username':
              username ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        })
        .select()
        .single();

    return response['id'] as String;
  }

  /// Creates a test group and returns its ID
  static Future<String> createTestGroup({
    required String name,
    String? description,
    required String creatorId,
  }) async {
    final response = await client
        .from('poker_groups')
        .insert({
          'name': name,
          'description': description ?? 'Test group description',
          'creator_id': creatorId,
        })
        .select()
        .single();

    return response['id'] as String;
  }

  /// Creates a test game and returns its ID
  static Future<String> createTestGame({
    required String groupId,
    required String hostId,
    required double buyinAmount,
    required DateTime scheduledAt,
  }) async {
    final response = await client
        .from('poker_games')
        .insert({
          'group_id': groupId,
          'host_id': hostId,
          'buyin_amount': buyinAmount,
          'scheduled_at': scheduledAt.toIso8601String(),
          'status': 'scheduled',
        })
        .select()
        .single();

    return response['id'] as String;
  }

  /// Adds a member to a group
  static Future<String> addGroupMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    final response = await client
        .from('group_members')
        .insert({
          'group_id': groupId,
          'user_id': userId,
          'role': role,
        })
        .select()
        .single();

    return response['id'] as String;
  }

  /// Cleans up test data by deleting all records for a specific group
  static Future<void> cleanupTestGroup(String groupId) async {
    // Delete in order of dependencies
    await client.from('game_participants').delete().match({'game_id': groupId});
    await client.from('poker_games').delete().match({'group_id': groupId});
    await client.from('group_members').delete().match({'group_id': groupId});
    await client.from('poker_groups').delete().match({'id': groupId});
  }

  /// Cleans up test user profile
  static Future<void> cleanupTestUser(String userId) async {
    await client.from('user_profiles').delete().match({'id': userId});
  }

  /// Verifies if a record exists in a table
  static Future<bool> recordExists({
    required String table,
    required String id,
  }) async {
    final response =
        await client.from(table).select('id').eq('id', id).maybeSingle();
    return response != null;
  }

  /// Gets count of records matching a condition
  static Future<int> getRecordCount({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    final response = await client.from(table).select('id').eq(column, value);
    return (response as List).length;
  }

  /// Waits for a condition to be true with timeout
  static Future<bool> waitForCondition({
    required Future<bool> Function() condition,
    Duration timeout = const Duration(seconds: 5),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      if (await condition()) {
        return true;
      }
      await Future.delayed(checkInterval);
    }
    return false;
  }
}
