class ChatSession {
  final int id;
  final String? name;
  final DateTime? createdAt;

  ChatSession({required this.id, this.name, this.createdAt});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
