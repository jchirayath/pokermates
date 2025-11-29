import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_test_helper.dart';

/// Integration tests for Group CRUD workflow
/// Tests: Create, Modify, Delete Group operations
void main() {
  late String testUserId;
  late String testGroupId;

  setUpAll(() async {
    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    // Create a test user for group operations
    testUserId = await SupabaseTestHelper.createTestUserProfile(
      fullName: 'Test Group Creator',
      username: 'group_test_user',
    );
  });

  tearDownAll(() async {
    // Cleanup test data
    if (testGroupId.isNotEmpty) {
      await SupabaseTestHelper.cleanupTestGroup(testGroupId);
    }
    await SupabaseTestHelper.cleanupTestUser(testUserId);
  });

  group('Group Workflow Tests', () {
    test('WORKFLOW 1.1: Create Group - Success', () async {
      // Arrange
      const groupName = 'Monday Night Poker';
      const groupDescription = 'Weekly poker game for friends';

      // Act
      testGroupId = await SupabaseTestHelper.createTestGroup(
        name: groupName,
        description: groupDescription,
        creatorId: testUserId,
      );

      // Assert
      expect(testGroupId, isNotEmpty);

      final groupExists = await SupabaseTestHelper.recordExists(
        table: 'poker_groups',
        id: testGroupId,
      );
      expect(groupExists, isTrue, reason: 'Group should exist in database');

      // Verify group data
      final group = await Supabase.instance.client
          .from('poker_groups')
          .select()
          .eq('id', testGroupId)
          .single();

      expect(group['name'], equals(groupName));
      expect(group['description'], equals(groupDescription));
      expect(group['creator_id'], equals(testUserId));
    });

    test('WORKFLOW 1.2: Create Group - Validation Failure (Missing Name)',
        () async {
      // Act & Assert
      expect(
        () async => await Supabase.instance.client.from('poker_groups').insert({
          'description': 'Group without name',
          'creator_id': testUserId,
        }),
        throwsA(isA<PostgrestException>()),
        reason: 'Should throw error when group name is missing',
      );
    });

    test('WORKFLOW 1.3: Modify Group - Update Name and Description', () async {
      // Arrange
      const updatedName = 'Friday Night Poker Club';
      const updatedDescription = 'Updated weekly poker game';

      // Act
      await Supabase.instance.client.from('poker_groups').update({
        'name': updatedName,
        'description': updatedDescription,
      }).eq('id', testGroupId);

      // Assert
      final updatedGroup = await Supabase.instance.client
          .from('poker_groups')
          .select()
          .eq('id', testGroupId)
          .single();

      expect(updatedGroup['name'], equals(updatedName));
      expect(updatedGroup['description'], equals(updatedDescription));
      expect(updatedGroup['updated_at'],
          isNot(equals(updatedGroup['created_at'])));
    });

    test('WORKFLOW 1.4: Modify Group - Update With Invalid Data', () async {
      // Act & Assert
      expect(
        () async => await Supabase.instance.client
            .from('poker_groups')
            .update({'name': ''}).eq('id', testGroupId),
        throwsA(isA<PostgrestException>()),
        reason: 'Should fail when updating with empty name',
      );
    });

    test('WORKFLOW 1.5: Delete Group - Success', () async {
      // Arrange - Create a group specifically for deletion
      final groupToDelete = await SupabaseTestHelper.createTestGroup(
        name: 'Temporary Test Group',
        description: 'Group created for deletion test',
        creatorId: testUserId,
      );

      // Act
      await Supabase.instance.client
          .from('poker_groups')
          .delete()
          .eq('id', groupToDelete);

      // Assert
      final groupExists = await SupabaseTestHelper.recordExists(
        table: 'poker_groups',
        id: groupToDelete,
      );
      expect(groupExists, isFalse,
          reason: 'Group should be deleted from database');
    });

    test('WORKFLOW 1.6: Delete Group - Cascade Delete Verification', () async {
      // Arrange - Create group with members
      final groupWithMembers = await SupabaseTestHelper.createTestGroup(
        name: 'Group With Members',
        description: 'Testing cascade delete',
        creatorId: testUserId,
      );

      await SupabaseTestHelper.addGroupMember(
        groupId: groupWithMembers,
        userId: testUserId,
        role: 'admin',
      );

      // Act - Delete group
      await Supabase.instance.client
          .from('poker_groups')
          .delete()
          .eq('id', groupWithMembers);

      // Assert - Verify members are also deleted
      final memberCount = await SupabaseTestHelper.getRecordCount(
        table: 'group_members',
        column: 'group_id',
        value: groupWithMembers,
      );
      expect(memberCount, equals(0),
          reason: 'Group members should be cascade deleted');
    });

    test('WORKFLOW 1.7: Create Multiple Groups - Same Creator', () async {
      // Arrange & Act
      final group1Id = await SupabaseTestHelper.createTestGroup(
        name: 'Poker Group 1',
        description: 'First group',
        creatorId: testUserId,
      );

      final group2Id = await SupabaseTestHelper.createTestGroup(
        name: 'Poker Group 2',
        description: 'Second group',
        creatorId: testUserId,
      );

      // Assert
      expect(group1Id, isNot(equals(group2Id)));

      final userGroupCount = await SupabaseTestHelper.getRecordCount(
        table: 'poker_groups',
        column: 'creator_id',
        value: testUserId,
      );
      expect(userGroupCount, greaterThanOrEqualTo(2));

      // Cleanup
      await SupabaseTestHelper.cleanupTestGroup(group1Id);
      await SupabaseTestHelper.cleanupTestGroup(group2Id);
    });
  });
}
