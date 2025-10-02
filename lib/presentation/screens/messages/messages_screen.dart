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
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with WidgetsBindingObserver {
  final MessageRepository _messageRepository = MessageRepository();
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConversations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload conversations when app comes back to foreground
      _loadConversations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload if it's been more than 2 seconds since last load
    if (_lastLoadTime == null || 
        DateTime.now().difference(_lastLoadTime!) > const Duration(seconds: 2)) {
      _loadConversations();
    }
  }

  Future<void> _loadConversations() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    // Prevent too frequent reloads
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < const Duration(milliseconds: 500)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final conversations = await _messageRepository.getConversations(currentUser.id);
      setState(() {
        _conversations = conversations;
        _isLoading = false;
        _lastLoadTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openChat(UserModel partner) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(otherUser: partner),
      ),
    );
    // Reload conversations when coming back
    _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Conversations List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start chatting with your connections!',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadConversations,
                        child: ListView.builder(
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = _conversations[index];
                            final lastMessage = conversation['lastMessage'] as MessageModel;
                            final partnerId = conversation['partnerId'] as String;
                            final authProvider = context.read<AuthProvider>();
                            final isUnread = !lastMessage.read && 
                                           lastMessage.receiverId == authProvider.currentUser?.id;

                            return FutureBuilder<UserModel?>(
                              future: _userRepository.getUserById(partnerId),
                              builder: (context, snapshot) {
                                final partner = snapshot.data;
                                if (partner == null) {
                                  return const SizedBox.shrink();
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isUnread 
                                        ? (isDark 
                                            ? AppTheme.primaryColor.withOpacity(0.05) 
                                            : AppTheme.primaryColor.withOpacity(0.03))
                                        : null,
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: partner.photoUrl != null
                                              ? CachedNetworkImageProvider(partner.photoUrl!)
                                              : null,
                                          child: partner.photoUrl == null 
                                              ? const Icon(Icons.person, size: 28) 
                                              : null,
                                        ),
                                        if (isUnread)
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryColor,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isDark ? AppTheme.darkBackgroundColor : Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    title: Text(
                                      partner.displayName ?? partner.email,
                                      style: TextStyle(
                                        fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        lastMessage.content,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          lastMessage.createdAt != null
                                              ? timeago.format(lastMessage.createdAt!)
                                              : '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isUnread 
                                                ? AppTheme.primaryColor 
                                                : (isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary),
                                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _openChat(partner),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
