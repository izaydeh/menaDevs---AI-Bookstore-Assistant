import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  /// Get all sessions
  static Future<List<dynamic>> getSessions() async {
    final res = await http.get(Uri.parse('$baseUrl/sessions'));
    return jsonDecode(res.body);
  }

  /// Create new session
  static Future<Map<String, dynamic>> createSession(String? name) async {
    final url = name != null
        ? '$baseUrl/sessions?name=$name'
        : '$baseUrl/sessions';
    final res = await http.post(Uri.parse(url));
    return jsonDecode(res.body);
  }

  /// Get chat messages
  static Future<List<dynamic>> getMessages(int sessionId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/sessions/$sessionId/messages'),
    );
    return jsonDecode(res.body);
  }

  /// Send chat message
  static Future<Map<String, dynamic>> sendMessage(
    int sessionId,
    String message,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/chat'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"session_id": sessionId, "message": message}),
    );
    return jsonDecode(res.body);
  }

  /// Delete a session
  static Future<bool> deleteSession(int sessionId) async {
    final res = await http.delete(Uri.parse('$baseUrl/sessions/$sessionId'));
    if (res.statusCode == 200) return true;
    return false;
  }
}
