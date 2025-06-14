class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String payload;
  final DateTime timestamp;
  final bool isEncrypted;

  Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.payload,
    required this.timestamp,
    this.isEncrypted = false,
  });
} 