import 'dart:async';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:src/domain/entities/device.dart' as app;
import 'package:src/infrastructure/services/logger_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/datasources/i_remote_datasource.dart';
import '../../data/models/message_model.dart';

// This will be implemented using flutter_blue or another Bluetooth package.
class RemoteDatasourceImpl implements IRemoteDatasource {
  final FlutterBlue _flutterBlue = FlutterBlue.instance;
  final LoggerService _logger;

  RemoteDatasourceImpl({required LoggerService logger}) : _logger = logger;

  @override
  Stream<List<app.Device>> scanForDevices() async* {
    if (await _requestPermissions()) {
      _logger.i('Starting Bluetooth device scan...');
      final Set<app.Device> foundDevices = {};

      final scanSubscription = _flutterBlue.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name.isNotEmpty &&
              (r.device.name.toLowerCase().contains('lora') ||
                  r.device.name.toLowerCase().contains('aprs'))) {
            foundDevices.add(app.Device(
              id: r.device.id.toString(),
              name: r.device.name,
              address: r.device.id.toString(),
            ));
          }
        }
      });

      _flutterBlue.startScan(timeout: const Duration(seconds: 10));
      await Future.delayed(const Duration(seconds: 10));
      _flutterBlue.stopScan();

      yield foundDevices.toList();
      scanSubscription.cancel();
      _logger.i('Bluetooth scan finished.');
    } else {
      _logger.w('Bluetooth permissions not granted. Cannot scan for devices.');
      yield []; // Return an empty list if permissions are not granted
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      return true;
    } else {
      _logger.e(
          'Permissions not granted: $statuses');
      return false;
    }
  }

  @override
  Future<void> connectToDevice(app.Device device) async {
    final BluetoothDevice bleDevice = BluetoothDevice.fromId(device.id);
    _logger.i('Connecting to device: ${device.name} (${device.id})');
    try {
      await bleDevice.connect(autoConnect: false);
      _logger.i('Successfully connected to ${device.name}');
    } catch (e) {
      _logger.e('Error connecting to device ${device.name}', e);
      rethrow;
    }
  }

  @override
  Future<void> disconnectDevice(app.Device device) async {
    final BluetoothDevice bleDevice = BluetoothDevice.fromId(device.id);
    _logger.i('Disconnecting from device: ${device.name}');
    try {
      await bleDevice.disconnect();
      _logger.i('Successfully disconnected from ${device.name}');
    } catch (e) {
      _logger.e('Error disconnecting from device ${device.name}', e);
      rethrow;
    }
  }

  @override
  Stream<MessageModel> getMessageStream() {
    _logger.i('Listening for incoming messages...');
    return Stream.empty();
  }

  @override
  Future<void> sendMessage(MessageModel message) {
    _logger.i('Sending message ${message.id} via Bluetooth.');
    return Future.value();
  }
} 