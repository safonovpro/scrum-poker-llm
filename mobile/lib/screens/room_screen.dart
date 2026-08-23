import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/role.dart';
import '../l10n/app_localizations.dart';
import '../widgets/player_list.dart';
import '../widgets/vote_cards.dart';
import '../widgets/reveal_panel.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            final roomName = state.room?.name ?? l10n.createRoom;
            return Text(roomName);
          },
        ),
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading) {
            return Center(child: Text(l10n.loading));
          }

          if (state.room == null) {
            return Center(child: Text(l10n.roomNotFound));
          }

          final room = state.room!;
          final activeRound = state.activeRound;
          final currentPlayer = state.currentPlayer;
          final isHost = currentPlayer?.role == Role.host;
          final isRoundActive = activeRound != null && activeRound.isActive;

          return Column(
            children: [
              // Статус раунда
              if (activeRound != null)
                AnimatedSlide(
                  offset: const Offset(0, 0),
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: isRoundActive
                          ? Colors.indigo.shade100
                          : Colors.green.shade100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return RotationTransition(
                                turns: animation,
                                child: child,
                              );
                            },
                            child: Icon(
                              isRoundActive
                                  ? Icons.hourglass_empty
                                  : Icons.check_circle,
                              key: ValueKey(isRoundActive),
                              color: isRoundActive ? Colors.indigo : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isRoundActive
                                  ? l10n.roundActive
                                  : l10n.roundFinished,
                              style: TextStyle(
                                color: isRoundActive ? Colors.indigo.shade900 : Colors.green.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Список игроков
              Expanded(
                child: PlayerList(
                  players: room.players,
                  activeRound: activeRound,
                ),
              ),

              // Карты голосования или раскрытие
              if (isRoundActive && currentPlayer != null)
                VoteCards(
                  playerId: currentPlayer.id,
                  onVote: (value) {
                    context.read<AppBloc>().add(CastVoteEvent(value));
                  },
                ),

              if (state.revealedVotes.isNotEmpty)
                RevealPanel(votes: state.revealedVotes),

              // FAB для действий
              if (isRoundActive && isHost)
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _showRevealDialog(context, l10n);
                    },
                    icon: const Icon(Icons.visibility),
                    label: Text(l10n.revealCards),
                  ),
                ),

              if (!isRoundActive && isHost)
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showStartRoundDialog(context, l10n);
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.startRound),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showStartRoundDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.startRoundTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.taskDescription,
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(StartRoundEvent(controller.text));
              Navigator.pop(ctx);
            },
            child: Text(l10n.start),
          ),
        ],
      ),
    );
  }

  void _showRevealDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.revealTitle),
        content: Text(l10n.revealContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(RevealVotesEvent());
              Navigator.pop(ctx);
            },
            child: Text(l10n.reveal),
          ),
        ],
      ),
    );
  }
}
