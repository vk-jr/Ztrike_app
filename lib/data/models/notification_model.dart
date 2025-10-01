class NotificationModel {
  final String id;
  final String userId;
  final String fromId;
  final String type;
  final String title;
  final String? description;
  final bool read;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.fromId,
    required this.type,
    required this.title,
    this.description,
    this.read = false,
    this.metadata,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fromId: json['from_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      read: json['read'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'from_id': fromId,
      'type': type,
      'title': title,
      'description': description,
      'read': read,
      'metadata': metadata,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? fromId,
    String? type,
    String? title,
    String? description,
    bool? read,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fromId: fromId ?? this.fromId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      read: read ?? this.read,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
