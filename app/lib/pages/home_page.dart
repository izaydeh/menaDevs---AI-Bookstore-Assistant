import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'session_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedSessionId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SessionList(
          selectedSessionId: selectedSessionId,
          onSelect: (id) {
            setState(() {
              selectedSessionId = id;
            });
          },
          onDelete: (id) {
            setState(() {
              if (selectedSessionId == id) selectedSessionId = null;
            });
          },
        ),

        // MAIN chat window
        Expanded(
          child: selectedSessionId == null
              ? const Center(
                  child: Text(
                    "Select or create a session",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ChatPage(sessionId: selectedSessionId!),
        ),
      ],
    );
  }
}
