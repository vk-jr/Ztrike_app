class PostModel {
  final String id;
  final String content;
  final String authorId;
  final String? imageUrl;
  final String? videoUrl;
  final int likes;
  final List<String> likedBy;
  final String? authorName;
  final String? authorPhotoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.content,
    required this.authorId,
    this.imageUrl,
    this.videoUrl,
    this.likes = 0,
    this.likedBy = const [],
    this.authorName,
    this.authorPhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      content: json['content'] as String,
      authorId: json['author_id'] as String,
      imageUrl: json['image_url'] as String?,
      videoUrl: json['video_url'] as String?,
      likes: json['likes'] as int? ?? 0,
      likedBy: (json['liked_by'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      authorName: json['author_name'] as String?,
      authorPhotoUrl: json['author_photo_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author_id': authorId,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'likes': likes,
      'liked_by': likedBy,
      'author_name': authorName,
      'author_photo_url': authorPhotoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? content,
    String? authorId,
    String? imageUrl,
    String? videoUrl,
    int? likes,
    List<String>? likedBy,
    String? authorName,
    String? authorPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      authorName: authorName ?? this.authorName,
      authorPhotoUrl: authorPhotoUrl ?? this.authorPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final String? authorName;
  final String? authorPhotoUrl;
  final DateTime? createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.authorName,
    this.authorPhotoUrl,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      authorName: json['author_name'] as String?,
      authorPhotoUrl: json['author_photo_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'author_name': authorName,
      'author_photo_url': authorPhotoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
