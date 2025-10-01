import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/profile_card_widget.dart';
import '../../widgets/post_card_widget.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PostRepository _postRepository = PostRepository();
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<PostModel> _posts = [];
  bool _isLoading = false;
  bool _isCreatingPost = false;
  File? _selectedImage;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await _postRepository.getPosts(offset: _currentPage * 20, limit: 20);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading posts: $e')),
        );
      }
    }
  }

  Future<void> _createPost() async {
    if (_postController.text.trim().isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    setState(() => _isCreatingPost = true);

    try {
      await _postRepository.createPost(
        authorId: currentUser.id,
        content: _postController.text.trim(),
        authorName: currentUser.displayName ?? currentUser.email,
        authorPhotoUrl: currentUser.photoUrl,
        imageFile: _selectedImage,
      );

      _postController.clear();
      setState(() {
        _selectedImage = null;
        _isCreatingPost = false;
      });

      await _loadPosts();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully')),
        );
      }
    } catch (e) {
      setState(() => _isCreatingPost = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating post: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: Row(
        children: [
          // Left Sidebar - Profile Card
          if (MediaQuery.of(context).size.width > 900)
            SizedBox(
              width: 280,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return ProfileCardWidget(user: authProvider.currentUser);
                  },
                ),
              ),
            ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Post Creation Card
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      final user = authProvider.currentUser;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: user?.photoUrl != null
                                        ? CachedNetworkImageProvider(user!.photoUrl!)
                                        : null,
                                    child: user?.photoUrl == null
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _postController,
                                      maxLines: 3,
                                      decoration: const InputDecoration(
                                        hintText: "What's on your mind?",
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedImage != null) ...[
                                const SizedBox(height: 12),
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImage!,
                                        height: 200,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, color: Colors.white),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                        ),
                                        onPressed: () => setState(() => _selectedImage = null),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image_outlined),
                                    onPressed: _pickImage,
                                    tooltip: 'Add Image',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.videocam_outlined),
                                    onPressed: () {
                                      // TODO: Implement video
                                    },
                                    tooltip: 'Add Video',
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: _isCreatingPost ? null : _createPost,
                                    child: _isCreatingPost
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Post'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Posts Feed
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_posts.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: Text('No posts yet. Be the first to post!'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
                                await _loadPosts();
                              }
                            },
                            onDelete: () async {
                              await _postRepository.deletePost(_posts[index].id);
                              await _loadPosts();
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Right Sidebar
          if (MediaQuery.of(context).size.width > 1200)
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upcoming Matches Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Upcoming Matches',
                                  style: AppTheme.heading3,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No upcoming matches',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // People You May Know
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'People You May Know',
                              style: AppTheme.heading3,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No suggestions available',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
