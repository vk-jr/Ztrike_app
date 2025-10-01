import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';

class MessageRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get conversations for user
  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final messages = (response as List).map((json) => MessageModel.fromJson(json)).toList();
      
      // Group by conversation partner
      Map<String, MessageModel> conversationsMap = {};
      for (var message in messages) {
        final partnerId = message.senderId == userId ? message.receiverId : message.senderId;
        if (!conversationsMap.containsKey(partnerId)) {
          conversationsMap[partnerId] = message;
        }
      }

      return conversationsMap.entries.map((entry) => {
        'partnerId': entry.key,
        'lastMessage': entry.value,
      }).toList();
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  // Get messages between two users
  Future<List<MessageModel>> getMessages(String userId, String partnerId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId,receiver_id.eq.$partnerId),and(sender_id.eq.$partnerId,receiver_id.eq.$userId)')
          .order('created_at', ascending: true);

      return (response as List).map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  // Send message
  Future<MessageModel> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String? senderName,
    String? senderPhotoUrl,
    String? receiverName,
    String? receiverPhotoUrl,
  }) async {
    try {
      final response = await _supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'content': content,
        'sender_name': senderName,
        'sender_photo_url': senderPhotoUrl,
        'receiver_name': receiverName,
        'receiver_photo_url': receiverPhotoUrl,
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      // Create notification
      await _supabase.from('notifications').insert({
        'user_id': receiverId,
        'from_id': senderId,
        'type': 'message',
        'title': 'New Message',
        'description': '$senderName sent you a message',
        'created_at': DateTime.now().toIso8601String(),
      });

      return MessageModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String userId, String partnerId) async {
    try {
      await _supabase
          .from('messages')
          .update({'read': true})
          .eq('sender_id', partnerId)
          .eq('receiver_id', userId);
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // Get unread message count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select()
          .eq('receiver_id', userId)
          .eq('read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // Stream messages (real-time)
  Stream<List<MessageModel>> streamMessages(String userId, String partnerId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) {
          // Filter messages between the two users
          final filtered = data.where((msg) {
            final senderId = msg['sender_id'];
            final receiverId = msg['receiver_id'];
            return (senderId == userId && receiverId == partnerId) ||
                   (senderId == partnerId && receiverId == userId);
          }).toList();
          return filtered.map((json) => MessageModel.fromJson(json)).toList();
        });
  }
}
