import 'package:flutter/material.dart';

class AIMessageBubble extends StatelessWidget {
  const AIMessageBubble({
    super.key,
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          content,
          style: TextStyle(color: isUser ? Colors.white : null),
        ),
      ),
    );
  }
}
