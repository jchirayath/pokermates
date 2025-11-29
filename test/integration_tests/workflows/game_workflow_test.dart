import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../test_helpers/supabase_test_helper.dart';

/// Integration tests for Game CRUD workflow within Groups
/// Tests: Create, Modify, Delete Game operations
void main() {
  late String testUserId;
  late String testGroupId;
  late String testGameId;

  setUpAll(() async {
    // Initialize Supabase
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );

    // Create test user and group
    testUserId = await SupabaseTestHelper.createTestUserProfile(
      fullName: 'Test Game Host',
      username: 'game_test_user',
    );

    testGroupId = await SupabaseTestHelper.createTestGroup(
      name: 'Test Poker Group for Games',
      description: 'Group for game testing',
      creatorId: testUserId,
    );
  });

  tearDownAll(() async {
    // Cleanup test data
    await SupabaseTestHelper.cleanupTestGroup(testGroupId);
    await SupabaseTestHelper.cleanupTestUser(testUserId);
  });

  group('Game Workflow Tests', () {
    test('WORKFLOW 2.1: Create Game - Success', () async {
      // Arrange
      final scheduledTime = DateTime.now().add(const Duration(days: 7));
      const buyinAmount = 50.0;

      // Act
      testGameId = await SupabaseTestHelper.createTestGame(
        groupId: testGroupId,
        hostId: testUserId,
        buyinAmount: buyinAmount,
        scheduledAt: scheduledTime,
      );

      // Assert
      expect(testGameId, isNotEmpty);

      final gameExists = await SupabaseTestHelper.recordExists(
        table: 'poker_games',
        id: testGameId,
      );
      expect(gameExists, isTrue, reason: 'Game should exist in database');

      // Verify game data
      final game = await Supabase.instance.client
          .from('poker_games')
          .select()
          .eq('id', testGameId)
          .single();

      expect(game['group_id'], equals(testGroupId));
      expect(game['host_id'], equals(testUserId));
      expect(game['buyin_amount'], equals(buyinAmount.toString()));
      expect(game['status'], equals('scheduled'));
    });

    test(
        'WORKFLOW 2.2: Create Game - Validation Failure (Missing Required Fields)',
        () async {
      // Act & Assert - Missing buyin_amount
      expect(
        () async => await Supabase.instance.client.from('poker_games').insert({
          'group_id': testGroupId,
          'host_id': testUserId,
          'scheduled_at':
              DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        }),
        throwsA(isA<PostgrestException>()),
        reason: 'Should throw error when buyin_amount is missing',
      );
    });

    test('WORKFLOW 2.3: Create Game - Invalid Group Reference', () async {
      // Act & Assert
      expect(
        () async => await SupabaseTestHelper.createTestGame(
          groupId: '00000000-0000-0000-0000-000000000000',
          hostId: testUserId,
          buyinAmount: 50.0,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        ),
        throwsA(isA<PostgrestException>()),
        reason: 'Should fail when referencing non-existent group',
      );
    });

    test('WORKFLOW 2.4: Modify Game - Update Schedule and Buyin', () async {
      // Arrange
      final newScheduledTime = DateTime.now().add(const Duration(days: 14));
      const newBuyinAmount = 100.0;

      // Act
      await Supabase.instance.client.from('poker_games').update({
        'scheduled_at': newScheduledTime.toIso8601String(),
        'buyin_amount': newBuyinAmount,
        'allow_rebuys': true,
        'rebuy_amount': 50.0,
      }).eq('id', testGameId);

      // Assert
      final updatedGame = await Supabase.instance.client
          .from('poker_games')
          .select()
          .eq('id', testGameId)
          .single();

      expect(updatedGame['buyin_amount'], equals(newBuyinAmount.toString()));
      expect(updatedGame['allow_rebuys'], equals(true));
      expect(updatedGame['rebuy_amount'], equals('50'));
    });

    test('WORKFLOW 2.5: Modify Game - Change Status', () async {
      // Act - Update game status
      await Supabase.instance.client
          .from('poker_games')
          .update({'status': 'in_progress'}).eq('id', testGameId);

      // Assert
      final game = await Supabase.instance.client
          .from('poker_games')
          .select()
          .eq('id', testGameId)
          .single();

      expect(game['status'], equals('in_progress'));

      // Change to completed
      await Supabase.instance.client
          .from('poker_games')
          .update({'status': 'completed'}).eq('id', testGameId);

      final completedGame = await Supabase.instance.client
          .from('poker_games')
          .select()
          .eq('id', testGameId)
          .single();

      expect(completedGame['status'], equals('completed'));
    });

    test('WORKFLOW 2.6: Modify Game - Invalid Status Value', () async {
      // Act & Assert
      expect(
        () async => await Supabase.instance.client
            .from('poker_games')
            .update({'status': 'invalid_status'}).eq('id', testGameId),
        throwsA(isA<PostgrestException>()),
        reason: 'Should fail with invalid game status',
      );
    });

    test('WORKFLOW 2.7: Delete Game - Success', () async {
      // Arrange - Create a game specifically for deletion
      final gameToDelete = await SupabaseTestHelper.createTestGame(
        groupId: testGroupId,
        hostId: testUserId,
        buyinAmount: 25.0,
        scheduledAt: DateTime.now().add(const Duration(days: 3)),
      );

      // Act
      await Supabase.instance.client
          .from('poker_games')
          .delete()
          .eq('id', gameToDelete);

      // Assert
      final gameExists = await SupabaseTestHelper.recordExists(
        table: 'poker_games',
        id: gameToDelete,
      );
      expect(gameExists, isFalse,
          reason: 'Game should be deleted from database');
    });

    test('WORKFLOW 2.8: Create Multiple Games - Same Group', () async {
      // Arrange & Act
      final game1Id = await SupabaseTestHelper.createTestGame(
        groupId: testGroupId,
        hostId: testUserId,
        buyinAmount: 50.0,
        scheduledAt: DateTime.now().add(const Duration(days: 1)),
      );

      final game2Id = await SupabaseTestHelper.createTestGame(
        groupId: testGroupId,
        hostId: testUserId,
        buyinAmount: 75.0,
        scheduledAt: DateTime.now().add(const Duration(days: 2)),
      );

      // Assert
      expect(game1Id, isNot(equals(game2Id)));

      final groupGameCount = await SupabaseTestHelper.getRecordCount(
        table: 'poker_games',
        column: 'group_id',
        value: testGroupId,
      );
      expect(groupGameCount, greaterThanOrEqualTo(2));

      // Cleanup
      await Supabase.instance.client
          .from('poker_games')
          .delete()
          .eq('id', game1Id);
      await Supabase.instance.client
          .from('poker_games')
          .delete()
          .eq('id', game2Id);
    });

    test('WORKFLOW 2.9: Add Game Notes - Update Text Field', () async {
      // Arrange
      const gameNotes = 'Bring chips and cards. Starting at 7 PM sharp.';

      // Act
      await Supabase.instance.client
          .from('poker_games')
          .update({'notes': gameNotes}).eq('id', testGameId);

      // Assert
      final game = await Supabase.instance.client
          .from('poker_games')
          .select()
          .eq('id', testGameId)
          .single();

      expect(game['notes'], equals(gameNotes));
    });

    test('WORKFLOW 2.10: Delete Game - Cascade Delete Participants', () async {
      // Arrange - Create game with participants
      final gameWithParticipants = await SupabaseTestHelper.createTestGame(
        groupId: testGroupId,
        hostId: testUserId,
        buyinAmount: 50.0,
        scheduledAt: DateTime.now().add(const Duration(days: 5)),
      );

      // Add participant
      await Supabase.instance.client.from('game_participants').insert({
        'game_id': gameWithParticipants,
        'user_id': testUserId,
        'total_buyin': 50.0,
      });

      // Act - Delete game
      await Supabase.instance.client
          .from('poker_games')
          .delete()
          .eq('id', gameWithParticipants);

      // Assert - Verify participants are also deleted
      final participantCount = await SupabaseTestHelper.getRecordCount(
        table: 'game_participants',
        column: 'game_id',
        value: gameWithParticipants,
      );
      expect(participantCount, equals(0),
          reason: 'Game participants should be cascade deleted');
    });
  });
}
