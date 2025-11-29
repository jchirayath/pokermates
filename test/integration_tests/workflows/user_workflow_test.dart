import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_test_helper.dart';

/// Integration tests for User/Member CRUD workflow within Groups
/// Tests: Create, Modify, Delete User operations within groups
void main() {
  late String testAdminUserId;
  late String testMemberUserId;
  late String testGroupId;
  late String testMembershipId;

  setUpAll(() async {
    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    // Create test admin user
    testAdminUserId = await SupabaseTestHelper.createTestUserProfile(
      fullName: 'Test Admin User',
      username: 'admin_test_user',
    );

    // Create test member user
    testMemberUserId = await SupabaseTestHelper.createTestUserProfile(
      fullName: 'Test Member User',
      username: 'member_test_user',
    );

    // Create test group
    testGroupId = await SupabaseTestHelper.createTestGroup(
      name: 'Test Group for Members',
      description: 'Group for member testing',
      creatorId: testAdminUserId,
    );
  });

  tearDownAll() async {
    // Cleanup test data
    await SupabaseTestHelper.cleanupTestGroup(testGroupId);
    await SupabaseTestHelper.cleanupTestUser(testAdminUserId);
    await SupabaseTestHelper.cleanupTestUser(testMemberUserId);
  });

  group('User/Member Workflow Tests', () {
    test('WORKFLOW 3.1: Add User to Group - Success', () async {
      // Act
      testMembershipId = await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: testMemberUserId,
        role: 'member',
      );

      // Assert
      expect(testMembershipId, isNotEmpty);
      
      final memberExists = await SupabaseTestHelper.recordExists(
        table: 'group_members',
        id: testMembershipId,
      );
      expect(memberExists, isTrue, reason: 'Member should exist in group');

      // Verify member data
      final member = await Supabase.instance.client
          .from('group_members')
          .select()
          .eq('id', testMembershipId)
          .single();

      expect(member['group_id'], equals(testGroupId));
      expect(member['user_id'], equals(testMemberUserId));
      expect(member['role'], equals('member'));
    });

    test('WORKFLOW 3.2: Add User to Group - Duplicate Prevention', () async {
      // Act & Assert - Try to add same user again
      expect(
        () async => await SupabaseTestHelper.addGroupMember(
          groupId: testGroupId,
          userId: testMemberUserId,
          role: 'member',
        ),
        throwsA(isA<PostgrestException>()),
        reason: 'Should prevent duplicate user in same group',
      );
    });

    test('WORKFLOW 3.3: Add User to Group - Invalid User Reference', () async {
      // Act & Assert
      expect(
        () async => await SupabaseTestHelper.addGroupMember(
          groupId: testGroupId,
          userId: '00000000-0000-0000-0000-000000000000',
          role: 'member',
        ),
        throwsA(isA<PostgrestException>()),
        reason: 'Should fail when referencing non-existent user',
      );
    });

    test('WORKFLOW 3.4: Modify User Role - Member to Admin', () async {
      // Act
      await Supabase.instance.client
          .from('group_members')
          .update({'role': 'admin'})
          .eq('id', testMembershipId);

      // Assert
      final updatedMember = await Supabase.instance.client
          .from('group_members')
          .select()
          .eq('id', testMembershipId)
          .single();

      expect(updatedMember['role'], equals('admin'));
    });

    test('WORKFLOW 3.5: Modify User Role - Admin to Member', () async {
      // Act
      await Supabase.instance.client
          .from('group_members')
          .update({'role': 'member'})
          .eq('id', testMembershipId);

      // Assert
      final updatedMember = await Supabase.instance.client
          .from('group_members')
          .select()
          .eq('id', testMembershipId)
          .single();

      expect(updatedMember['role'], equals('member'));
    });

    test('WORKFLOW 3.6: Modify User Role - Invalid Role Value', () async {
      // Act & Assert
      expect(
        () async => await Supabase.instance.client
            .from('group_members')
            .update({'role': 'superadmin'})
            .eq('id', testMembershipId),
        throwsA(isA<PostgrestException>()),
        reason: 'Should fail with invalid role value',
      );
    });

    test('WORKFLOW 3.7: Remove User from Group - Success', () async {
      // Arrange - Create a temporary member for deletion
      final tempUserId = await SupabaseTestHelper.createTestUserProfile(
        fullName: 'Temp Member User',
        username: 'temp_member_${DateTime.now().millisecondsSinceEpoch}',
      );

      final tempMembershipId = await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: tempUserId,
        role: 'member',
      );

      // Act
      await Supabase.instance.client
          .from('group_members')
          .delete()
          .eq('id', tempMembershipId);

      // Assert
      final memberExists = await SupabaseTestHelper.recordExists(
        table: 'group_members',
        id: tempMembershipId,
      );
      expect(memberExists, isFalse, reason: 'Member should be removed from group');

      // Cleanup
      await SupabaseTestHelper.cleanupTestUser(tempUserId);
    });

    test('WORKFLOW 3.8: Add Multiple Users to Group', () async {
      // Arrange - Create additional test users
      final user1Id = await SupabaseTestHelper.createTestUserProfile(
        fullName: 'Multi Test User 1',
        username: 'multi_user_1_${DateTime.now().millisecondsSinceEpoch}',
      );

      final user2Id = await SupabaseTestHelper.createTestUserProfile(
        fullName: 'Multi Test User 2',
        username: 'multi_user_2_${DateTime.now().millisecondsSinceEpoch}',
      );

      // Act
      final member1Id = await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: user1Id,
        role: 'member',
      );

      final member2Id = await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: user2Id,
        role: 'member',
      );

      // Assert
      expect(member1Id, isNot(equals(member2Id)));
      
      final memberCount = await SupabaseTestHelper.getRecordCount(
        table: 'group_members',
        column: 'group_id',
        value: testGroupId,
      );
      expect(memberCount, greaterThanOrEqualTo(3)); // Including original member

      // Cleanup
      await Supabase.instance.client.from('group_members').delete().eq('id', member1Id);
      await Supabase.instance.client.from('group_members').delete().eq('id', member2Id);
      await SupabaseTestHelper.cleanupTestUser(user1Id);
      await SupabaseTestHelper.cleanupTestUser(user2Id);
    });

    test('WORKFLOW 3.9: Get Group Members List', () async {
      // Act
      final members = await Supabase.instance.client
          .from('group_members')
          .select('*, user_profiles(*)')
          .eq('group_id', testGroupId);

      // Assert
      expect(members, isNotEmpty);
      expect(members.length, greaterThanOrEqualTo(1));
      
      final memberData = members.first;
      expect(memberData['user_profiles'], isNotNull);
      expect(memberData['user_profiles']['full_name'], isNotEmpty);
    });

    test('WORKFLOW 3.10: Verify Member Access to Group', () async {
      // Act - Get groups where user is a member
      final userGroups = await Supabase.instance.client
          .from('group_members')
          .select('group_id, poker_groups(*)')
          .eq('user_id', testMemberUserId);

      // Assert
      expect(userGroups, isNotEmpty);
      expect(userGroups.any((g) => g['group_id'] == testGroupId), isTrue);
    });

    test('WORKFLOW 3.11: Remove All Members from Group', () async {
      // Arrange - Add temporary members
      final tempUser1 = await SupabaseTestHelper.createTestUserProfile(
        fullName: 'Temp User 1',
        username: 'temp_1_${DateTime.now().millisecondsSinceEpoch}',
      );
      
      final tempUser2 = await SupabaseTestHelper.createTestUserProfile(
        fullName: 'Temp User 2',
        username: 'temp_2_${DateTime.now().millisecondsSinceEpoch}',
      );

      await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: tempUser1,
        role: 'member',
      );

      await SupabaseTestHelper.addGroupMember(
        groupId: testGroupId,
        userId: tempUser2,
        role: 'member',
      );

      // Act - Remove all members
      await Supabase.instance.client
          .from('group_members')
          .delete()
          .eq('group_id', testGroupId);

      // Assert
      final remainingMembers = await SupabaseTestHelper.getRecordCount(
        table: 'group_members',
        column: 'group_id',
        value: testGroupId,
      );
      expect(remainingMembers, equals(0), reason: 'All members should be removed');

      // Cleanup
      await SupabaseTestHelper.cleanupTestUser(tempUser1);
      await SupabaseTestHelper.cleanupTestUser(tempUser2);
    });
  });
}