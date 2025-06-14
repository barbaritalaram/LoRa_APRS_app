import 'dart:async';
import 'dart:convert';
import 'dart:convert' show json;
import 'dart:convert' show utf8;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:src/domain/entities/device.dart' as app;
import 'package:src/infrastructure/services/logger_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/datasources/i_remote_datasource.dart';
import '../../data/models/message_model.dart';

// This will be implemented using flutter_blue or another Bluetooth package.
class RemoteDatasourceImpl implements IRemoteDatasource {
  final LoggerService _logger;
  final Map<String, BluetoothDevice> _scannedDevices = {};
  BluetoothDevice? _connectedDevice;
  StreamSubscription? _connectionStateSubscription;
  StreamSubscription? _scanSubscription;
  StreamController<MessageModel>? _messageStreamController;
  StreamController<List<app.Device>>? _scanResultsController;

  // TODO: Replace with actual UUIDs from the LoRa device
  final Guid _serviceUuid = Guid("0000ffe0-0000-1000-8000-00805f9b34fb");
  final Guid _writeCharacteristicUuid = Guid("0000ffe1-0000-1000-8000-00805f9b34fb");
  final Guid _notifyCharacteristicUuid = Guid("0000ffe2-0000-1000-8000-00805f9b34fb");

  RemoteDatasourceImpl({required LoggerService logger}) : _logger = logger;

  @override
  Stream<List<app.Device>> scanForDevices() {
    _logger.i('Starting or restarting Bluetooth device scan...');
    _scanResultsController?.close();
    _scanResultsController = StreamController<List<app.Device>>.broadcast();

    final Set<app.Device> foundDevices = {};

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        final lowerCaseName = r.device.name.toLowerCase();

        if (r.device.name.isNotEmpty &&
            (lowerCaseName.contains('lora') ||
                lowerCaseName.contains('aprs') ||
                lowerCaseName.contains('esp') ||
                lowerCaseName.contains('smart tag'))) {
          _scannedDevices[r.device.id.toString()] = r.device;
          foundDevices.add(app.Device(
            id: r.device.id.toString(),
            name: r.device.name,
            address: r.device.id.toString(),
          ));
        }
      }
      _scanResultsController?.add(foundDevices.toList());
    });

    // Stop any previous scan and start a new one
    FlutterBluePlus.stopScan();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));

    return _scanResultsController!.stream;
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
    final BluetoothDevice? bleDevice = _scannedDevices[device.id];

    if (bleDevice == null) {
      final err = 'Device ${device.name} not in cache. Please scan again.';
      _logger.e(err);
      throw Exception(err);
    }

    _logger.i('Attempting to pair with device: ${device.name} (${device.id})');
    try {
      await bleDevice.pair();
    } catch (e) {
      _logger.w('Pairing failed or was not required: $e');
    }

    _logger.i('Connecting to device: ${device.name} (${device.id})');
    try {
      await bleDevice.connect(autoConnect: false, mtu: null);
      _connectedDevice = bleDevice;
      _logger.i('Successfully connected to ${device.name}. Discovering services...');
      await _discoverServicesAndSetupMessageStream();
      
      _connectionStateSubscription = bleDevice.state.listen((state) {
        if (state == BluetoothDeviceState.disconnected) {
          _logger.w('Device ${device.name} disconnected.');
          _cleanupConnection();
        }
      });

    } catch (e) {
      _logger.e('Error connecting to device ${device.name}', e);
      _cleanupConnection();
      rethrow;
    }
  }

  @override
  Future<void> disconnectDevice(app.Device device) async {
    final BluetoothDevice? bleDevice = _scannedDevices[device.id] ?? _connectedDevice;

    if (bleDevice == null) {
      _logger.w('Trying to disconnect from a device that is not connected or cached.');
      return;
    }
      
    _logger.i('Disconnecting from device: ${device.name}');
    try {
      // Before disconnecting, stop any ongoing scan to prevent immediate reconnection attempts
      FlutterBluePlus.stopScan();
      await bleDevice.disconnect();
      _logger.i('Successfully disconnected from ${device.name}');
    } catch (e) {
      _logger.e('Error disconnecting from device ${device.name}', e);
      rethrow;
    } finally {
      _cleanupConnection();
    }
  }

  Future<void> _discoverServicesAndSetupMessageStream() async {
    if (_connectedDevice == null) return;

    final services = await _connectedDevice!.discoverServices();
    _logger.i('Found ${services.length} services. Listing them below:');
    for (var service in services) {
        _logger.i('--> Service UUID: ${service.uuid}');
        for (var char in service.characteristics) {
            _logger.i('  - Characteristic UUID: ${char.uuid} | Properties: ${char.properties}');
        }
    }
    
    final service = services.firstWhere((s) => s.uuid == _serviceUuid, 
      orElse: () {
          _logger.e('Required service ${_serviceUuid} not found on device.');
          throw Exception('Required service not found.');
      },
    );

    final notifyCharacteristic = service.characteristics.firstWhere((c) => c.uuid == _notifyCharacteristicUuid,
      orElse: () {
        _logger.e('Required notify characteristic ${_notifyCharacteristicUuid} not found on service ${_serviceUuid}.');
        throw Exception('Notify characteristic not found.');
      },
    );

    _messageStreamController = StreamController<MessageModel>.broadcast();
    await notifyCharacteristic.setNotifyValue(true);
    notifyCharacteristic.value.listen((value) {
      _logger.i('Received raw data: $value');
      // Assuming the data is a JSON string that can be decoded
      try {
        final jsonString = String.fromCharCodes(value);
        final message = MessageModel.fromJson(json.decode(jsonString));
        _messageStreamController!.add(message);
      } catch (e) {
        _logger.e('Failed to parse incoming message', e);
      }
    });

     _logger.i('Message stream setup complete.');
  }

  void _cleanupConnection() {
    _connectedDevice = null;
    _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;
    _messageStreamController?.close();
    _messageStreamController = null;
    // Do not cancel scan-related controllers here
  }

  @override
  Stream<MessageModel> getMessageStream() {
    _logger.i('Listening for incoming messages...');
    return _messageStreamController?.stream ?? Stream.empty();
  }

  @override
  Future<void> sendMessage(MessageModel message) async {
    if (_connectedDevice == null) {
      throw Exception('Not connected to any device.');
    }
    _logger.i('Sending message ${message.id} via Bluetooth.');

    final services = await _connectedDevice!.discoverServices();
    final service = services.firstWhere((s) => s.uuid == _serviceUuid);
    final characteristic = service.characteristics.firstWhere((c) => c.uuid == _writeCharacteristicUuid);
    
    final jsonString = json.encode(message.toJson());
    final bytes = utf8.encode(jsonString);

    await characteristic.write(bytes, withoutResponse: false);
     _logger.i('Message ${message.id} sent successfully.');
  }
} 