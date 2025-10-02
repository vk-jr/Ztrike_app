import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';
import '../providers/auth_provider.dart';
import '../screens/profile/user_profile_screen.dart';

class PostCardWidget extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onDelete;

  const PostCardWidget({
    super.key,
    required this.post,
    this.onLike,
    this.onDelete,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  final PostRepository _postRepository = PostRepository();
  final TextEditingController _commentController = TextEditingController();
  List<CommentModel> _comments = [];
  bool _showComments = false;
  bool _isLoadingComments = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);
    try {
      final comments = await _postRepository.getComments(widget.post.id);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    try {
      await _postRepository.addComment(
        postId: widget.post.id,
        authorId: currentUser.id,
        content: _commentController.text.trim(),
        authorName: currentUser.displayName ?? currentUser.email,
        authorPhotoUrl: currentUser.photoUrl,
      );

      _commentController.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
        );
      }
    }
  }

  void _navigateToProfile(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    // If it's the current user's post, don't navigate - just show a message
    if (currentUser != null && widget.post.authorId == currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is your post! Go to Profile tab to view your profile'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to other user's profile
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: widget.post.authorId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isOwnPost = currentUser?.id == widget.post.authorId;
    final isLiked = currentUser != null && widget.post.likedBy.contains(currentUser.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => _navigateToProfile(context),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.post.authorPhotoUrl != null
                        ? CachedNetworkImageProvider(widget.post.authorPhotoUrl!)
                        : null,
                    child: widget.post.authorPhotoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.authorName ?? 'Unknown',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.post.createdAt != null
                              ? timeago.format(widget.post.createdAt!)
                              : '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isOwnPost)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete' && widget.onDelete != null) {
                        widget.onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Post Content
            Text(
              widget.post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            // Post Image
            if (widget.post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: widget.post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkSurfaceColor
                        : AppTheme.surfaceColor,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppTheme.darkSurfaceColor
                        : AppTheme.surfaceColor,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),

            // Actions Row
            Row(
              children: [
                TextButton.icon(
                  onPressed: widget.onLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? AppTheme.errorColor : null,
                  ),
                  label: Text('${widget.post.likes}'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _showComments = !_showComments);
                    if (_showComments && _comments.isEmpty) {
                      _loadComments();
                    }
                  },
                  icon: const Icon(Icons.comment_outlined),
                  label: Text(_comments.isEmpty ? 'Comment' : '${_comments.length}'),
                ),
              ],
            ),

            // Comments Section
            if (_showComments) ...[
              const Divider(),
              if (_isLoadingComments)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
                // Comment Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addComment,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Comments List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: comment.authorPhotoUrl != null
                                ? CachedNetworkImageProvider(comment.authorPhotoUrl!)
                                : null,
                            child: comment.authorPhotoUrl == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comment.authorName ?? 'Unknown',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.content,
                                    style: AppTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.createdAt != null
                                        ? timeago.format(comment.createdAt!)
                                        : '',
                                    style: AppTheme.caption,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
