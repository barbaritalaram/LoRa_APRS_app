import 'package:src/domain/entities/device.dart';
import 'package:src/domain/repositories/i_message_repository.dart';

class DisconnectFromDeviceUseCase {
  final IMessageRepository _repository;

  DisconnectFromDeviceUseCase(this._repository);

  Future<void> call(Device device) {
    return _repository.disconnectFromDevice(device);
  }
} 