import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/round.dart';
import '../l10n/app_localizations.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;
  final Round? activeRound;

  const PlayerList({
    super.key,
    required this.players,
    this.activeRound,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final hasVoted = activeRound?.votes.any((v) => v.playerId == player.id && v.value != null) ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: hasVoted ? Colors.green : Colors.grey.shade300,
              child: Text(
                player.nickname[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(player.nickname),
            subtitle: Text(_roleLabel(player.role, l10n)),
            trailing: hasVoted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.circle_outlined, color: Colors.grey),
          ),
        );
      },
    );
  }

  String _roleLabel(Role role, AppLocalizations l10n) {
    switch (role) {
      case Role.host:
        return l10n.host;
      case Role.player:
        return l10n.player;
      case Role.observer:
        return l10n.observer;
    }
  }
}
