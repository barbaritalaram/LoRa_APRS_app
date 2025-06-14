import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required String id,
    required String senderId,
    required String recipientId,
    required String payload,
    required DateTime timestamp,
    bool isEncrypted = false,
  }) : super(
          id: id,
          senderId: senderId,
          recipientId: recipientId,
          payload: payload,
          timestamp: timestamp,
          isEncrypted: isEncrypted,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['senderId'],
      recipientId: json['recipientId'],
      payload: json['payload'],
      timestamp: DateTime.parse(json['timestamp']),
      isEncrypted: json['isEncrypted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'isEncrypted': isEncrypted,
    };
  }
} 