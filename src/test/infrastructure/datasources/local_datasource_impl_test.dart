import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:src/data/models/message_model.dart';
import 'package:src/infrastructure/datasources/local_datasource_impl.dart';
import 'package:src/infrastructure/services/logger_service.dart';
import 'package:src/injection_container.dart';

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late LocalDatasourceImpl datasource;
  late MockLoggerService mockLoggerService;

  setUpAll(() async {
    // Use an in-memory database for tests
    Hive.init('test_path'); 
    Hive.registerAdapter(MessageModelAdapter());
    
    // Register mock dependency
    mockLoggerService = MockLoggerService();
    sl.registerLazySingleton<LoggerService>(() => mockLoggerService);
  });

  setUp(() async {
    datasource = LocalDatasourceImpl(logger: mockLoggerService);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await sl.reset(); // Reset GetIt container
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