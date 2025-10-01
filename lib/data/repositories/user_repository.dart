import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get user by auth ID
  Future<UserModel?> getUserByAuthId(String authId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      // Add display_name_lower if display_name is being updated (same as display_name)
      if (updates.containsKey('display_name')) {
        updates['display_name_lower'] = updates['display_name'];
      }
      
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query, {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .ilike('display_name_lower', '%${query.toLowerCase()}%')
          .limit(limit);

      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get users by account type
  Future<List<UserModel>> getUsersByAccountType(String accountType, {int limit = 20}) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('account_type', accountType)
          .limit(limit);

      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Get multiple users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];
      
      final response = await _supabase
          .from('users')
          .select()
          .inFilter('id', userIds);

      return (response as List).map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  // Send connection request
  Future<void> sendConnectionRequest(String fromUserId, String toUserId) async {
    try {
      // Add to sender's sent_requests
      await _supabase.rpc('array_append', params: {
        'table_name': 'users',
        'column_name': 'sent_requests',
        'id': fromUserId,
        'value': toUserId,
      });

      // Add to receiver's pending_requests
      await _supabase.rpc('array_append', params: {
        'table_name': 'users',
        'column_name': 'pending_requests',
        'id': toUserId,
        'value': fromUserId,
      });

      // Create notification
      final fromUser = await getUserById(fromUserId);
      if (fromUser != null) {
        await _supabase.from('notifications').insert({
          'user_id': toUserId,
          'from_id': fromUserId,
          'type': AppConstants.notificationTypeConnectionRequest,
          'title': 'New Connection Request',
          'description': '${fromUser.displayName ?? 'Someone'} wants to connect with you',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      // Fallback to manual array update if RPC doesn't exist
      try {
        // Get current user data
        final fromUserData = await _supabase.from('users').select('sent_requests').eq('id', fromUserId).single();
        final toUserData = await _supabase.from('users').select('pending_requests').eq('id', toUserId).single();

        List<String> fromSentRequests = List<String>.from(fromUserData['sent_requests'] ?? []);
        List<String> toPendingRequests = List<String>.from(toUserData['pending_requests'] ?? []);

        if (!fromSentRequests.contains(toUserId)) {
          fromSentRequests.add(toUserId);
        }
        if (!toPendingRequests.contains(fromUserId)) {
          toPendingRequests.add(fromUserId);
        }

        await _supabase.from('users').update({'sent_requests': fromSentRequests}).eq('id', fromUserId);
        await _supabase.from('users').update({'pending_requests': toPendingRequests}).eq('id', toUserId);

        // Create notification
        final fromUser = await getUserById(fromUserId);
        if (fromUser != null) {
          await _supabase.from('notifications').insert({
            'user_id': toUserId,
            'from_id': fromUserId,
            'type': AppConstants.notificationTypeConnectionRequest,
            'title': 'New Connection Request',
            'description': '${fromUser.displayName ?? 'Someone'} wants to connect with you',
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } catch (fallbackError) {
        throw Exception('Failed to send connection request: $fallbackError');
      }
    }
  }

  // Accept connection request
  Future<void> acceptConnectionRequest(String userId, String requesterId) async {
    try {
      // Get current data
      final userData = await _supabase.from('users').select('pending_requests, connections').eq('id', userId).single();
      final requesterData = await _supabase.from('users').select('sent_requests, connections').eq('id', requesterId).single();

      // Update arrays
      List<String> userPendingRequests = List<String>.from(userData['pending_requests'] ?? []);
      List<String> userConnections = List<String>.from(userData['connections'] ?? []);
      List<String> requesterSentRequests = List<String>.from(requesterData['sent_requests'] ?? []);
      List<String> requesterConnections = List<String>.from(requesterData['connections'] ?? []);

      userPendingRequests.remove(requesterId);
      if (!userConnections.contains(requesterId)) {
        userConnections.add(requesterId);
      }

      requesterSentRequests.remove(userId);
      if (!requesterConnections.contains(userId)) {
        requesterConnections.add(userId);
      }

      // Update database
      await _supabase.from('users').update({
        'pending_requests': userPendingRequests,
        'connections': userConnections,
      }).eq('id', userId);

      await _supabase.from('users').update({
        'sent_requests': requesterSentRequests,
        'connections': requesterConnections,
      }).eq('id', requesterId);

      // Create notification
      final user = await getUserById(userId);
      if (user != null) {
        await _supabase.from('notifications').insert({
          'user_id': requesterId,
          'from_id': userId,
          'type': AppConstants.notificationTypeConnectionAccepted,
          'title': 'Connection Request Accepted',
          'description': '${user.displayName ?? 'Someone'} accepted your connection request',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to accept connection request: $e');
    }
  }

  // Reject connection request
  Future<void> rejectConnectionRequest(String userId, String requesterId) async {
    try {
      // Get current data
      final userData = await _supabase.from('users').select('pending_requests').eq('id', userId).single();
      final requesterData = await _supabase.from('users').select('sent_requests').eq('id', requesterId).single();

      // Update arrays
      List<String> userPendingRequests = List<String>.from(userData['pending_requests'] ?? []);
      List<String> requesterSentRequests = List<String>.from(requesterData['sent_requests'] ?? []);

      userPendingRequests.remove(requesterId);
      requesterSentRequests.remove(userId);

      // Update database
      await _supabase.from('users').update({'pending_requests': userPendingRequests}).eq('id', userId);
      await _supabase.from('users').update({'sent_requests': requesterSentRequests}).eq('id', requesterId);
    } catch (e) {
      throw Exception('Failed to reject connection request: $e');
    }
  }

  // Get suggested users (users not connected)
  Future<List<UserModel>> getSuggestedUsers(String currentUserId, {int limit = 10}) async {
    try {
      final currentUser = await getUserById(currentUserId);
      if (currentUser == null) return [];

      final response = await _supabase
          .from('users')
          .select()
          .neq('id', currentUserId)
          .limit(limit * 2); // Get more to filter

      final allUsers = (response as List).map((json) => UserModel.fromJson(json)).toList();
      
      // Filter out already connected users and pending requests
      final suggested = allUsers.where((user) {
        return !currentUser.connections.contains(user.id) &&
               !currentUser.pendingRequests.contains(user.id) &&
               !currentUser.sentRequests.contains(user.id);
      }).take(limit).toList();

      return suggested;
    } catch (e) {
      throw Exception('Failed to get suggested users: $e');
    }
  }

  // Calculate and update rank score
  Future<void> updateRankScore(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return;

      // Rank calculation: MVPs × 100 + Goals × 50 + Assists × 30
      final rankScore = (user.mvps * 100) + (user.goals * 50) + (user.assists * 30);

      await _supabase
          .from('users')
          .update({'rank_score': rankScore.toDouble()})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update rank score: $e');
    }
  }
}
