import 'package:src/domain/entities/message.dart';
import 'package:src/domain/repositories/i_message_repository.dart';

class SendMessageUseCase {
  final IMessageRepository _repository;

  SendMessageUseCase(this._repository);

  Future<void> call(Message message) {
    return _repository.sendMessage(message);
  }
} 