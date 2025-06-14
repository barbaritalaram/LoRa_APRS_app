import '../models/message_model.dart';

abstract class ILocalDatasource {
  Future<void> saveMessage(MessageModel message);
  Future<MessageModel?> getMessage(String id);
} 