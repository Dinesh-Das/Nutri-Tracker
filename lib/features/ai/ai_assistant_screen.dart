import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/services/ai_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/widgets/ai_message_bubble.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({
    super.key,
    this.initialPrompt,
    this.showAppBar = true,
  });

  final String? initialPrompt;
  final bool showAppBar;

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _controller = TextEditingController();
  final _ai = AIService();
  final _firestore = FirestoreService();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null) {
      _controller.text = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('NutriBot'),
              actions: [
                IconButton(
                  tooltip: 'New chat',
                  icon: const Icon(Icons.add_comment_outlined),
                  onPressed: () => _ai.clearChat(uid),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, String>>>(
              stream: _ai.watchChatHistory(uid),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'What should I eat today?',
                          'Give me a 7-day Indian meal plan',
                          "How is today's progress?",
                          'Healthier Indian alternatives',
                          'No-equipment home workout',
                          'Estimate calories for my meal',
                          'High-protein Indian foods',
                        ].map((prompt) {
                          return ActionChip(
                            label: Text(prompt),
                            onPressed: () {
                              _controller.text = prompt;
                              _send(uid, messages);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= messages.length) {
                      return const AIMessageBubble(
                          role: 'assistant', content: 'Typing...');
                    }
                    final message = messages[index];
                    return AIMessageBubble(
                      role: message['role'] ?? 'user',
                      content: message['content'] ?? '',
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: StreamBuilder<List<Map<String, String>>>(
                stream: _ai.watchChatHistory(uid),
                builder: (context, snapshot) {
                  final history = snapshot.data ?? [];
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Ask about Indian nutrition...',
                          ),
                        ),
                      ),
                      IconButton.filled(
                        icon: const Icon(Icons.send),
                        onPressed: _sending ? null : () => _send(uid, history),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send(String uid, List<Map<String, String>> history) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _ai.saveChatMessage(uid: uid, role: 'user', content: text);
      final user = await _firestore.getUser(uid);
      final recentHistory =
          history.length <= 12 ? history : history.sublist(history.length - 12);
      final reply = await _ai.sendMessage(
        userMessage: text,
        conversationHistory: recentHistory,
        userContext: user,
      );
      await _ai.saveChatMessage(uid: uid, role: 'assistant', content: reply);
    } catch (error) {
      await _ai.saveChatMessage(
        uid: uid,
        role: 'assistant',
        content:
            'I could not reach NutriBot right now. Please check the secure AI proxy configuration and try again.',
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
