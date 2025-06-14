import '../models/message_model.dart';

abstract class ILocalDatasource {
  Future<void> cacheMessage(MessageModel message);
  Future<List<MessageModel>> getAllMessages();
} 