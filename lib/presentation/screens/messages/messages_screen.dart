import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_theme.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final MessageRepository _messageRepository = MessageRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _conversations = [];
  UserModel? _selectedPartner;
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);
    try {
      final conversations = await _messageRepository.getConversations(currentUser.id);
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectConversation(String partnerId) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final partner = await _userRepository.getUserById(partnerId);
    final messages = await _messageRepository.getMessages(currentUser.id, partnerId);

    setState(() {
      _selectedPartner = partner;
      _messages = messages;
    });

    // Mark as read
    await _messageRepository.markAsRead(currentUser.id, partnerId);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedPartner == null) return;

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _messageRepository.sendMessage(
        senderId: currentUser.id,
        receiverId: _selectedPartner!.id,
        content: _messageController.text.trim(),
        senderName: currentUser.displayName ?? currentUser.email,
        senderPhotoUrl: currentUser.photoUrl,
        receiverName: _selectedPartner!.displayName ?? _selectedPartner!.email,
        receiverPhotoUrl: _selectedPartner!.photoUrl,
      );

      _messageController.clear();
      await _selectConversation(_selectedPartner!.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Conversations List
        SizedBox(
          width: MediaQuery.of(context).size.width > 900 ? 300 : MediaQuery.of(context).size.width * 0.35,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search messages...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                        ? const Center(child: Text('No conversations'))
                        : ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conversation = _conversations[index];
                              final lastMessage = conversation['lastMessage'] as MessageModel;
                              final partnerId = conversation['partnerId'] as String;

                              return FutureBuilder<UserModel?>(
                                future: _userRepository.getUserById(partnerId),
                                builder: (context, snapshot) {
                                  final partner = snapshot.data;
                                  if (partner == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: partner.photoUrl != null
                                          ? CachedNetworkImageProvider(partner.photoUrl!)
                                          : null,
                                      child: partner.photoUrl == null ? const Icon(Icons.person) : null,
                                    ),
                                    title: Text(partner.displayName ?? partner.email),
                                    subtitle: Text(
                                      lastMessage.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Text(
                                      lastMessage.createdAt != null
                                          ? timeago.format(lastMessage.createdAt!)
                                          : '',
                                      style: AppTheme.caption,
                                    ),
                                    selected: _selectedPartner?.id == partnerId,
                                    onTap: () => _selectConversation(partnerId),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),

        // Chat Area
        Expanded(
          child: _selectedPartner == null
              ? const Center(child: Text('Select a conversation'))
              : Column(
                  children: [
                    // Chat Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: _selectedPartner!.photoUrl != null
                                ? CachedNetworkImageProvider(_selectedPartner!.photoUrl!)
                                : null,
                            child: _selectedPartner!.photoUrl == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedPartner!.displayName ?? _selectedPartner!.email,
                            style: AppTheme.heading3,
                          ),
                        ],
                      ),
                    ),

                    // Messages
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[_messages.length - 1 - index];
                          final authProvider = context.read<AuthProvider>();
                          final isSentByMe = message.senderId == authProvider.currentUser?.id;

                          return Align(
                            alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.6,
                              ),
                              decoration: BoxDecoration(
                                color: isSentByMe ? AppTheme.primaryColor : AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.content,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isSentByMe ? Colors.black : AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    message.createdAt != null
                                        ? timeago.format(message.createdAt!)
                                        : '',
                                    style: AppTheme.caption.copyWith(
                                      color: isSentByMe ? Colors.black54 : AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Message Input
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: AppTheme.borderColor)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
