import 'package:flutter_test/flutter_test.dart';
import 'package:src/domain/entities/message.dart';
import 'package:src/domain/repositories/i_message_repository.dart';
import 'package:src/domain/usecases/send_message_use_case.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'send_message_use_case_test.mocks.dart';

@GenerateMocks([IMessageRepository])
void main() {
  late SendMessageUseCase useCase;
  late MockIMessageRepository mockMessageRepository;

  setUp(() {
    mockMessageRepository = MockIMessageRepository();
    useCase = SendMessageUseCase(mockMessageRepository);
  });

  final testMessage = Message(
    id: '1',
    senderId: 'sender',
    recipientId: 'recipient',
    payload: 'Hello, world!',
    timestamp: DateTime.now(),
  );

  test('should call sendMessage on the repository when payload is not empty', () async {
    // arrange
    when(mockMessageRepository.sendMessage(any)).thenAnswer((_) async => Future.value());
    // act
    await useCase.execute(testMessage);
    // assert
    verify(mockMessageRepository.sendMessage(testMessage));
    verifyNoMoreInteractions(mockMessageRepository);
  });

  test('should throw an ArgumentError when message payload is empty', () async {
    // arrange
    final emptyMessage = Message(
      id: '2',
      senderId: 'sender',
      recipientId: 'recipient',
      payload: '',
      timestamp: DateTime.now(),
    );
    // act & assert
    expect(() => useCase.execute(emptyMessage), throwsA(isA<ArgumentError>()));
    verifyZeroInteractions(mockMessageRepository);
  });
} 