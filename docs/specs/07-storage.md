# Storage Specifications

## Overview

This document defines the storage strategy for the LoRa APRS application, focusing on local persistence using the **Hive** NoSQL database for its performance and simplicity in Flutter.

## Storage Strategy: Hive

Instead of a relational SQL database, we use **Hive**, a lightweight and fast key-value database written in pure Dart. It's ideal for storing structured data on the device.

### 1. Hive Boxes

Hive stores data in "Boxes," which can be thought of as tables in a traditional database. For this project, we will use a primary box for messages.

-   **`messages_box`**: Stores all `MessageModel` objects, using the message `id` as the key.

### 2. Hive TypeAdapters

To store custom objects, Hive needs `TypeAdapter`s that tell it how to convert an object to and from bytes. These are generated automatically.

-   **`MessageModelAdapter`**: Handles serialization and deserialization for the `MessageModel`.

```dart
// lib/data/models/message_model.dart

@HiveType(typeId: 0)
class MessageModel extends Message {
  @HiveField(0)
  final String id;
  // ... other fields
}
```

### 3. Data Versioning and Migration

While Hive is schemaless, changes to data models (`TypeAdapter`s) require version management. If a field is added or removed from a model in a future app version, the `@HiveType`'s `typeId` and `@HiveField` indices must be managed carefully to ensure backward compatibility or to trigger a data migration process.

---

## Other Storage Types

### 1. Preferences Storage (using Hive)

For simple key-value settings (like theme, language), we can use a separate, simple Hive box instead of `shared_preferences`.

-   **`settings_box`**: Stores user preferences.

#### Keys
```dart
class PreferenceKeys {
  static const String THEME = 'theme';
  static const String LANGUAGE = 'language';
}
```

### 2. File Cache

This remains unchanged and will be managed by a separate caching mechanism if needed for images or map tiles.

---

## Implementation

### 1. Hive Initialization & `LocalDatasourceImpl`

The local data source implementation directly uses the Hive API to interact with the boxes.

```dart
// lib/infrastructure/datasources/local_datasource_impl.dart

class LocalDatasourceImpl implements ILocalDatasource {
  
  Future<Box<MessageModel>> _openBox() async {
    return await Hive.openBox<MessageModel>('messages_box');
  }

  @override
  Future<void> cacheMessage(MessageModel message) async {
    final box = await _openBox();
    await box.put(message.id, message);
  }

  // ...
}
```

This approach centralizes data access logic and abstracts the underlying storage mechanism from the rest of the application.

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