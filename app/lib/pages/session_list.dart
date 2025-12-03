import 'package:flutter/material.dart';
import '../api_service.dart';
import '../models/session.dart';

class SessionList extends StatefulWidget {
  final Function(int) onSelect;
  final Function(int)? onDelete;
  final int? selectedSessionId;

  const SessionList({
    super.key,
    required this.onSelect,
    this.onDelete,
    this.selectedSessionId,
  });

  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  List<ChatSession> sessions = [];
  bool _initialSelectionDone = false;

  @override
  void initState() {
    super.initState();
    loadSessions();
  }

  Future<void> loadSessions() async {
    final data = await ApiService.getSessions();
    setState(() {
      sessions = data.map<ChatSession>((s) => ChatSession.fromJson(s)).toList();
    });
    if (!_initialSelectionDone && sessions.isNotEmpty) {
      _initialSelectionDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSelect(sessions.first.id);
      });
    }
  }

  Future<void> newSession() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) {
        String input = "";
        return AlertDialog(
          title: const Text("New Session"),
          content: TextField(
            onChanged: (v) => input = v,
            decoration: const InputDecoration(labelText: "Session Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () =>
                  Navigator.pop(context, input.isEmpty ? null : input),
              child: const Text(
                "Create",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (name == null) return;

    final s = await ApiService.createSession(name);
    await loadSessions();
    widget.onSelect(s['id']);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Sessions",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(icon: const Icon(Icons.add), onPressed: newSession),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (_, i) {
                final s = sessions[i];
                final isSelected =
                    widget.selectedSessionId != null &&
                    widget.selectedSessionId == s.id;
                String? formattedDate;
                if (s.createdAt != null) {
                  final dt = s.createdAt!.toLocal();
                  const months = [
                    '',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec',
                  ];
                  formattedDate = '${months[dt.month]} ${dt.day}, ${dt.year}';
                }

                return ListTile(
                  tileColor: isSelected ? Colors.grey.shade300 : null,
                  selected: isSelected,
                  leading: isSelected
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      : const SizedBox(width: 8),
                  title: Text(
                    " ${s.name ?? ''}",
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.black87 : Colors.black,
                    ),
                  ),
                  subtitle: formattedDate != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => widget.onSelect(s.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 15),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Delete Session'),
                          content: const Text(
                            'Are you sure you want to delete this session? This will remove its messages.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      final success = await ApiService.deleteSession(s.id);
                      if (success) {
                        await loadSessions();
                        if (widget.onDelete != null) widget.onDelete!(s.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
