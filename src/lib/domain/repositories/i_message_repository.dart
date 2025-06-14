import '../entities/message.dart';

abstract class IMessageRepository {
  Future<void> sendMessage(Message message);
  Stream<Message> getMessages();
  Future<void> saveMessage(Message message);
} 