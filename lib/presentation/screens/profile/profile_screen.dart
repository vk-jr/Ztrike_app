import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/team_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/team_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/post_card_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PostRepository _postRepository = PostRepository();
  final TeamRepository _teamRepository = TeamRepository();
  
  List<PostModel> _posts = [];
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureUserLoaded();
    });
  }

  Future<void> _ensureUserLoaded() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser == null) {
      await authProvider.loadCurrentUser();
    }
    await _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) {
      print('ProfileScreen: currentUser is null');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final posts = await _postRepository.getPostsByAuthor(currentUser.id);
      final achievements = await _teamRepository.getAchievements(currentUser.id);
      
      if (mounted) {
        setState(() {
          _posts = posts;
          _achievements = achievements;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('ProfileScreen: Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/sign-in');
              }
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;
          
          if (authProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('User not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await authProvider.loadCurrentUser();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cover Banner
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: user.bannerUrl == null
                        ? const LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.successColor],
                          )
                        : null,
                    image: user.bannerUrl != null
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(user.bannerUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),

                // Profile Content
                Transform.translate(
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
                              style: AppTheme.heading1.copyWith(fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                user.accountType?.toUpperCase() ?? 'USER',
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              user.email,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (user.bio != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                user.bio!,
                                style: AppTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ],
                            const SizedBox(height: 24),

                            // Stats Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _StatColumn(
                                  label: 'Connections',
                                  value: user.connections.length.toString(),
                                ),
                                _StatColumn(
                                  label: 'Teams',
                                  value: user.teams.length.toString(),
                                ),
                                _StatColumn(
                                  label: 'Leagues',
                                  value: user.leagues.length.toString(),
                                ),
                                _StatColumn(
                                  label: 'Post Views',
                                  value: user.postViews.toString(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Action Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.share),
                                  label: const Text('Share Profile'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit Profile'),
                                ),
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
                          Tab(text: 'Performance'),
                          Tab(text: 'Connections'),
                        ],
                      ),

                      // Tab Content
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Posts Tab
                            _buildPostsTab(),
                            // Performance Tab
                            _buildPerformanceTab(user),
                            // Connections Tab
                            _buildConnectionsTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return const Center(
        child: Text('No posts yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCardWidget(
            post: _posts[index],
            onLike: () async {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.currentUser != null) {
                await _postRepository.toggleLike(
                  _posts[index].id,
                  authProvider.currentUser!.id,
                );
                await _loadData();
              }
            },
            onDelete: () async {
              await _postRepository.deletePost(_posts[index].id);
              await _loadData();
            },
          ),
        );
      },
    );
  }

  Widget _buildPerformanceTab(user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Achievements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppTheme.warningColor),
                      const SizedBox(width: 8),
                      const Text('Achievements', style: AppTheme.heading3),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_achievements.isEmpty)
                    const Text('No achievements yet', style: AppTheme.caption)
                  else
                    ..._achievements.map((achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, size: 20, color: AppTheme.warningColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(achievement.title, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                    if (achievement.description != null)
                                      Text(achievement.description!, style: AppTheme.caption),
                                    if (achievement.year != null)
                                      Text('Year: ${achievement.year}', style: AppTheme.caption),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Performance Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Performance Stats', style: AppTheme.heading3),
                  const SizedBox(height: 16),
                  _StatRow(label: 'Position', value: user.position ?? 'N/A'),
                  _StatRow(label: 'Matches Played', value: user.matchesPlayed.toString()),
                  _StatRow(label: 'Goals', value: user.goals.toString()),
                  _StatRow(label: 'Assists', value: user.assists.toString()),
                  _StatRow(label: 'MVPs', value: user.mvps.toString()),
                  _StatRow(label: 'Saves', value: user.saves.toString()),
                  _StatRow(label: 'Wins / Losses', value: '${user.wins} / ${user.losses}'),
                  _StatRow(label: 'Win Rate', value: '${user.winRate.toStringAsFixed(1)}%'),
                  _StatRow(label: 'Clean Sheets', value: user.cleanSheets.toString()),
                  _StatRow(label: 'Rank Score', value: user.rankScore.toStringAsFixed(0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsTab() {
    return const Center(
      child: Text('Connections will be displayed here'),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTheme.heading2),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMedium),
          Text(value, style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
