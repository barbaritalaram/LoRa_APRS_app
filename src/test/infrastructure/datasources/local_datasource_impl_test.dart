import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:src/data/models/message_model.dart';
import 'package:src/infrastructure/datasources/local_datasource_impl.dart';

void main() {
  late LocalDatasourceImpl datasource;

  setUpAll(() async {
    // Use an in-memory database for tests
    Hive.init('test_path'); 
    Hive.registerAdapter(MessageModelAdapter());
  });

  setUp(() async {
    datasource = LocalDatasourceImpl();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  final testMessage = MessageModel(
    id: '1',
    senderId: 'sender',
    recipientId: 'recipient',
    payload: 'Test message',
    timestamp: DateTime.now(),
  );

  test('should cache a message and retrieve it', () async {
    // act
    await datasource.cacheMessage(testMessage);
    final messages = await datasource.getAllMessages();

    // assert
    expect(messages, isNotEmpty);
    expect(messages.first.id, testMessage.id);
  });

  test('should return all cached messages', () async {
    // arrange
    final testMessage2 = MessageModel(id: '2', senderId: 's2', recipientId: 'r2', payload: 'p2', timestamp: DateTime.now());
    await datasource.cacheMessage(testMessage);
    await datasource.cacheMessage(testMessage2);

    // act
    final messages = await datasource.getAllMessages();

    // assert
    expect(messages.length, 2);
  });
} 