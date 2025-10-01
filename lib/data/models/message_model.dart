class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final bool read;
  final String? senderName;
  final String? senderPhotoUrl;
  final String? receiverName;
  final String? receiverPhotoUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.read = false,
    this.senderName,
    this.senderPhotoUrl,
    this.receiverName,
    this.receiverPhotoUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      read: json['read'] as bool? ?? false,
      senderName: json['sender_name'] as String?,
      senderPhotoUrl: json['sender_photo_url'] as String?,
      receiverName: json['receiver_name'] as String?,
      receiverPhotoUrl: json['receiver_photo_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'read': read,
      'sender_name': senderName,
      'sender_photo_url': senderPhotoUrl,
      'receiver_name': receiverName,
      'receiver_photo_url': receiverPhotoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    bool? read,
    String? senderName,
    String? senderPhotoUrl,
    String? receiverName,
    String? receiverPhotoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      read: read ?? this.read,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      receiverName: receiverName ?? this.receiverName,
      receiverPhotoUrl: receiverPhotoUrl ?? this.receiverPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
