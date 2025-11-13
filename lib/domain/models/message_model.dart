// lib/domain/models/message_model.dart

class MessageModel {
  final String? id;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.createdAt,
  });

  /// تحويل من JSON إلى كائن MessageModel
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String?,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      text: (json['text'] ?? '') as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// تحويل الكائن إلى JSON (للإرسال إلى Supabase)
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'sender_id': senderId,
    'receiver_id': receiverId,
    'text': text,
    'created_at': createdAt.toIso8601String(),
  };
}
