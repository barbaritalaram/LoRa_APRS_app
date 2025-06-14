import '../entities/message.dart';
import '../repositories/i_message_repository.dart';

class SendMessageUseCase {
  final IMessageRepository _messageRepository;

  SendMessageUseCase(this._messageRepository);

  Future<void> execute(Message message) {
    // Here you could add business logic, e.g., validation
    if (message.payload.isEmpty) {
      throw ArgumentError('Message payload cannot be empty');
    }
    return _messageRepository.sendMessage(message);
  }
} 