import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final String address; // Could be a MAC address for Bluetooth

  const Device({
    required this.id,
    required this.name,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, address];
} 