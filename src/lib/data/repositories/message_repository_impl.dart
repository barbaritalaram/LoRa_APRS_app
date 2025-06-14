import '../../domain/entities/message.dart';
import '../../domain/entities/device.dart';
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
    return remoteDatasource
        .getMessageStream()
        .map((messageModel) => messageModel.toEntity());
  }

  @override
  Future<void> saveMessage(Message message) {
    final messageModel = MessageModel.fromEntity(message);
    return localDatasource.saveMessage(messageModel);
  }

  @override
  Future<void> sendMessage(Message message) {
    final messageModel = MessageModel.fromEntity(message);
    return remoteDatasource.sendMessage(messageModel);
  }

  @override
  Stream<List<Device>> scanForDevices() {
    return remoteDatasource.scanForDevices();
  }

  @override
  Future<void> connectToDevice(Device device) {
    return remoteDatasource.connectToDevice(device);
  }

  @override
  Future<void> disconnectFromDevice(Device device) {
    return remoteDatasource.disconnectDevice(device);
  }

  @override
  Future<Message?> getMessage(String id) async {
    final messageModel = await localDatasource.getMessage(id);
    return messageModel?.toEntity();
  }
}
