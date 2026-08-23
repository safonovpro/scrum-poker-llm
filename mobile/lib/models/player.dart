import 'role.dart';

class Player {
  final String id;
  final String roomId;
  final String nickname;
  final Role role;
  final bool isReady;

  const Player({
    required this.id,
    required this.roomId,
    required this.nickname,
    required this.role,
    required this.isReady,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      nickname: json['nickname'] as String,
      role: Role.values.firstWhere(
        (r) => r.toString() == 'Role.${json['role']}',
        orElse: () => Role.player,
      ),
      isReady: json['is_ready'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'nickname': nickname,
      'role': role.toString().split('.').last,
      'is_ready': isReady,
    };
  }
}
