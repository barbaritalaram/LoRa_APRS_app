import '../entities/device.dart';

abstract class IDeviceRepository {
  Future<List<Device>> getPairedDevices();
  Stream<List<Device>> scanForDevices();
  Future<void> connectToDevice(Device device);
  Future<void> disconnectDevice(Device device);
} 