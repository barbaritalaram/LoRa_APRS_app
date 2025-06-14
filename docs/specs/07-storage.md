# Storage Specifications

## Overview

This document defines the storage strategy for the LoRa APRS application, including local persistence, caching, and data management.

## Storage Types

### 1. SQLite Database

#### Schema
```sql
-- Version 1
CREATE TABLE devices (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  firmware TEXT NOT NULL,
  is_connected INTEGER NOT NULL,
  last_seen INTEGER NOT NULL
);

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

CREATE TABLE device_status (
  device_id TEXT PRIMARY KEY,
  battery_level INTEGER NOT NULL,
  signal_strength INTEGER NOT NULL,
  error_count INTEGER NOT NULL,
  uptime INTEGER NOT NULL,
  timestamp INTEGER NOT NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id)
);

CREATE TABLE configurations (
  device_id TEXT PRIMARY KEY,
  settings TEXT NOT NULL,
  last_update INTEGER NOT NULL,
  FOREIGN KEY (device_id) REFERENCES devices(id)
);
```

#### Indexes
```sql
CREATE INDEX idx_messages_timestamp ON messages(timestamp);
CREATE INDEX idx_locations_timestamp ON locations(timestamp);
CREATE INDEX idx_device_status_timestamp ON device_status(timestamp);
```

### 2. Preferences Storage

#### Keys
```dart
class StorageKeys {
  static const String THEME = 'theme';
  static const String LANGUAGE = 'language';
  static const String NOTIFICATIONS = 'notifications';
  static const String ENCRYPTION = 'encryption';
  static const String LAST_SYNC = 'last_sync';
}
```

#### Values
```dart
class StorageValues {
  static const String THEME_LIGHT = 'light';
  static const String THEME_DARK = 'dark';
  static const String LANGUAGE_EN = 'en';
  static const String LANGUAGE_ES = 'es';
}
```

### 3. File Cache

#### Structure
```
/cache
  /images
    /avatars
    /icons
  /maps
    /tiles
    /markers
  /temp
    /downloads
    /uploads
```

#### Policies
- Maximum size: 20MB
- Lifetime: 7 days
- Automatic cleanup
- Deletion priority

## Implementation

### 1. Database Manager
```dart
class DatabaseManager {
  static const String DATABASE_NAME = 'lora_aprs.db';
  static const int DATABASE_VERSION = 1;
  
  Future<Database> get database async {
    // Implementation
  }
  
  Future<void> initDatabase() async {
    // Implementation
  }
}
```

### 2. Preferences Manager
```dart
class PreferencesManager {
  static const String PREFERENCES_NAME = 'lora_aprs_prefs';
  
  Future<void> setString(String key, String value) async {
    // Implementation
  }
  
  Future<String?> getString(String key) async {
    // Implementation
  }
}
```

### 3. Cache Manager
```dart
class CacheManager {
  static const int MAX_SIZE = 20 * 1024 * 1024; // 20MB
  static const Duration MAX_AGE = Duration(days: 7);
  
  Future<void> cacheFile(String key, File file) async {
    // Implementation
  }
  
  Future<File?> getCachedFile(String key) async {
    // Implementation
  }
}
```

## Operations

### 1. Read
```dart
class StorageOperations {
  Future<List<Message>> getMessages({
    required String deviceId,
    int limit = 50,
    int offset = 0,
  }) async {
    // Implementation
  }
  
  Future<Device?> getDevice(String deviceId) async {
    // Implementation
  }
}
```

### 2. Write
```dart
class StorageOperations {
  Future<void> saveMessage(Message message) async {
    // Implementation
  }
  
  Future<void> updateDevice(Device device) async {
    // Implementation
  }
}
```

### 3. Delete
```dart
class StorageOperations {
  Future<void> deleteMessage(String messageId) async {
    // Implementation
  }
  
  Future<void> clearCache() async {
    // Implementation
  }
}
```

## Migrations

### 1. Version 1 to 2
```sql
ALTER TABLE messages ADD COLUMN is_encrypted INTEGER NOT NULL DEFAULT 0;
ALTER TABLE configurations ADD COLUMN version TEXT NOT NULL DEFAULT '1.0.0';
```

### 2. Version 2 to 3
```sql
CREATE TABLE message_attachments (
  id TEXT PRIMARY KEY,
  message_id TEXT NOT NULL,
  type TEXT NOT NULL,
  path TEXT NOT NULL,
  size INTEGER NOT NULL,
  FOREIGN KEY (message_id) REFERENCES messages(id)
);
```

## Considerations

### 1. Performance
- Indexes on search fields
- Pagination of results
- Cache of frequent queries
- Batch operations

### 2. Security
- Encryption of sensitive data
- Input validation
- Data sanitization
- Access control

### 3. Maintainability
- Schema versioning
- Clear documentation
- Integration tests
- Operation logging

## Libraries

### Database
- sqflite
- path_provider
- sqflite_migration

### Preferences
- shared_preferences
- flutter_secure_storage

### Cache
- flutter_cache_manager
- cached_network_image
- path_provider

## Tests

### 1. Unit Tests
- CRUD operations
- Validations
- Migrations
- Cache

### 2. Integration Tests
- Complete flows
- Real scenarios
- Performance
- Recovery

### 3. Load Tests
- Multiple operations
- Large data
- Concurrency
- Limited resources 