import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';
import '../../core/constants/app_constants.dart';

class PostRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all posts with pagination
  Future<List<PostModel>> getPosts({int offset = 0, int limit = 20}) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Get posts by author
  Future<List<PostModel>> getPostsByAuthor(String authorId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('author_id', authorId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => PostModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get posts: $e');
    }
  }

  // Create post
  Future<PostModel> createPost({
    required String authorId,
    required String content,
    String? authorName,
    String? authorPhotoUrl,
    XFile? imageFile,
    XFile? videoFile,
  }) async {
    try {
      String? imageUrl;
      String? videoUrl;

      // Upload image if provided
      if (imageFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
        final bytes = await imageFile.readAsBytes();
        
        await _supabase.storage
            .from(AppConstants.postsBucket)
            .uploadBinary(fileName, bytes);
        
        imageUrl = _supabase.storage
            .from(AppConstants.postsBucket)
            .getPublicUrl(fileName);
      }

      // Upload video if provided
      if (videoFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${videoFile.name}';
        final bytes = await videoFile.readAsBytes();
        
        await _supabase.storage
            .from(AppConstants.postsBucket)
            .uploadBinary(fileName, bytes);
        
        videoUrl = _supabase.storage
            .from(AppConstants.postsBucket)
            .getPublicUrl(fileName);
      }

      final response = await _supabase.from('posts').insert({
        'author_id': authorId,
        'content': content,
        'author_name': authorName,
        'author_photo_url': authorPhotoUrl,
        'image_url': imageUrl,
        'video_url': videoUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select().single();

      return PostModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  // Like/unlike post
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final post = await _supabase
          .from('posts')
          .select()
          .eq('id', postId)
          .single();

      List<String> likedBy = List<String>.from(post['liked_by'] ?? []);
      int likes = post['likes'] ?? 0;

      if (likedBy.contains(userId)) {
        // Unlike
        likedBy.remove(userId);
        likes = (likes - 1).clamp(0, double.infinity).toInt();
      } else {
        // Like
        likedBy.add(userId);
        likes++;
      }

      await _supabase.from('posts').update({
        'liked_by': likedBy,
        'likes': likes,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', postId);
    } catch (e) {
      throw Exception('Failed to toggle like: $e');
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _supabase.from('posts').delete().eq('id', postId);
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  // Get comments for post
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final response = await _supabase
          .from('comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => CommentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get comments: $e');
    }
  }

  // Add comment
  Future<CommentModel> addComment({
    required String postId,
    required String authorId,
    required String content,
    String? authorName,
    String? authorPhotoUrl,
  }) async {
    try {
      final response = await _supabase.from('comments').insert({
        'post_id': postId,
        'author_id': authorId,
        'content': content,
        'author_name': authorName,
        'author_photo_url': authorPhotoUrl,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      return CommentModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }
}
