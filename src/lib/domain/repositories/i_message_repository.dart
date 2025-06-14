import '../entities/message.dart';
import 'package:src/domain/entities/device.dart';

abstract class IMessageRepository {
  Future<void> sendMessage(Message message);
  Stream<Message> getMessages();
  Future<void> saveMessage(Message message);
  Future<Message?> getMessage(String id);
  Stream<List<Device>> scanForDevices();
  Future<void> connectToDevice(Device device);
  Future<void> disconnectFromDevice(Device device);
} 