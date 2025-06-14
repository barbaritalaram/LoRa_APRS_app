class Device {
  final String id;
  final String name;
  final String address; // Could be a MAC address for Bluetooth

  Device({
    required this.id,
    required this.name,
    required this.address,
  });
} 