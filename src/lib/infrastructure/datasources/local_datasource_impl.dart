import 'package:hive/hive.dart';

import '../../data/datasources/i_local_datasource.dart';
import '../../data/models/message_model.dart';
import '../services/logger_service.dart';
import '../../injection_container.dart';

const String messagesBoxName = 'messages_box';

// This will be implemented using a local database like Hive or SQLite.
class LocalDatasourceImpl implements ILocalDatasource {
  final LoggerService logger;

  LocalDatasourceImpl({required this.logger}) {
    _openBox();
  }

  Future<Box<MessageModel>> _openBox() async {
    return await Hive.openBox<MessageModel>(messagesBoxName);
  }

  @override
  Future<void> cacheMessage(MessageModel message) async {
    final box = await _openBox();
    await box.put(message.id, message);
    logger.i('Cached message with id: ${message.id}');
  }

  @override
  Future<List<MessageModel>> getAllMessages() async {
    final box = await _openBox();
    final messages = box.values.toList();
    logger.i('Retrieved ${messages.length} messages from cache.');
    return messages;
  }
} 