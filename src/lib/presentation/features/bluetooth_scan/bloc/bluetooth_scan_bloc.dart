import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/domain/usecases/scan_for_devices_usecase.dart';

// --- STATE ---
abstract class BluetoothScanState extends Equatable {
  const BluetoothScanState();

  @override
  List<Object> get props => [];
}

class ScanInitial extends BluetoothScanState {}

class ScanInProgress extends BluetoothScanState {}

class ScanSuccess extends BluetoothScanState {
  final List<Device> devices;

  const ScanSuccess(this.devices);

  @override
  List<Object> get props => [devices];
}

class ScanFailure extends BluetoothScanState {
  final String error;

  const ScanFailure(this.error);

  @override
  List<Object> get props => [error];
}

// --- EVENT ---
abstract class BluetoothScanEvent extends Equatable {
  const BluetoothScanEvent();
}

class ScanStarted extends BluetoothScanEvent {
  @override
  List<Object> get props => [];
}

class _DevicesReceived extends BluetoothScanEvent {
  final List<Device> devices;
  const _DevicesReceived(this.devices);

  @override
  List<Object> get props => [devices];
}

class _ScanError extends BluetoothScanEvent {
  final String error;
  const _ScanError(this.error);

  @override
  List<Object> get props => [error];
}


// --- BLOC ---
class BluetoothScanBloc extends Bloc<BluetoothScanEvent, BluetoothScanState> {
  final ScanForDevicesUseCase _scanForDevicesUseCase;
  StreamSubscription? _deviceStreamSubscription;

  BluetoothScanBloc({required ScanForDevicesUseCase scanForDevicesUseCase})
      : _scanForDevicesUseCase = scanForDevicesUseCase,
        super(ScanInitial()) {
    on<ScanStarted>(_onScanStarted);
    on<_DevicesReceived>(_onDevicesReceived);
    on<_ScanError>(_onScanError);
  }

  Future<void> _onScanStarted(
    ScanStarted event,
    Emitter<BluetoothScanState> emit,
  ) async {
    emit(ScanInProgress());
    await _deviceStreamSubscription?.cancel();
    _deviceStreamSubscription = _scanForDevicesUseCase().listen(
      (devices) => add(_DevicesReceived(devices)),
      onError: (error) => add(_ScanError(error.toString())),
    );
  }

  void _onDevicesReceived(
    _DevicesReceived event,
    Emitter<BluetoothScanState> emit,
  ) {
    emit(ScanSuccess(event.devices));
  }

  void _onScanError(
    _ScanError event,
    Emitter<BluetoothScanState> emit,
  ) {
    emit(ScanFailure(event.error));
  }

  @override
  Future<void> close() {
    _deviceStreamSubscription?.cancel();
    return super.close();
  }
} 