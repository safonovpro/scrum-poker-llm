import { createContext, useContext, useState, useEffect, ReactNode, useRef } from 'react';
import { io, Socket } from 'socket.io-client';
import { api } from '../api';
import { Room, Player, FullVote, VoteStatus } from '../types';

interface AppContextType {
  room: Room | null;
  currentPlayer: Player | null;
  activeRound: number | null;
  activeRoundTask: string | null;
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
  const [activeRoundTask, setActiveRoundTask] = useState<string | null>(null);
  const [myVote, setMyVote] = useState<number | null>(null);
  const [allVotes, setAllVotes] = useState<FullVote[]>([]);
  const [socket, setSocket] = useState<Socket | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Рефы для актуальных значений в слушателях
  const roomRef = useRef<Room | null>(room);
  const currentPlayerRef = useRef<Player | null>(currentPlayer);
  const socketRef = useRef<Socket | null>(socket);
  
  // Обновляем рефы при изменении
  useEffect(() => {
    roomRef.current = room;
  }, [room]);
  
  useEffect(() => {
    currentPlayerRef.current = currentPlayer;
  }, [currentPlayer]);

  useEffect(() => {
    socketRef.current = socket;
  }, [socket]);
  
  // Автоматическая подписка на комнату когда room устанавливается
  useEffect(() => {
    if (room && socketRef.current) {
      console.log('📡 Auto-subscribing to room:', room.id);
      socketRef.current.emit('join_room', { room_id: room.id });
    } else if (room && !socketRef.current) {
      console.log('⚠️ Room set but socket not ready yet');
    }
  }, [room]);

  // Инициализация WebSocket
  useEffect(() => {
    const socketUrl = import.meta.env.VITE_API_URL || '/';
    const socketInstance = io(socketUrl, {
      transports: ['polling'],
      autoConnect: true,
    });

    socketInstance.on('connect', () => {
      console.log('WebSocket connected');
    });

    socketInstance.on('disconnect', () => {
      console.log('WebSocket disconnected');
    });

    socketInstance.on('room_created', (data) => {
      console.log('📢 room_created received:', data);
      const currentRoom = roomRef.current;
      console.log('Current room:', currentRoom?.id);
      if (currentRoom && currentRoom.id === data.room_id) {
        console.log('Updating room after room_created');
        api.getRoom(data.room_id).then(setRoom).catch(err => console.error(err));
      }
    });

    socketInstance.on('player_joined', (data) => {
      console.log('📢 player_joined received:', data);
      const currentRoom = roomRef.current;
      console.log('Current room:', currentRoom?.id);
      console.log('Event room_id:', data.room_id);
      if (currentRoom && currentRoom.id === data.room_id) {
        console.log('Updating room after player_joined');
        api.getRoom(data.room_id).then(newRoom => {
          console.log('New room players:', newRoom.players);
          setRoom(newRoom);
          // Обновляем currentPlayer если он есть
          if (currentPlayerRef.current) {
            const updatedPlayer = newRoom.players.find(p => p.id === currentPlayerRef.current!.id);
            if (updatedPlayer) {
              console.log('Updated currentPlayer:', updatedPlayer);
              setCurrentPlayer(updatedPlayer);
            } else {
              console.log('⚠️ currentPlayer not found in updated room!');
            }
          }
        }).catch(err => console.error(err));
      }
    });

    socketInstance.on('round_started', (data) => {
      console.log('Round started:', data);
      const currentRoom = roomRef.current;
      if (currentRoom && currentRoom.id === data.room_id) {
        setActiveRound(data.round_id);
        setActiveRoundTask(data.task_description || null);
        setMyVote(null);
        setAllVotes([]);
        
        // Обновляем room чтобы включить новые записи голосов
        api.getRoom(data.room_id).then(newRoom => {
          setRoom(newRoom);
        }).catch(err => console.error(err));
      }
    });

    socketInstance.on('vote_cast', (data) => {
      console.log('Vote cast:', data);
      const currentRoom = roomRef.current;
      if (currentRoom && currentRoom.id === data.room_id) {
        // Добавляем/обновляем голос в allVotes
        setAllVotes(prevVotes => {
          const exists = prevVotes.find(v => v.player_id === data.player_id);
          if (exists) {
            return prevVotes; // Значения всё равно скрыты до раскрытия
          }
          // Добавляем нового проголосовавшего
          const player = currentRoom.players.find(p => p.id === data.player_id);
          return [...prevVotes, {
            player_id: data.player_id,
            player_nickname: player?.nickname || 'Unknown',
            value: null
          }];
        });
        
        api.getRoom(data.room_id).then(newRoom => {
          setRoom(newRoom);
          if (currentPlayerRef.current) {
            const updatedPlayer = newRoom.players.find(p => p.id === currentPlayerRef.current!.id);
            if (updatedPlayer) setCurrentPlayer(updatedPlayer);
          }
        }).catch(err => console.error(err));
      }
    });

    socketInstance.on('round_revealed', (data) => {
      console.log('Round revealed:', data);
      const currentRoom = roomRef.current;
      if (currentRoom && currentRoom.id === data.room_id) {
        setActiveRound(null);
        setActiveRoundTask(null);
        setAllVotes(data.votes || []);
        setMyVote(null);
      }
    });

    setSocket(socketInstance);

    return () => {
      socketInstance.close();
    };
  }, []); // Убрали зависимости чтобы не пересоздавать слушатели

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
      
      // Обновляем URL с room_id (HashRouter format)
      window.location.hash = `#/room/${data.room_id}`;
      
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
      
      // Обновляем URL с room_id (HashRouter format)
      window.location.hash = `#/room/${roomId}`;
      
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
      
      // Найти активный раунд из загруженных данных
      const active = roomData.recent_rounds.find(r => r.is_active);
      setActiveRound(active?.id || null);
      setActiveRoundTask(active?.task_description || null);
      
      // Обновить голоса если есть активный раунд
      if (active) {
        const votes = active.votes || [];
        // Показываем только что кто-то проголосовал (без значений до раскрытия)
        setAllVotes(votes.map((v: VoteStatus) => ({
          player_id: v.player_id,
          player_nickname: roomData.players.find(p => p.id === v.player_id)?.nickname || 'Unknown',
          value: null // До раскрытия значения скрыты
        })));
      } else {
        setAllVotes([]);
      }
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
        activeRoundTask,
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
