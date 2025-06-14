import 'package:hive/hive.dart';

import '../../data/datasources/i_local_datasource.dart';
import '../../data/models/message_model.dart';
import '../services/logger_service.dart';
import '../../injection_container.dart';

const String _kMessagesBox = 'messagesBox';

// This will be implemented using a local database like Hive or SQLite.
class LocalDatasourceImpl implements ILocalDatasource {
  final LoggerService _logger;
  late final Box<MessageModel> _messagesBox;

  LocalDatasourceImpl({required LoggerService logger}) : _logger = logger {
    _messagesBox = Hive.box<MessageModel>(_kMessagesBox);
  }

  @override
  Future<void> saveMessage(MessageModel message) async {
    _logger.i('Saving message with id: ${message.id} to local storage.');
    try {
      await _messagesBox.put(message.id, message);
      _logger.i('Message ${message.id} saved successfully.');
    } catch (e) {
      _logger.e('Failed to save message ${message.id}', e);
      rethrow;
    }
  }

  @override
  Future<MessageModel?> getMessage(String id) async {
    _logger.i('Getting message with id: $id from local storage.');
    try {
      final message = _messagesBox.get(id);
      if (message != null) {
        _logger.i('Message $id found in cache.');
      } else {
        _logger.w('Message $id not found in cache.');
      }
      return message;
    } catch (e) {
      _logger.e('Failed to get message $id from cache', e);
      rethrow;
    }
  }
} 