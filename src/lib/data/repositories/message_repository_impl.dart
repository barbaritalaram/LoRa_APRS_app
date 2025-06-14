import '../../domain/entities/message.dart';
import '../../domain/repositories/i_message_repository.dart';
import '../datasources/i_local_datasource.dart';
import '../datasources/i_remote_datasource.dart';
import '../models/message_model.dart';

class MessageRepositoryImpl implements IMessageRepository {
  final IRemoteDatasource remoteDatasource;
  final ILocalDatasource localDatasource;

  MessageRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Stream<Message> getMessages() {
    // For now, just streams from remote. Could be combined with local.
    return remoteDatasource.getMessageStream();
  }

  @override
  Future<void> saveMessage(Message message) {
    final messageModel = MessageModel(
      id: message.id,
      senderId: message.senderId,
      recipientId: message.recipientId,
      payload: message.payload,
      timestamp: message.timestamp,
      isEncrypted: message.isEncrypted,
    );
    return localDatasource.cacheMessage(messageModel);
  }

  @override
  Future<void> sendMessage(Message message) {
     final messageModel = MessageModel(
      id: message.id,
      senderId: message.senderId,
      recipientId: message.recipientId,
      payload: message.payload,
      timestamp: message.timestamp,
      isEncrypted: message.isEncrypted,
    );
    return remoteDatasource.sendMessage(messageModel);
  }
}
