import 'package:hive/hive.dart';

import '../../data/datasources/i_local_datasource.dart';
import '../../data/models/message_model.dart';

const String messagesBoxName = 'messages_box';

// This will be implemented using a local database like Hive or SQLite.
class LocalDatasourceImpl implements ILocalDatasource {
  
  LocalDatasourceImpl() {
    _openBox();
  }

  Future<Box<MessageModel>> _openBox() async {
    return await Hive.openBox<MessageModel>(messagesBoxName);
  }

  @override
  Future<void> cacheMessage(MessageModel message) async {
    final box = await _openBox();
    await box.put(message.id, message);
  }

  @override
  Future<List<MessageModel>> getAllMessages() async {
    final box = await _openBox();
    return box.values.toList();
  }
} 