class Vote {
  final int id;
  final int roundId;
  final String playerId;
  final int? value;
  final DateTime votedAt;

  const Vote({
    required this.id,
    required this.roundId,
    required this.playerId,
    required this.value,
    required this.votedAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as int,
      roundId: json['round_id'] as int,
      playerId: json['player_id'] as String,
      value: json['value'] as int?,
      votedAt: DateTime.parse(json['voted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'round_id': roundId,
      'player_id': playerId,
      'value': value,
      'voted_at': votedAt.toIso8601String(),
    };
  }
}
