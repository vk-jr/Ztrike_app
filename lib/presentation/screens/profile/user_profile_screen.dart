import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../widgets/post_card_widget.dart';

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
  
  List<PostModel> _userPosts = [];
  bool _isLoading = false;

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

          return CustomScrollView(
            slivers: [
              // App Bar with Banner
              SliverAppBar(
                expandedHeight: 200,
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
                child: Transform.translate(
                  offset: const Offset(0, -50),
                  child: Column(
                    children: [
                      // Profile Picture
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 56,
                          backgroundImage: user.photoUrl != null
                              ? CachedNetworkImageProvider(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // User Info
                      Padding(
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
                            if (user.position != null) ...[
                              const SizedBox(height: 4),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
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
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    ),
                  ],
                ),
              ),
            ],
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
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
