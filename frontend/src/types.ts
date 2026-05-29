export interface Room {
  id: string;
  name: string;
  created_at: string;
  is_active: boolean;
  players: Player[];
  recent_rounds: Round[];
}

export interface Player {
  id: string;
  nickname: string;
  role: 'host' | 'player' | 'observer';
  is_ready: boolean;
}

export interface Round {
  id: number;
  task_description: string | null;
  started_at: string;
  revealed_at: string | null;
  is_active: boolean;
  votes: VoteStatus[];
}

export interface VoteStatus {
  player_id: string;
  voted: boolean;
}

export interface FullVote {
  player_id: string;
  player_nickname: string;
  value: number | null;
}

export interface CreateRoomData {
  name: string;
  host_nickname: string;
}

export interface JoinRoomData {
  nickname: string;
  role: 'player' | 'observer';
}

export interface StartRoundData {
  task_description?: string;
  host_id: string;
}

export interface CastVoteData {
  player_id: string;
  value: number | null;
}

export interface RevealData {
  host_id: string;
}
