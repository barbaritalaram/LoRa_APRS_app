import '../models/message_model.dart';
import '../../domain/entities/device.dart';

abstract class IRemoteDatasource {
  Future<void> sendMessage(MessageModel message);
  Stream<MessageModel> getMessageStream();
  Stream<List<Device>> scanForDevices();
  Future<void> connectToDevice(Device device);
  Future<void> disconnectDevice(Device device);
} 