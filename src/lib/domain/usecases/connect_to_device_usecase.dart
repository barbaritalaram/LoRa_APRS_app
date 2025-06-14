import 'package:src/domain/entities/device.dart';
import 'package:src/domain/repositories/i_message_repository.dart';

class ConnectToDeviceUseCase {
  final IMessageRepository _repository;

  ConnectToDeviceUseCase(this._repository);

  Future<void> call(Device device) {
    return _repository.connectToDevice(device);
  }
} 