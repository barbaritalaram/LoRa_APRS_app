import 'package:hive/hive.dart';
import '../../domain/entities/message.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends Message {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String senderId;

  @HiveField(2)
  final String recipientId;

  @HiveField(3)
  final String payload;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  final bool isEncrypted;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    required this.timestamp,
    this.isEncrypted = false,
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

  factory MessageModel.fromEntity(Message entity) => MessageModel(
        id: entity.id,
        senderId: entity.senderId,
        recipientId: entity.recipientId,
        payload: entity.payload,
        timestamp: entity.timestamp,
        isEncrypted: entity.isEncrypted,
      );

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