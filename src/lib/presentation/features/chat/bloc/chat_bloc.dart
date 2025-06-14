import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/message.dart';
import 'package:src/domain/usecases/get_message_stream_usecase.dart';
import 'package:src/domain/usecases/send_message_usecase.dart';
import 'package:uuid/uuid.dart';

// --- STATE ---
abstract class ChatState extends Equatable {
  final List<Message> messages;
  const ChatState(this.messages);

  @override
  List<Object> get props => [messages];
}

class ChatInitial extends ChatState {
  const ChatInitial(super.messages);
}

class MessageSendInProgress extends ChatState {
  const MessageSendInProgress(super.messages);
}

class MessageSendSuccess extends ChatState {
  const MessageSendSuccess(super.messages);
}

class MessageSendFailure extends ChatState {
  final String error;
  const MessageSendFailure(super.messages, this.error);

    @override
  List<Object> get props => [messages, error];
}


// --- EVENT ---
abstract class ChatEvent extends Equatable {
  const ChatEvent();
}

class SubscriptionRequested extends ChatEvent {
  @override
  List<Object> get props => [];
}

class MessageSent extends ChatEvent {
  final String text;
  const MessageSent(this.text);
  @override
  List<Object> get props => [text];
}

class _MessageReceived extends ChatEvent {
  final Message message;
  const _MessageReceived(this.message);
    @override
  List<Object> get props => [message];
}

// --- BLOC ---
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessageUseCase _sendMessageUseCase;
  final GetMessageStreamUseCase _getMessageStreamUseCase;
  StreamSubscription? _messageSubscription;

  ChatBloc({
    required SendMessageUseCase sendMessageUseCase,
    required GetMessageStreamUseCase getMessageStreamUseCase,
  })  : _sendMessageUseCase = sendMessageUseCase,
        _getMessageStreamUseCase = getMessageStreamUseCase,
        super(const ChatInitial([])) {
    on<SubscriptionRequested>(_onSubscriptionRequested);
    on<MessageSent>(_onMessageSent);
    on<_MessageReceived>(_onMessageReceived);
  }

  void _onSubscriptionRequested(
    SubscriptionRequested event,
    Emitter<ChatState> emit,
  ) {
    _messageSubscription?.cancel();
    _messageSubscription = _getMessageStreamUseCase().listen(
      (message) => add(_MessageReceived(message)),
    );
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    final optimisticMessage = Message(
      id: const Uuid().v4(),
      payload: event.text,
      senderId: 'me', // Assuming 'me' is the sender
      recipientId: 'device', // The connected device
      timestamp: DateTime.now(),
      isEncrypted: false,
    );
    
    final currentMessages = List<Message>.from(state.messages)..insert(0, optimisticMessage);
    emit(MessageSendInProgress(currentMessages));

    try {
      await _sendMessageUseCase(optimisticMessage);
      emit(MessageSendSuccess(currentMessages));
    } catch (e) {
      final errorMessages = List<Message>.from(state.messages)..remove(optimisticMessage);
      emit(MessageSendFailure(errorMessages, e.toString()));
    }
  }

  void _onMessageReceived(
    _MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    final updatedMessages = List<Message>.from(state.messages)..insert(0, event.message);
    emit(ChatInitial(updatedMessages));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
} 