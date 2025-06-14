import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/presentation/features/bluetooth_scan/bloc/bluetooth_scan_bloc.dart';
import 'package:src/presentation/features/device_connection/bloc/device_connection_bloc.dart';

class BluetoothScanView extends StatelessWidget {
  const BluetoothScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Scanner'),
      ),
      body: BlocBuilder<BluetoothScanBloc, BluetoothScanState>(
        builder: (context, state) {
          if (state is ScanInProgress) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ScanFailure) {
            return Center(
              child: Text('Error: ${state.error}'),
            );
          }
          if (state is ScanSuccess) {
            if (state.devices.isEmpty) {
              return const Center(
                child: Text('No devices found. Try scanning again.'),
              );
            }
            return BlocBuilder<DeviceConnectionBloc, DeviceConnectionState>(
              builder: (context, connectionState) {
                return DeviceList(
                  devices: state.devices,
                  connectionState: connectionState,
                );
              },
            );
          }
          // Initial State
          return const Center(
            child: Text('Press the button to start scanning for devices.'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.read<BluetoothScanBloc>().add(ScanStarted()),
        child: const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}

class DeviceList extends StatelessWidget {
  final List<Device> devices;
  final DeviceConnectionState connectionState;

  const DeviceList(
      {super.key, required this.devices, required this.connectionState});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceListItem(
          device: device,
          connectionState: connectionState,
        );
      },
    );
  }
}

class DeviceListItem extends StatelessWidget {
  final Device device;
  final DeviceConnectionState connectionState;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.connectionState,
  });

  @override
  Widget build(BuildContext context) {
    final connectionBloc = context.read<DeviceConnectionBloc>();
    Widget trailing;
    bool isConnecting = false;

    final state = connectionState;
    if (state is ConnectionInProgress && state.deviceId == device.id) {
      trailing = const CircularProgressIndicator();
      isConnecting = true;
    } else if (state is ConnectionSuccess && state.deviceId == device.id) {
      trailing = IconButton(
        icon: const Icon(Icons.bluetooth_connected, color: Colors.green),
        onPressed: () => connectionBloc.add(DisconnectRequested(device)),
      );
    } else if (state is ConnectionFailure && state.deviceId == device.id) {
      trailing = IconButton(
        icon: const Icon(Icons.error, color: Colors.red),
        onPressed: () => connectionBloc.add(ConnectRequested(device)),
        tooltip: state.error,
      );
    } else {
      trailing = ElevatedButton(
        child: const Text('Connect'),
        onPressed: () => connectionBloc.add(ConnectRequested(device)),
      );
    }

    return ListTile(
      title: Text(device.name),
      subtitle: Text(device.address),
      leading: const Icon(Icons.bluetooth),
      trailing: trailing,
      enabled: !isConnecting,
      onTap: isConnecting
          ? null
          : () => connectionBloc.add(ConnectRequested(device)),
    );
  }
} 