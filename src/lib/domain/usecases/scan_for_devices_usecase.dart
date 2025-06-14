import 'package:src/domain/entities/device.dart';
import 'package:src/domain/repositories/i_message_repository.dart';

class ScanForDevicesUseCase {
  final IMessageRepository _repository;

  ScanForDevicesUseCase(this._repository);

  Stream<List<Device>> call() {
    return _repository.scanForDevices();
  }
} 