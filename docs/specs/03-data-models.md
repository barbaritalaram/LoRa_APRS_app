# Data Models

## Overview

The data models define the structure and relationships of the information managed by the application. They will be implemented using Dart classes with JSON serialization support.

## Main Models

### 1. Device
```dart
class Device {
  final String id;           // Unique identifier
  final String name;         // Device name
  final String type;         // Device type
  final String firmware;     // Firmware version
  final bool isConnected;    // Connection status
  final DateTime lastSeen;   // Last seen timestamp
  final DeviceStatus status; // Current status
}
```

### 2. Message
```dart
class Message {
  final String id;           // Unique identifier
  final String senderId;     // Sender ID
  final String? recipientId; // Recipient ID (optional)
  final String content;      // Message content
  final MessageType type;    // Message type
  final bool isEncrypted;    // Encryption status
  final DateTime timestamp;  // Timestamp
  final MessageStatus status;// Message status
}
```

### 3. Location
```dart
class Location {
  final double latitude;     // Latitude
  final double longitude;    // Longitude
  final double altitude;     // Altitude
  final double speed;        // Speed
  final double course;       // Course
  final DateTime timestamp;  // Timestamp
  final String deviceId;     // Device ID
}
```

### 4. DeviceStatus
```dart
class DeviceStatus {
  final int batteryLevel;    // Battery level
  final int signalStrength;  // Signal strength
  final int errorCount;      // Error counter
  final int uptime;          // Uptime
  final DateTime timestamp;  // Timestamp
}
```

### 5. Configuration
```dart
class Configuration {
  final String deviceId;     // Device ID
  final Map<String, dynamic> settings; // Settings
  final DateTime lastUpdate; // Last update
}
```

## Enumerations

### MessageType
```dart
enum MessageType {
  text,       // Text message
  beacon,     // Location beacon
  status,     // Device status
  config      // Configuration
}
```

### MessageStatus
```dart
enum MessageStatus {
  sending,    // Sending
  sent,       // Sent
  delivered,  // Delivered
  failed      // Failed
}
```

## Relationships

### Device -> Message
- A device can have multiple messages
- One-to-many relationship
- Messages ordered by timestamp

### Device -> Location
- A device has a current location
- One-to-one relationship
- Location history

### Device -> DeviceStatus
- A device has a current status
- One-to-one relationship
- Status history

### Device -> Configuration
- A device has a configuration
- One-to-one relationship
- Configuration versions

## Persistence

### SQLite Tables

#### devices
```sql
CREATE TABLE devices (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  firmware TEXT NOT NULL,
  is_connected INTEGER NOT NULL,
  last_seen INTEGER NOT NULL
);
```

#### messages
```sql
CREATE TABLE messages (
  id TEXT PRIMARY KEY,
  sender_id TEXT NOT NULL,
  recipient_id TEXT,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  is_encrypted INTEGER NOT NULL,
  timestamp INTEGER NOT NULL,
  status TEXT NOT NULL,
  FOREIGN KEY (sender_id) REFERENCES devices(id),
  FOREIGN KEY (recipient_id) REFERENCES devices(id)
);
```

#### locations
```sql
CREATE TABLE locations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  device_id TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  altitude REAL NOT NULL,
  speed REAL NOT NULL,
  course REAL NOT NULL,
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

#### device_status
```sql
CREATE TABLE device_status (
  device_id TEXT PRIMARY KEY,
  battery_level INTEGER NOT NULL,
  signal_strength INTEGER NOT NULL,
  error_count INTEGER NOT NULL,
  uptime INTEGER NOT NULL,
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

#### configurations
```sql
CREATE TABLE configurations (
  device_id TEXT PRIMARY KEY,
  settings TEXT NOT NULL,
  last_update INTEGER NOT NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

## Indexes

```sql
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
CREATE INDEX idx_locations_timestamp ON locations(timestamp);
CREATE INDEX idx_device_status_timestamp ON device_status(timestamp);
```

## Validations

### Device
- ID: Not null, unique
- Name: Not null, 3-32 characters
- Type: Allowed values
- Firmware: Semantic format

### Message
- ID: Not null, unique
- Content: Not null, max 160 characters
- Timestamp: Not null, valid
- Type: Allowed values

### Location
- Latitude: -90 to 90
- Longitude: -180 to 180
- Altitude: -1000 to 10000 meters
- Speed: 0 to 300 km/h
- Course: 0 to 360 degrees

### DeviceStatus
- Battery: 0 to 100
- Signal: -100 to 0 dBm
- Errors: >= 0
- Uptime: >= 0

## Migrations

### Version 1
- Initial table creation
- Basic indexes

### Version 2
- Add encryption field to messages
- Add version field to configurations

## Considerations

### Performance
- Indexes on frequently searched fields
- Periodic cleanup of old data
- Cache of frequent data

### Security
- Encryption of sensitive data
- Input validation
- Data sanitization

### Maintainability
- Descriptive names
- Inline documentation
- Consistent conventions 