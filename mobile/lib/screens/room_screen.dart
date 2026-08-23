import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/app_bloc.dart';
import '../models/role.dart';
import '../widgets/player_list.dart';
import '../widgets/vote_cards.dart';
import '../widgets/reveal_panel.dart';

class RoomScreen extends StatelessWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            final roomName = state.room?.name ?? 'Комната';
            return Text(roomName);
          },
        ),
      ),
      body: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.room == null) {
            return const Center(child: Text('Комната не найдена'));
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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: isRoundActive
                      ? Colors.indigo.shade100
                      : Colors.green.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRoundActive
                            ? Icons.hourglass_empty
                            : Icons.check_circle,
                        color: isRoundActive ? Colors.indigo : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isRoundActive
                              ? 'Раунд активен'
                              : 'Раунд завершён',
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
                FloatingActionButton.extended(
                  onPressed: () => _showRevealDialog(context),
                  icon: const Icon(Icons.visibility),
                  label: const Text('Вскрыть карты'),
                ),

              if (!isRoundActive && isHost)
                FloatingActionButton.extended(
                  onPressed: () => _showStartRoundDialog(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Начать раунд'),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showStartRoundDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Начать раунд'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Описание задачи (необязательно)',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(StartRoundEvent(controller.text));
              Navigator.pop(ctx);
            },
            child: const Text('Начать'),
          ),
        ],
      ),
    );
  }

  void _showRevealDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вскрыть карты?'),
        content: const Text('Все голоса будут показаны участникам.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppBloc>().add(RevealVotesEvent());
              Navigator.pop(ctx);
            },
            child: const Text('Вскрыть'),
          ),
        ],
      ),
    );
  }
}
