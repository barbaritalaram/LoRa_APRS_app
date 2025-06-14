import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/domain/entities/message.dart';
import 'package:src/presentation/features/chat/bloc/chat_bloc.dart';

class ChatView extends StatelessWidget {
  final Device device;
  const ChatView({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Say hello!'),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isSending =
                        index == 0 && state is MessageSendInProgress;
                    return MessageBubble(
                      message: message,
                      isSending: isSending,
                    );
                  },
                );
              },
            ),
          ),
          const MessageInputField(),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSending;
  const MessageBubble({super.key, required this.message, this.isSending = false});

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'me';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isMe ? Theme.of(context).primaryColorLight.withOpacity(0.8) : Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message.payload),
              if (isSending) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MessageInputField extends StatefulWidget {
  const MessageInputField({super.key});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatBloc>().add(MessageSent(text));
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
} 