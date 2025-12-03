import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatefulWidget {
  final int sessionId;

  const ChatPage({super.key, required this.sessionId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatMessage> messages = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool loading = false;
  bool loadingMessages = false;
  bool hasInput = false;

  @override
  void initState() {
    super.initState();
    loadMessages();
    _ctrl.addListener(() {
      if (!mounted) return;
      setState(() {
        hasInput = _ctrl.text.isNotEmpty;
      });
    });
  }

  Future<void> loadMessages() async {
    setState(() => loadingMessages = true);
    final data = await ApiService.getMessages(widget.sessionId);
    setState(() {
      messages = data.map<ChatMessage>((m) => ChatMessage.fromJson(m)).toList();
      loadingMessages = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> send() async {
    if (_ctrl.text.isEmpty) return;

    final text = _ctrl.text;
    setState(() {
      messages.add(ChatMessage(role: "user", content: text));
      loading = true;
      _ctrl.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    await ApiService.sendMessage(widget.sessionId, text);
    await loadMessages();

    setState(() => loading = false);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionId != widget.sessionId) {
      setState(() {
        messages = [];
        loading = false;
        _ctrl.clear();
      });
      loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sessionId == 0) {
      return const Center(child: Text("Select a session"));
    }

    return Column(
      children: [
        Expanded(
          child: loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : (messages.isEmpty
                    ? Center(
                        child: hasInput
                            ? const SizedBox.shrink()
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Start the conversation",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Type a message below and press Enter to send",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          for (var m in messages)
                            MessageBubble(
                              content: m.content,
                              isUser: m.role == "user",
                            ),
                          if (loading)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Thinking...",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                        ],
                      )),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  child: Builder(
                    builder: (ctx) {
                      final hasFocus = Focus.of(ctx).hasFocus;
                      return TextField(
                        controller: _ctrl,
                        cursorColor: Colors.black,
                        style: const TextStyle(color: Colors.black87),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => send(),
                        decoration: InputDecoration(
                          hintText: "Ask something...",
                          filled: true,
                          fillColor: hasFocus
                              ? Colors.white
                              : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 1.2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.send), onPressed: send),
            ],
          ),
        ),
      ],
    );
  }
}
