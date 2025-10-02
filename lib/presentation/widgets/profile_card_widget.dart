import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';

class ProfileCardWidget extends StatelessWidget {
  final UserModel? user;

  const ProfileCardWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: user!.bannerUrl == null
                  ? const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.successColor],
                    )
                  : null,
              image: user!.bannerUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(user!.bannerUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
          ),

          // Profile Picture
          Transform.translate(
            offset: const Offset(0, -30),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: user!.photoUrl != null
                        ? CachedNetworkImageProvider(user!.photoUrl!)
                        : null,
                    child: user!.photoUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                ),
              ],
            ),
          ),

          // User Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Text(
                  user!.displayName ?? user!.email,
                  style: AppTheme.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user!.accountType?.toUpperCase() ?? 'USER',
                    style: AppTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user!.email,
                  style: AppTheme.caption,
                  textAlign: TextAlign.center,
                ),
                if (user!.bio != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    user!.bio!,
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),

                // Stats Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Connections',
                        value: user!.connections.length.toString(),
                      ),
                      _StatItem(
                        label: 'Post Views',
                        value: user!.postViews.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Teams',
                        value: user!.teams.length.toString(),
                      ),
                      _StatItem(
                        label: 'Leagues',
                        value: user!.leagues.length.toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // View Profile Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                  child: const Text('View Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.heading3,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.caption,
        ),
      ],
    );
  }
}
