import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { io, Socket } from 'socket.io-client';
import { api } from '../api';
import { Room, Player, FullVote } from '../types';

interface AppContextType {
  room: Room | null;
  currentPlayer: Player | null;
  activeRound: number | null;
  myVote: number | null;
  allVotes: FullVote[];
  socket: Socket | null;
  loading: boolean;
  error: string | null;
  
  // Actions
  createRoom: (name: string, hostNickname: string) => Promise<void>;
  joinRoom: (roomId: string, nickname: string, role: 'player' | 'observer') => Promise<void>;
  loadRoom: (roomId: string) => Promise<void>;
  setCurrentPlayer: (player: Player | null) => void;
  startRound: (taskDescription: string) => Promise<void>;
  castVote: (value: number) => Promise<void>;
  revealVotes: () => Promise<void>;
  refreshRoom: () => Promise<void>;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export function AppProvider({ children }: { children: ReactNode }) {
  const [room, setRoom] = useState<Room | null>(null);
  const [currentPlayer, setCurrentPlayer] = useState<Player | null>(null);
  const [activeRound, setActiveRound] = useState<number | null>(null);
  const [myVote, setMyVote] = useState<number | null>(null);
  const [allVotes, setAllVotes] = useState<FullVote[]>([]);
  const [socket, setSocket] = useState<Socket | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Инициализация WebSocket
  useEffect(() => {
    const socketInstance = io('/', {
      transports: ['polling'],
      autoConnect: true,
    });

    socketInstance.on('connect', () => {
      console.log('WebSocket connected');
    });

    socketInstance.on('room_created', (data) => {
      console.log('Room created:', data);
      refreshRoom();
    });

    socketInstance.on('player_joined', (data) => {
      console.log('Player joined:', data);
      refreshRoom();
    });

    socketInstance.on('round_started', (data) => {
      console.log('Round started:', data);
      setActiveRound(data.round_id);
      setMyVote(null);
      setAllVotes([]);
    });

    socketInstance.on('vote_cast', (data) => {
      console.log('Vote cast:', data);
      if (data.player_id === currentPlayer?.id) {
        setMyVote(myVote);
      }
      refreshRoom();
    });

    socketInstance.on('round_revealed', (data) => {
      console.log('Round revealed:', data);
      setActiveRound(null);
      setAllVotes(data.votes || []);
      setMyVote(null);
    });

    setSocket(socketInstance);

    return () => {
      socketInstance.close();
    };
  }, [currentPlayer]);

  const refreshRoom = async () => {
    if (!room) return;
    try {
      const roomData = await api.getRoom(room.id);
      setRoom(roomData);
      
      // Найти активного игрока
      if (currentPlayer) {
        const player = roomData.players.find(p => p.id === currentPlayer.id);
        if (player) setCurrentPlayer(player);
      }
      
      // Найти активный раунд
      const active = roomData.recent_rounds.find(r => r.is_active);
      setActiveRound(active?.id || null);
    } catch (err) {
      console.error('Failed to refresh room:', err);
    }
  };

  const createRoom = async (name: string, hostNickname: string) => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.createRoom({ name, host_nickname: hostNickname });
      const roomData = await api.getRoom(data.room_id);
      
      setRoom(roomData);
      const player = roomData.players.find(p => p.id === data.host_id) || null;
      setCurrentPlayer(player);
      
      // Сохраняем player_id в localStorage
      if (player) {
        localStorage.setItem('currentPlayerId', player.id);
        localStorage.setItem('currentPlayerNickname', hostNickname);
      }
      
      // Обновляем URL с room_id
      window.history.pushState({}, '', `/room/${data.room_id}`);
      
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Failed to create room');
      setLoading(false);
      throw err;
    }
  };

  const joinRoom = async (roomId: string, nickname: string, role: 'player' | 'observer') => {
    setLoading(true);
    setError(null);
    try {
      const data = await api.joinRoom(roomId, { nickname, role });
      const roomData = await api.getRoom(roomId);
      
      setRoom(roomData);
      const player = roomData.players.find(p => p.id === data.player_id) || null;
      setCurrentPlayer(player);
      
      // Сохраняем player_id в localStorage
      if (player) {
        localStorage.setItem('currentPlayerId', player.id);
        localStorage.setItem('currentPlayerNickname', nickname);
      }
      
      // Обновляем URL с room_id
      window.history.pushState({}, '', `/room/${roomId}`);
      
      // Подключиться к комнате через WebSocket
      if (socket) {
        socket.emit('join_room', { room_id: roomId });
      }
      
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Failed to join room');
      setLoading(false);
      throw err;
    }
  };

  const loadRoom = async (roomId: string) => {
    try {
      const roomData = await api.getRoom(roomId);
      setRoom(roomData);
    } catch (err: any) {
      console.error('Failed to load room:', err);
      throw err;
    }
  };

  const startRound = async (taskDescription: string) => {
    if (!room || !currentPlayer) return;
    try {
      await api.startRound(room.id, { task_description: taskDescription, host_id: currentPlayer.id });
    } catch (err: any) {
      setError(err.message || 'Failed to start round');
      throw err;
    }
  };

  const castVote = async (value: number) => {
    if (!activeRound || !currentPlayer) return;
    try {
      await api.castVote(activeRound, { player_id: currentPlayer.id, value });
      setMyVote(value);
    } catch (err: any) {
      setError(err.message || 'Failed to cast vote');
      throw err;
    }
  };

  const revealVotes = async () => {
    if (!activeRound || !currentPlayer) return;
    try {
      await api.revealVotes(activeRound, { host_id: currentPlayer.id });
    } catch (err: any) {
      setError(err.message || 'Failed to reveal votes');
      throw err;
    }
  };

  return (
    <AppContext.Provider
      value={{
        room,
        currentPlayer,
        activeRound,
        myVote,
        allVotes,
        socket,
        loading,
        error,
        createRoom,
        joinRoom,
        loadRoom,
        setCurrentPlayer,
        startRound,
        castVote,
        revealVotes,
        refreshRoom,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}
