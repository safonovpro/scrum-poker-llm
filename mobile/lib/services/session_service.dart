import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyPlayerId = 'player_id';
  static const _keyRoomId = 'room_id';
  static const _keyNickname = 'nickname';
  static const _keyRole = 'role';

  Future<void> saveSession({
    required String playerId,
    required String roomId,
    required String nickname,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlayerId, playerId);
    await prefs.setString(_keyRoomId, roomId);
    await prefs.setString(_keyNickname, nickname);
    await prefs.setString(_keyRole, role);
  }

  Future<Map<String, String>?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final playerId = prefs.getString(_keyPlayerId);
    final roomId = prefs.getString(_keyRoomId);
    final nickname = prefs.getString(_keyNickname);
    final role = prefs.getString(_keyRole);

    if (playerId == null || roomId == null || nickname == null || role == null) {
      return null;
    }

    return {
      'player_id': playerId,
      'room_id': roomId,
      'nickname': nickname,
      'role': role,
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayerId);
    await prefs.remove(_keyRoomId);
    await prefs.remove(_keyNickname);
    await prefs.remove(_keyRole);
  }
}
