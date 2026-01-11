import 'package:flutter/material.dart';
import 'package:chat_package/chat_package.dart';
import 'package:auth_package/auth_package.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const AuthScreen());
  }
}
