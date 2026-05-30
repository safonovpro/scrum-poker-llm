import {
  Room,
  CreateRoomData,
  JoinRoomData,
  StartRoundData,
  CastVoteData,
  RevealData,
} from './types';

const API_BASE = import.meta.env.VITE_API_URL || '';

// Debug: показать какой API URL используется
console.log('API_BASE:', API_BASE);
console.log('VITE_API_URL:', import.meta.env.VITE_API_URL);

export const api = {
  // Комнаты
  async createRoom(data: CreateRoomData): Promise<{ room_id: string; room_name: string; host_id: string; invite_url: string }> {
    const res = await fetch(`${API_BASE}/api/rooms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async getRoom(roomId: string): Promise<Room> {
    const res = await fetch(`${API_BASE}/api/rooms/${roomId}`);
    return res.json();
  },

  async joinRoom(roomId: string, data: JoinRoomData): Promise<{ player_id: string; nickname: string; role: string }> {
    const res = await fetch(`${API_BASE}/api/rooms/${roomId}/join`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return res.json();
  },

  // Раунды
  async startRound(roomId: string, data: StartRoundData): Promise<{ round_id: number; task_description: string | null }> {
    const res = await fetch(`${API_BASE}/api/rooms/${roomId}/rounds`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return res.json();
  },

  // Голоса
  async castVote(roundId: number, data: CastVoteData): Promise<{ vote_id: number; voted: boolean }> {
    const res = await fetch(`${API_BASE}/api/rounds/${roundId}/votes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return res.json();
  },

  async revealVotes(roundId: number, data: RevealData): Promise<{ round_id: number; votes: any[] }> {
    const res = await fetch(`${API_BASE}/api/rounds/${roundId}/reveal`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    });
    return res.json();
  },
};
