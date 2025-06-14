import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/domain/usecases/connect_to_device_usecase.dart';
import 'package:src/domain/usecases/disconnect_from_device_usecase.dart';

// --- STATE ---
abstract class DeviceConnectionState extends Equatable {
  const DeviceConnectionState();

  @override
  List<Object> get props => [];
}

class ConnectionInitial extends DeviceConnectionState {}

class ConnectionInProgress extends DeviceConnectionState {
  final String deviceId;
  const ConnectionInProgress(this.deviceId);

  @override
  List<Object> get props => [deviceId];
}

class ConnectionSuccess extends DeviceConnectionState {
  final String deviceId;
  const ConnectionSuccess(this.deviceId);

    @override
  List<Object> get props => [deviceId];
}

class ConnectionFailure extends DeviceConnectionState {
  final String deviceId;
  final String error;

  const ConnectionFailure(this.deviceId, this.error);

  @override
  List<Object> get props => [deviceId, error];
}


// --- EVENT ---
abstract class DeviceConnectionEvent extends Equatable {
  const DeviceConnectionEvent();
}

class ConnectRequested extends DeviceConnectionEvent {
  final Device device;
  const ConnectRequested(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectRequested extends DeviceConnectionEvent {
  final Device device;
  const DisconnectRequested(this.device);

  @override
  List<Object> get props => [device];
}


// --- BLOC ---
class DeviceConnectionBloc extends Bloc<DeviceConnectionEvent, DeviceConnectionState> {
  final ConnectToDeviceUseCase _connectToDeviceUseCase;
  final DisconnectFromDeviceUseCase _disconnectFromDeviceUseCase;

  DeviceConnectionBloc({
    required ConnectToDeviceUseCase connectToDeviceUseCase,
    required DisconnectFromDeviceUseCase disconnectFromDeviceUseCase,
  })  : _connectToDeviceUseCase = connectToDeviceUseCase,
        _disconnectFromDeviceUseCase = disconnectFromDeviceUseCase,
        super(ConnectionInitial()) {
    on<ConnectRequested>(_onConnectRequested);
    on<DisconnectRequested>(_onDisconnectRequested);
  }

  Future<void> _onConnectRequested(
    ConnectRequested event,
    Emitter<DeviceConnectionState> emit,
  ) async {
    emit(ConnectionInProgress(event.device.id));
    try {
      await _connectToDeviceUseCase(event.device);
      emit(ConnectionSuccess(event.device.id));
    } catch (e) {
      emit(ConnectionFailure(event.device.id, e.toString()));
    }
  }

  Future<void> _onDisconnectRequested(
    DisconnectRequested event,
    Emitter<DeviceConnectionState> emit,
  ) async {
    // We don't show a loading indicator for disconnection, it should be fast.
    try {
      await _disconnectFromDeviceUseCase(event.device);
      emit(ConnectionInitial()); // Go back to initial state
    } catch (e) {
      emit(ConnectionFailure(event.device.id, e.toString()));
    }
  }
} 