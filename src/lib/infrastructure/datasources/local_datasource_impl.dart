import '../../data/datasources/i_local_datasource.dart';
import '../../data/models/message_model.dart';

// This will be implemented using a local database like Hive or SQLite.
class LocalDatasourceImpl implements ILocalDatasource {
  @override
  Future<void> cacheMessage(MessageModel message) {
    // TODO: Implement caching logic with Hive
    print('Message ${message.id} cached.');
    return Future.value();
  }

  @override
  Future<List<MessageModel>> getAllMessages() {
    // TODO: Implement message retrieval from Hive
    print('Retrieving all messages from cache.');
    return Future.value([]);
  }
} 