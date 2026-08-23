import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiService(this.baseUrl);

  Future<Room> getRoom(String roomId) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/rooms/$roomId'));
    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load room: ${response.statusCode}');
    }
  }

  /// Возвращает {room_id, room_name, host_id, invite_url}
  Future<Map<String, dynamic>> createRoom({
    required String name,
    required String hostNickname,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'host_nickname': hostNickname,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to create room: ${response.statusCode}');
    }
  }

  /// Возвращает {player_id, nickname, role}
  Future<Map<String, dynamic>> joinRoom(
    String roomId, {
    required String nickname,
    required String role,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/rooms/$roomId/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nickname': nickname,
        'role': role,
      }),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to join room: ${response.statusCode}');
    }
  }

  Future<void> startRound(
    String roomId, {
    required String taskDescription,
    required String hostId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/rooms/$roomId/rounds'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'task_description': taskDescription,
        'host_id': hostId,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to start round: ${response.statusCode}');
    }
  }

  Future<void> castVote(
    int roundId, {
    required String playerId,
    required int value,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/rounds/$roundId/votes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'player_id': playerId,
        'value': value,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to cast vote: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> revealVotes(
    int roundId, {
    required String hostId,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/api/rounds/$roundId/reveal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'host_id': hostId,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to reveal votes: ${response.statusCode}');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['votes'] as List).cast<Map<String, dynamic>>();
  }

  void dispose() {
    _client.close();
  }
}