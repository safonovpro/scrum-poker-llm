import 'vote.dart';

class Round {
  final int id;
  final String roomId;
  final String? taskDescription;
  final DateTime startedAt;
  final DateTime? revealedAt;
  final bool isActive;
  final List<Vote> votes;

  const Round({
    required this.id,
    required this.roomId,
    this.taskDescription,
    required this.startedAt,
    this.revealedAt,
    required this.isActive,
    required this.votes,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    final votesJson = json['votes'] as List<dynamic>? ?? [];
    final votes = votesJson
        .map((v) => Vote.fromJson(v as Map<String, dynamic>))
        .toList();

    return Round(
      id: json['id'] as int,
      roomId: json['room_id'] as String,
      taskDescription: json['task_description'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      revealedAt: json['revealed_at'] != null
          ? DateTime.parse(json['revealed_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      votes: votes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'task_description': taskDescription,
      'started_at': startedAt.toIso8601String(),
      'revealed_at': revealedAt?.toIso8601String(),
      'is_active': isActive,
      'votes': votes.map((v) => v.toJson()).toList(),
    };
  }

  Round copyWith({
    int? id,
    String? roomId,
    String? taskDescription,
    DateTime? startedAt,
    DateTime? revealedAt,
    bool? isActive,
    List<Vote>? votes,
  }) {
    return Round(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      taskDescription: taskDescription ?? this.taskDescription,
      startedAt: startedAt ?? this.startedAt,
      revealedAt: revealedAt ?? this.revealedAt,
      isActive: isActive ?? this.isActive,
      votes: votes ?? this.votes,
    );
  }
}
