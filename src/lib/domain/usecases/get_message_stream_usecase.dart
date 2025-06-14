import 'dart:async';
import 'package:src/domain/entities/message.dart';
import 'package:src/domain/repositories/i_message_repository.dart';

class GetMessageStreamUseCase {
  final IMessageRepository _repository;

  GetMessageStreamUseCase(this._repository);

  Stream<Message> call() {
    return _repository.getMessages();
  }
} 