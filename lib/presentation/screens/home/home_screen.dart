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
import 'dart:typed_data';

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
  XFile? _selectedImage;
  XFile? _selectedVideo;
  final int _currentPage = 0;

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
        videoFile: _selectedVideo,
      );

      _postController.clear();
      setState(() {
        _selectedImage = null;
        _selectedVideo = null;
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
      setState(() {
        _selectedImage = image;
        _selectedVideo = null; // Clear video if image is selected
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImage = null; // Clear image if video is selected
      });
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
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundImage: user?.photoUrl != null
                                        ? CachedNetworkImageProvider(user!.photoUrl!)
                                        : null,
                                    child: user?.photoUrl == null
                                        ? const Icon(Icons.person, size: 20)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _postController,
                                      maxLines: 1,
                                      decoration: const InputDecoration(
                                        hintText: "What's on your mind?",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(vertical: 8),
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
                                      child: FutureBuilder<Uint8List>(
                                        future: _selectedImage!.readAsBytes(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data!,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            );
                                          }
                                          return const SizedBox(
                                            height: 200,
                                            child: Center(child: CircularProgressIndicator()),
                                          );
                                        },
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
                              if (_selectedVideo != null) ...[
                                const SizedBox(height: 12),
                                Stack(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.videocam, size: 48, color: Colors.white),
                                            SizedBox(height: 8),
                                            Text(
                                              'Video selected',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                          ],
                                        ),
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
                                        onPressed: () => setState(() => _selectedVideo = null),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image_outlined, size: 22),
                                    onPressed: _pickImage,
                                    tooltip: 'Add Image',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.videocam_outlined, size: 22),
                                    onPressed: _pickVideo,
                                    tooltip: 'Add Video',
                                    padding: const EdgeInsets.all(8),
                                    constraints: const BoxConstraints(),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: _isCreatingPost ? null : _createPost,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                      minimumSize: const Size(0, 0),
                                    ),
                                    child: _isCreatingPost
                                        ? const SizedBox(
                                            height: 14,
                                            width: 14,
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
            const SizedBox(
              width: 300,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Upcoming Matches Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Upcoming Matches',
                                  style: AppTheme.heading3,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No upcoming matches',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // People You May Know
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'People You May Know',
                                  style: AppTheme.heading3,
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
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
