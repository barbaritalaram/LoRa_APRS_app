import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:src/domain/entities/device.dart';
import 'package:src/injection_container.dart';
import 'package:src/presentation/features/chat/bloc/chat_bloc.dart';
import 'package:src/presentation/features/chat/view/chat_view.dart';

class ChatPage extends StatelessWidget {
  final Device device;
  const ChatPage({super.key, required this.device});

  static Route<void> route({required Device device}) {
    return MaterialPageRoute(
      builder: (_) => ChatPage(device: device),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ChatBloc>()..add(SubscriptionRequested()),
      child: ChatView(device: device),
    );
  }
} 