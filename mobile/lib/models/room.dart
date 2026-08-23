import 'player.dart';
import 'round.dart';

class Room {
  final String id;
  final String name;
  final DateTime createdAt;
  final bool isActive;
  final List<Player> players;
  final List<Round> recentRounds;

  const Room({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.isActive,
    required this.players,
    required this.recentRounds,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    final playersJson = json['players'] as List<dynamic>? ?? [];
    final players = playersJson
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    final roundsJson = json['recent_rounds'] as List<dynamic>? ?? [];
    final rounds = roundsJson
        .map((r) => Round.fromJson(r as Map<String, dynamic>))
        .toList();

    return Room(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      players: players,
      recentRounds: rounds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'players': players.map((p) => p.toJson()).toList(),
      'recent_rounds': recentRounds.map((r) => r.toJson()).toList(),
    };
  }

  Room copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    bool? isActive,
    List<Player>? players,
    List<Round>? recentRounds,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      players: players ?? this.players,
      recentRounds: recentRounds ?? this.recentRounds,
    );
  }
}
