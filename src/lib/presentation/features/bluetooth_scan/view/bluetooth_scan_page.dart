import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/injection_container.dart';
import 'package:src/presentation/features/bluetooth_scan/bloc/bluetooth_scan_bloc.dart';
import 'package:src/presentation/features/bluetooth_scan/view/bluetooth_scan_view.dart';
import 'package:src/presentation/features/device_connection/bloc/device_connection_bloc.dart';

class BluetoothScanPage extends StatelessWidget {
  const BluetoothScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<BluetoothScanBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<DeviceConnectionBloc>(),
        ),
      ],
      child: const BluetoothScanView(),
    );
  }
} 