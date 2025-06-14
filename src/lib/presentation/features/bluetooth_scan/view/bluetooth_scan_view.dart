import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/presentation/features/bluetooth_scan/bloc/bluetooth_scan_bloc.dart';

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
            return DeviceList(devices: state.devices);
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
  const DeviceList({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return ListTile(
          title: Text(device.name),
          subtitle: Text(device.address),
          leading: const Icon(Icons.bluetooth),
        );
      },
    );
  }
} 