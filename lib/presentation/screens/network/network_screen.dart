import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../providers/auth_provider.dart';
import '../profile/user_profile_screen.dart';

class NetworkScreen extends StatefulWidget {
  const NetworkScreen({super.key});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserRepository _userRepository = UserRepository();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _connections = [];
  List<UserModel> _pendingRequests = [];
  List<UserModel> _suggestedUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final connections = await _userRepository.getUsersByIds(currentUser.connections);
      final pendingRequests = await _userRepository.getUsersByIds(currentUser.pendingRequests);
      final suggested = await _userRepository.getSuggestedUsers(currentUser.id, limit: 50);

      setState(() {
        _connections = connections;
        _pendingRequests = pendingRequests;
        _suggestedUsers = suggested;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptRequest(String requesterId) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _userRepository.acceptConnectionRequest(currentUser.id, requesterId);
      await authProvider.loadCurrentUser();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request accepted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(String requesterId) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _userRepository.rejectConnectionRequest(currentUser.id, requesterId);
      await authProvider.loadCurrentUser();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request rejected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _sendConnectionRequest(String userId) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _userRepository.sendConnectionRequest(currentUser.id, userId);
      await authProvider.loadCurrentUser();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent')),
        );
      }
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
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search connections...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'My Connections'),
            Tab(text: 'Pending Requests'),
          ],
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // My Connections Tab
              _buildConnectionsTab(),
              // Pending Requests Tab
              _buildPendingRequestsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Connections', style: AppTheme.heading3),
          const SizedBox(height: 16),
          if (_connections.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No connections yet'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _connections.length,
              itemBuilder: (context, index) {
                final connection = _connections[index];
                return _UserCard(
                  user: connection,
                  trailing: Chip(
                    label: const Text('Connected'),
                    backgroundColor: AppTheme.successColor.withValues(alpha: 0.2),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),

          // People You May Know
          const Text('People You May Know', style: AppTheme.heading3),
          const SizedBox(height: 16),
          if (_suggestedUsers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No suggestions available'),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestedUsers.length,
              itemBuilder: (context, index) {
                final user = _suggestedUsers[index];
                return _UserCard(
                  user: user,
                  trailing: ElevatedButton(
                    onPressed: () => _sendConnectionRequest(user.id),
                    child: const Text('Connect'),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pendingRequests.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No pending requests'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingRequests.length,
      itemBuilder: (context, index) {
        final request = _pendingRequests[index];
        return _UserCard(
          user: request,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _acceptRequest(request.id),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
                child: const Text('Accept'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _rejectRequest(request.id),
                style: OutlinedButton.styleFrom(foregroundColor: AppTheme.errorColor),
                child: const Text('Reject'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final Widget? trailing;

  const _UserCard({required this.user, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserProfileScreen(userId: user.id),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundImage: user.photoUrl != null
              ? CachedNetworkImageProvider(user.photoUrl!)
              : null,
          child: user.photoUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(user.displayName ?? user.email),
        subtitle: Text(user.position ?? user.accountType ?? ''),
        trailing: trailing,
      ),
    );
  }
}
