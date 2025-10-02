import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post_card_widget.dart';
import '../messages/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostRepository _postRepository = PostRepository();
  final UserRepository _userRepository = UserRepository();
  
  List<PostModel> _userPosts = [];
  bool _isLoading = false;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserPosts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postRepository.getPostsByAuthor(widget.userId);
      if (mounted) {
        setState(() {
          _userPosts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendConnectionRequest() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isActionLoading = true);
    try {
      await _userRepository.sendConnectionRequest(currentUser.id, widget.userId);
      await authProvider.loadCurrentUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent')),
        );
        setState(() => _isActionLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _openMessages(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(otherUser: user),
      ),
    );
  }

  bool _isConnected(UserModel user) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return false;
    // Check if user is in my connections
    return currentUser.connections.contains(user.id);
  }

  bool _hasRequestPending(UserModel user) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return false;
    // Only show pending if I sent them a request AND they haven't accepted yet
    // (if they accepted, we'd both be in connections)
    return currentUser.sentRequests.contains(user.id) && 
           !currentUser.connections.contains(user.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel?>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // App Bar with Banner
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: user.bannerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user.bannerUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.successColor],
                            ),
                          ),
                        ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile Picture - positioned to be fully visible
                    Transform.translate(
                      offset: const Offset(0, -70),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? AppTheme.darkSurfaceColor 
                              : Colors.white,
                          backgroundImage: user.photoUrl != null
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                      ),
                    ),

                    // User Info
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Text(
                              user.displayName ?? user.email,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            
                            // Account Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppTheme.primaryColor.withOpacity(0.2)
                                    : AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                _formatAccountType(user.accountType ?? 'athlete'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            
                            if (user.position != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                user.position!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                            if (user.bio != null && user.bio!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                user.bio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem('Posts', _userPosts.length),
                                _buildStatItem('Connections', user.connections.length),
                                _buildStatItem('MVPs', user.mvps),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _isConnected(user)
                                      ? OutlinedButton.icon(
                                          onPressed: null,
                                          icon: const Icon(Icons.check_circle),
                                          label: const Text('Connected'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: AppTheme.successColor,
                                            side: const BorderSide(color: AppTheme.successColor),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        )
                                      : _hasRequestPending(user)
                                          ? OutlinedButton.icon(
                                              onPressed: null,
                                              icon: const Icon(Icons.schedule),
                                              label: const Text('Pending'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: AppTheme.warningColor,
                                                side: const BorderSide(color: AppTheme.warningColor),
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            )
                                          : ElevatedButton.icon(
                                              onPressed: _isActionLoading ? null : _sendConnectionRequest,
                                              icon: _isActionLoading
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    )
                                                  : const Icon(Icons.person_add),
                                              label: const Text('Connect'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppTheme.primaryColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                              ),
                                            ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openMessages(user),
                                    icon: const Icon(Icons.message),
                                    label: const Text('Message'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryColor,
                                      side: const BorderSide(color: AppTheme.primaryColor),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Posts'),
                        Tab(text: 'About'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                // Posts Tab
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _userPosts.isEmpty
                        ? const Center(child: Text('No posts yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _userPosts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PostCardWidget(post: _userPosts[index]),
                              );
                            },
                          ),

                // About Tab
                ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildInfoSection('Email', user.email),
                    if (user.position != null)
                      _buildInfoSection('Position', user.position!),
                    _buildInfoSection('Account Type', _formatAccountType(user.accountType ?? 'athlete')),
                    _buildInfoSection('Goals', '${user.goals}'),
                    _buildInfoSection('Assists', '${user.assists}'),
                    _buildInfoSection('MVPs', '${user.mvps}'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatAccountType(String accountType) {
    return accountType[0].toUpperCase() + accountType.substring(1);
  }

  Future<UserModel?> _getUserProfile() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', widget.userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }
}
