import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useApp } from '../contexts/AppContext';

export function HomePage() {
  const navigate = useNavigate();
  const { createRoom, joinRoom } = useApp();
  
  const [mode, setMode] = useState<'create' | 'join'>('create');
  const [roomName, setRoomName] = useState('');
  const [roomId, setRoomId] = useState('');
  const [nickname, setNickname] = useState('');
  const [role, setRole] = useState<'player' | 'observer'>('player');
  const [loading, setLoading] = useState(false);

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roomName || !nickname) return;
    
    setLoading(true);
    try {
      await createRoom(roomName, nickname);
      navigate('/room');
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleJoin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roomId || !nickname) return;
    
    setLoading(true);
    try {
      await joinRoom(roomId, nickname, role);
      navigate('/room');
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="home-container">
      <h1>Scrum Poker</h1>
      
      <div className="mode-toggle">
        <button
          className={mode === 'create' ? 'active' : ''}
          onClick={() => setMode('create')}
        >
          Создать комнату
        </button>
        <button
          className={mode === 'join' ? 'active' : ''}
          onClick={() => setMode('join')}
        >
          Присоединиться
        </button>
      </div>

      {mode === 'create' ? (
        <form onSubmit={handleCreate} className="form">
          <div className="form-group">
            <label>Название комнаты</label>
            <input
              type="text"
              value={roomName}
              onChange={(e) => setRoomName(e.target.value)}
              placeholder="Например: Команда Frontend"
              required
            />
          </div>
          
          <div className="form-group">
            <label>Ваш псевдоним</label>
            <input
              type="text"
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              placeholder="Alice"
              required
            />
          </div>
          
          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? 'Создаём...' : 'Создать комнату'}
          </button>
        </form>
      ) : (
        <form onSubmit={handleJoin} className="form">
          <div className="form-group">
            <label>ID комнаты</label>
            <input
              type="text"
              value={roomId}
              onChange={(e) => setRoomId(e.target.value)}
              placeholder="1b95e07f-3e35-4608-8520-38754eb77385"
              required
            />
          </div>
          
          <div className="form-group">
            <label>Ваш псевдоним</label>
            <input
              type="text"
              value={nickname}
              onChange={(e) => setNickname(e.target.value)}
              placeholder="Bob"
              required
            />
          </div>
          
          <div className="form-group">
            <label>Роль</label>
            <select value={role} onChange={(e) => setRole(e.target.value as any)}>
              <option value="player">Игрок</option>
              <option value="observer">Наблюдатель</option>
            </select>
          </div>
          
          <button type="submit" disabled={loading} className="btn-primary">
            {loading ? 'Подключаемся...' : 'Присоединиться'}
          </button>
        </form>
      )}
    </div>
  );
}
