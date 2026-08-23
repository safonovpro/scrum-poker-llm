import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/room.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/round.dart';
import '../models/vote.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

// ==================== EVENTS ====================

abstract class AppEvent {}

class LoadRoomEvent extends AppEvent {
  final String roomId;
  LoadRoomEvent(this.roomId);
}

class CreateRoomEvent extends AppEvent {
  final String name;
  final String hostNickname;
  CreateRoomEvent(this.name, this.hostNickname);
}

class JoinRoomEvent extends AppEvent {
  final String roomId;
  final String nickname;
  final String role;
  JoinRoomEvent(this.roomId, this.nickname, this.role);
}

class StartRoundEvent extends AppEvent {
  final String taskDescription;
  StartRoundEvent(this.taskDescription);
}

class CastVoteEvent extends AppEvent {
  final int value;
  CastVoteEvent(this.value);
}

class RevealVotesEvent extends AppEvent {}

class LoadSavedPlayerEvent extends AppEvent {}

// ==================== STATUSES ====================

enum AppStatus { initial, loading, loaded, error, creating, joining, voting, revealing }

// ==================== STATE ====================

class AppState {
  final Room? room;
  final Player? currentPlayer;
  final Round? activeRound;
  final int? myVoteValue;
  final List<Map<String, dynamic>> revealedVotes;
  final AppStatus status;
  final String? error;

  const AppState({
    this.room,
    this.currentPlayer,
    this.activeRound,
    this.myVoteValue,
    this.revealedVotes = const [],
    this.status = AppStatus.initial,
    this.error,
  });

  AppState copyWith({
    Room? room,
    Player? currentPlayer,
    Round? activeRound,
    int? myVoteValue,
    List<Map<String, dynamic>>? revealedVotes,
    AppStatus? status,
    String? error,
  }) {
    return AppState(
      room: room ?? this.room,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      activeRound: activeRound ?? this.activeRound,
      myVoteValue: myVoteValue ?? this.myVoteValue,
      revealedVotes: revealedVotes ?? this.revealedVotes,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }
}

// ==================== BLOC ====================

class AppBloc extends Bloc<AppEvent, AppState> {
  final ApiService apiService;
  final SocketService socketService;

  StreamSubscription? _roomSubscription;
  StreamSubscription? _voteSubscription;
  StreamSubscription? _roundStartedSubscription;
  StreamSubscription? _roundRevealedSubscription;
  StreamSubscription? _playerJoinedSubscription;
  StreamSubscription? _playerLeftSubscription;

  AppBloc({
    required this.apiService,
    required this.socketService,
  }) : super(const AppState()) {
    on<LoadSavedPlayerEvent>(_loadSavedPlayer);
    on<CreateRoomEvent>(_createRoom);
    on<JoinRoomEvent>(_joinRoom);
    on<LoadRoomEvent>(_loadRoom);
    on<StartRoundEvent>(_startRound);
    on<CastVoteEvent>(_castVote);
    on<RevealVotesEvent>(_revealVotes);

    // WebSocket listeners
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _roomSubscription = socketService.on('room_created').listen(_onRoomCreated);
    _playerJoinedSubscription = socketService.on('player_joined').listen(_onPlayerJoined);
    _playerLeftSubscription = socketService.on('player_left').listen(_onPlayerLeft);
    _roundStartedSubscription = socketService.on('round_started').listen(_onRoundStarted);
    _voteSubscription = socketService.on('vote_cast').listen(_onVoteCast);
    _roundRevealedSubscription = socketService.on('round_revealed').listen(_onRoundRevealed);
  }

  Future<void> _loadSavedPlayer(LoadSavedPlayerEvent event, Emitter<AppState> emit) async {
    // TODO: Загрузить сохранённого игрока из SharedPreferences
    emit(state.copyWith(status: AppStatus.initial));
  }

  Future<void> _createRoom(CreateRoomEvent event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.creating));
    try {
      final data = await apiService.createRoom(
        name: event.name,
        hostNickname: event.hostNickname,
      );
      final roomId = data['room_id'];
      final hostId = data['host_id'];
      
      final room = await apiService.getRoom(roomId);
      final currentPlayer = room.players.firstWhere(
        (p) => p.id == hostId,
        orElse: () => room.players.first,
      );

      socketService.connect(roomId);

      emit(state.copyWith(
        room: room,
        currentPlayer: currentPlayer,
        status: AppStatus.loaded,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, error: e.toString()));
    }
  }

  Future<void> _joinRoom(JoinRoomEvent event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.joining));
    try {
      final data = await apiService.joinRoom(
        event.roomId,
        nickname: event.nickname,
        role: event.role,
      );
      final player = Player(
        id: data['player_id'],
        roomId: event.roomId,
        nickname: event.nickname,
        role: event.role == 'observer' ? Role.observer : Role.player,
        isReady: false,
      );

      final room = await apiService.getRoom(event.roomId);

      socketService.connect(event.roomId);

      emit(state.copyWith(
        room: room,
        currentPlayer: player,
        status: AppStatus.loaded,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, error: e.toString()));
    }
  }

  Future<void> _loadRoom(LoadRoomEvent event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));
    try {
      final room = await apiService.getRoom(event.roomId);
      final activeRound = room.recentRounds.firstWhere(
        (r) => r.isActive,
        orElse: () => throw Exception('No active round'),
      );

      emit(state.copyWith(
        room: room,
        activeRound: activeRound,
        status: AppStatus.loaded,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AppStatus.loaded,
        error: null,
      ));
    }
  }

  Future<void> _startRound(StartRoundEvent event, Emitter<AppState> emit) async {
    if (state.currentPlayer == null || state.room == null) return;
    emit(state.copyWith(status: AppStatus.loading));
    try {
      await apiService.startRound(
        state.room!.id,
        taskDescription: event.taskDescription,
        hostId: state.currentPlayer!.id,
      );
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, error: e.toString()));
    }
  }

  Future<void> _castVote(CastVoteEvent event, Emitter<AppState> emit) async {
    if (state.currentPlayer == null || state.activeRound == null) return;
    emit(state.copyWith(status: AppStatus.voting));
    try {
      await apiService.castVote(
        state.activeRound!.id,
        playerId: state.currentPlayer!.id,
        value: event.value,
      );
      emit(state.copyWith(myVoteValue: event.value, status: AppStatus.loaded));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, error: e.toString()));
    }
  }

  Future<void> _revealVotes(RevealVotesEvent event, Emitter<AppState> emit) async {
    if (state.currentPlayer == null || state.activeRound == null) return;
    emit(state.copyWith(status: AppStatus.revealing));
    try {
      final votes = await apiService.revealVotes(
        state.activeRound!.id,
        hostId: state.currentPlayer!.id,
      );
      emit(state.copyWith(
        revealedVotes: votes,
        status: AppStatus.loaded,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: AppStatus.error, error: e.toString()));
    }
  }

  void _onRoomCreated(dynamic data) {
    // Событие генерируется сразу после createRoom(), состояние уже установлено
    // через HTTP-ответ, поэтому здесь достаточно убедиться, что комната загружена
  }

  void _onPlayerJoined(dynamic data) {
    if (state.room == null) return;
    final newPlayer = Player(
      id: data['player_id'],
      roomId: data['room_id'],
      nickname: data['nickname'],
      role: data['role'] == 'observer' ? Role.observer : Role.player,
      isReady: false,
    );
    final updatedPlayers = List<Player>.from(state.room!.players)..add(newPlayer);
    final updatedRoom = state.room!.copyWith(players: updatedPlayers);
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(room: updatedRoom));
  }

  void _onPlayerLeft(dynamic data) {
    if (state.room == null) return;
    final playerIds = List<String>.from(data['player_ids']);
    final updatedPlayers = state.room!.players
        .where((p) => !playerIds.contains(p.id))
        .toList();
    final updatedRoom = state.room!.copyWith(players: updatedPlayers);
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(room: updatedRoom));
  }

  void _onRoundStarted(dynamic data) {
    final round = Round(
      id: data['round_id'],
      roomId: data['room_id'],
      taskDescription: data['task_description'],
      startedAt: DateTime.now(),
      revealedAt: null,
      isActive: true,
      votes: [],
    );
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(activeRound: round, myVoteValue: null, revealedVotes: []));
  }

  void _onVoteCast(dynamic data) {
    // Голос уже отправлен через HTTP, обновляем статус
    final playerId = data['player_id'];
    if (state.activeRound == null) return;

    final existingVotes = List<Vote>.from(state.activeRound!.votes);
    final existingIndex = existingVotes.indexWhere((v) => v.playerId == playerId);
    if (existingIndex >= 0) {
      final existing = existingVotes[existingIndex];
      existingVotes[existingIndex] = Vote(
        id: existing.id,
        roundId: existing.roundId,
        playerId: existing.playerId,
        value: existing.value,
        votedAt: existing.votedAt,
      );
    }

    final updatedRound = state.activeRound!.copyWith(votes: existingVotes);
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(activeRound: updatedRound));
  }

  void _onRoundRevealed(dynamic data) {
    final votes = List<Map<String, dynamic>>.from(data['votes']);
    // ignore: invalid_use_of_visible_for_testing_member
    emit(state.copyWith(
      activeRound: state.activeRound?.copyWith(isActive: false),
      revealedVotes: votes,
      myVoteValue: null,
    ));
  }

  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    _voteSubscription?.cancel();
    _roundStartedSubscription?.cancel();
    _roundRevealedSubscription?.cancel();
    _playerJoinedSubscription?.cancel();
    _playerLeftSubscription?.cancel();
    socketService.disconnect();
    return super.close();
  }
}
