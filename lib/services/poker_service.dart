import './supabase_service.dart';
import 'package:flutter/foundation.dart';

/// Service for managing poker groups, games, and related data
class PokerService {
  static final SupabaseService _supabase = SupabaseService.instance;

  // Utility method to get current user ID with better null handling
  static String? _getCurrentUserIdSafe() {
    return _supabase.client.auth.currentUser?.id;
  }

  // Utility method to get current user ID
  static String getCurrentUserId() {
    final userId = _getCurrentUserIdSafe();
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  // Groups Operations
  static Future<List<Map<String, dynamic>>> fetchUserGroups() async {
    try {
      final userId = _getCurrentUserIdSafe();
      if (userId == null) {
        debugPrint('User not authenticated, returning empty groups list');
        return [];
      }

      final response = await _supabase.client
          .from('poker_groups')
          .select('''
            *,
            group_members!inner(user_id, role),
            poker_games(id, scheduled_at, status)
          ''')
          .eq('group_members.user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createGroup({
    required String name,
    String? description,
  }) async {
    try {
      final userId = getCurrentUserId();

      final groupResponse =
          await _supabase.client
              .from('poker_groups')
              .insert({
                'name': name,
                'description': description,
                'creator_id': userId,
              })
              .select()
              .single();

      // Add creator as admin member
      await _supabase.client.from('group_members').insert({
        'group_id': groupResponse['id'],
        'user_id': userId,
        'role': 'admin',
      });

      return groupResponse;
    } catch (e) {
      debugPrint('Error creating group: $e');
      return null;
    }
  }

  static Future<void> deleteGroup(String groupId) async {
    try {
      await _supabase.client.from('poker_groups').delete().eq('id', groupId);
    } catch (e) {
      debugPrint('Error deleting group: $e');
      rethrow;
    }
  }

  // Games Operations
  static Future<List<Map<String, dynamic>>> fetchGroupGames(
    String groupId,
  ) async {
    try {
      final response = await _supabase.client
          .from('poker_games')
          .select('''
            *,
            saved_locations(name, address),
            user_profiles!poker_games_host_id_fkey(full_name),
            game_participants(id, user_id)
          ''')
          .eq('group_id', groupId)
          .order('scheduled_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching games: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> createGame({
    required String groupId,
    required String locationId,
    required String hostId,
    required DateTime scheduledAt,
    required double buyinAmount,
    required bool allowRebuys,
    double? rebuyAmount,
    List<String>? selectedPlayerIds,
    String? notes,
  }) async {
    try {
      final gameResponse =
          await _supabase.client
              .from('poker_games')
              .insert({
                'group_id': groupId,
                'location_id': locationId,
                'host_id': hostId,
                'scheduled_at': scheduledAt.toIso8601String(),
                'buyin_amount': buyinAmount,
                'allow_rebuys': allowRebuys,
                'rebuy_amount': rebuyAmount,
                'notes': notes,
                'status': 'scheduled',
              })
              .select()
              .single();

      // Add selected players as participants
      if (selectedPlayerIds != null && selectedPlayerIds.isNotEmpty) {
        final participants =
            selectedPlayerIds
                .map(
                  (playerId) => {
                    'game_id': gameResponse['id'],
                    'user_id': playerId,
                    'total_buyin': buyinAmount,
                  },
                )
                .toList();

        await _supabase.client.from('game_participants').insert(participants);
      }

      return gameResponse;
    } catch (e) {
      debugPrint('Error creating game: $e');
      rethrow;
    }
  }

  static Future<void> deleteGame(String gameId) async {
    try {
      await _supabase.client.from('poker_games').delete().eq('id', gameId);
    } catch (e) {
      debugPrint('Error deleting game: $e');
      rethrow;
    }
  }

  static Future<void> updateGameStatus(String gameId, String status) async {
    try {
      await _supabase.client
          .from('poker_games')
          .update({'status': status})
          .eq('id', gameId);
    } catch (e) {
      debugPrint('Error updating game status: $e');
      rethrow;
    }
  }

  // Locations Operations
  static Future<List<Map<String, dynamic>>> fetchUserLocations() async {
    try {
      final userId = _getCurrentUserIdSafe();
      if (userId == null) {
        debugPrint('User not authenticated, returning empty locations list');
        return [];
      }

      final response = await _supabase.client
          .from('saved_locations')
          .select()
          .eq('created_by', userId)
          .order('name', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching locations: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createLocation({
    required String name,
    required String address,
    String? city,
    String? state,
    String? postalCode,
  }) async {
    try {
      final userId = getCurrentUserId();

      final response =
          await _supabase.client
              .from('saved_locations')
              .insert({
                'name': name,
                'address': address,
                'city': city,
                'state': state,
                'postal_code': postalCode,
                'created_by': userId,
              })
              .select()
              .single();

      return response;
    } catch (e) {
      debugPrint('Error creating location: $e');
      return null;
    }
  }

  // Group Members Operations
  static Future<List<Map<String, dynamic>>> fetchGroupMembers(
    String groupId,
  ) async {
    try {
      final response = await _supabase.client
          .from('group_members')
          .select('''
            *,
            user_profiles(id, full_name, avatar_url)
          ''')
          .eq('group_id', groupId)
          .order('joined_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching group members: $e');
      rethrow;
    }
  }

  static Future<void> addGroupMember({
    required String groupId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      await _supabase.client.from('group_members').insert({
        'group_id': groupId,
        'user_id': userId,
        'role': role,
      });
    } catch (e) {
      debugPrint('Error adding group member: $e');
      rethrow;
    }
  }

  static Future<void> removeGroupMember(String memberId) async {
    try {
      await _supabase.client.from('group_members').delete().eq('id', memberId);
    } catch (e) {
      debugPrint('Error removing group member: $e');
      rethrow;
    }
  }

  // Game Participants Operations
  static Future<List<Map<String, dynamic>>> fetchGameParticipants(
    String gameId,
  ) async {
    try {
      final response = await _supabase.client
          .from('game_participants')
          .select('''
            *,
            user_profiles(full_name, avatar_url)
          ''')
          .eq('game_id', gameId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching game participants: $e');
      rethrow;
    }
  }

  static Future<void> updateParticipantResults({
    required String participantId,
    required double cashoutAmount,
  }) async {
    try {
      final participant =
          await _supabase.client
              .from('game_participants')
              .select()
              .eq('id', participantId)
              .single();

      final netProfit =
          cashoutAmount - ((participant['total_buyin'] as num?)?.toDouble() ?? 0);

      await _supabase.client
          .from('game_participants')
          .update({'cashout_amount': cashoutAmount, 'net_profit': netProfit})
          .eq('id', participantId);
    } catch (e) {
      debugPrint('Error updating participant results: $e');
      rethrow;
    }
  }

  // Payments Operations
  static Future<List<Map<String, dynamic>>> fetchParticipantPayments(
    String participantId,
  ) async {
    try {
      final response = await _supabase.client
          .from('payment_transactions')
          .select()
          .eq('participant_id', participantId)
          .order('transaction_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching payments: $e');
      rethrow;
    }
  }

  static Future<void> createPayment({
    required String participantId,
    required double amount,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      await _supabase.client.from('payment_transactions').insert({
        'participant_id': participantId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_status': 'paid',
        'notes': notes,
      });
    } catch (e) {
      debugPrint('Error creating payment: $e');
      rethrow;
    }
  }

  // Statistics Operations
  static Future<Map<String, dynamic>> fetchPlayerStats(String userId) async {
    try {
      final participants = await _supabase.client
          .from('game_participants')
          .select('''
            *,
            poker_games!inner(status, scheduled_at)
          ''')
          .eq('user_id', userId)
          .eq('poker_games.status', 'completed');

      double totalBuyin = 0;
      double totalCashout = 0;
      int gamesPlayed = participants.length;

      for (final participant in participants) {
        totalBuyin += (participant['total_buyin'] as num?)?.toDouble() ?? 0;
        totalCashout +=
            (participant['cashout_amount'] as num?)?.toDouble() ?? 0;
      }

      final netProfit = totalCashout - totalBuyin;

      return {
        'games_played': gamesPlayed,
        'total_buyin': totalBuyin,
        'total_cashout': totalCashout,
        'net_profit': netProfit,
        'win_rate': gamesPlayed > 0 ? (netProfit > 0 ? 1.0 : 0.0) : 0.0,
      };
    } catch (e) {
      debugPrint('Error fetching player stats: $e');
      rethrow;
    }
  }

  // Calendar View Operations
  static Future<List<Map<String, dynamic>>> fetchAllUserGames() async {
    try {
      final userId = _getCurrentUserIdSafe();
      if (userId == null) {
        debugPrint('User not authenticated, returning empty games list');
        return [];
      }

      final response = await _supabase.client
          .from('poker_games')
          .select('''
            *,
            saved_locations(name, address, city, state),
            user_profiles!poker_games_host_id_fkey(full_name),
            poker_groups(name),
            game_participants!inner(user_id, is_confirmed)
          ''')
          .eq('game_participants.user_id', userId)
          .order('scheduled_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching all user games: $e');
      return [];
    }
  }

  static Future<void> toggleGameRSVP({
    required String gameId,
    required bool isConfirmed,
  }) async {
    try {
      final userId = _getCurrentUserIdSafe();

      await _supabase.client
          .from('game_participants')
          .update({'is_confirmed': isConfirmed})
          .eq('game_id', gameId)
          .eq('user_id', userId ?? '');
    } catch (e) {
      debugPrint('Error toggling RSVP: $e');
      rethrow;
    }
  }
}