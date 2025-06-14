import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/injection_container.dart';
import 'package:src/presentation/features/bluetooth_scan/bloc/bluetooth_scan_bloc.dart';
import 'package:src/presentation/features/bluetooth_scan/view/bluetooth_scan_view.dart';

class BluetoothScanPage extends StatelessWidget {
  const BluetoothScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BluetoothScanBloc>(),
      child: const BluetoothScanView(),
    );
  }
} 