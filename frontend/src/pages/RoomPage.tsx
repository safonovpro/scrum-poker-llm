import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useApp } from '../contexts/AppContext';
import { FullVote } from '../types';

const CARDS = [0, 1, 2, 3, 5, 8, 13, 21, 34, 55, '?'];

interface RoomPageProps {
  roomId?: string;
}

export function RoomPage({ roomId: propRoomId }: RoomPageProps) {
  const navigate = useNavigate();
  const {
    room,
    currentPlayer,
    activeRound,
    activeRoundTask,
    myVote,
    allVotes,
    startRound,
    castVote,
    revealVotes,
    loadRoom,
    setCurrentPlayer,
    loading,
    error,
  } = useApp();

  const [selectedCard, setSelectedCard] = useState<number | null>(null);
  const [hasStartedLoading, setHasStartedLoading] = useState(false);
  const [taskDescription, setTaskDescription] = useState('');

  // Загружаем комнату и currentPlayer по roomId из URL при монтировании
  useEffect(() => {
    if (!propRoomId || hasStartedLoading) return;
    
    console.log('Loading room:', propRoomId);
    setHasStartedLoading(true);
    
    loadRoom(propRoomId).then(() => {
      console.log('Room loaded');
      
      // Сразу пробуем загрузить текущего игрока из localStorage
      const savedPlayerId = localStorage.getItem('currentPlayerId');
      console.log('Saved player ID:', savedPlayerId);
      
      if (savedPlayerId) {
        // Ждём немного чтобы room обновился в контексте
        const checkPlayer = setInterval(() => {
          if (room && room.id === propRoomId) {
            const savedPlayer = room.players.find(p => p.id === savedPlayerId);
            console.log('Found player:', savedPlayer);
            if (savedPlayer) {
              setCurrentPlayer(savedPlayer);
              clearInterval(checkPlayer);
            }
          }
        }, 100);
        
        // Очищаем через 3 секунды
        setTimeout(() => clearInterval(checkPlayer), 3000);
      }
    }).catch((err) => {
      console.error('Failed to load room:', err);
      navigate('/');
    });
  }, [propRoomId, hasStartedLoading]);

  // Отдельный эффект для поиска currentPlayer после загрузки комнаты
  useEffect(() => {
    if (!propRoomId || !room || room.id !== propRoomId || currentPlayer || !hasStartedLoading) return;
    
    const savedPlayerId = localStorage.getItem('currentPlayerId');
    if (savedPlayerId) {
      const savedPlayer = room.players.find(p => p.id === savedPlayerId);
      if (savedPlayer) {
        console.log('Found player from localStorage (2nd check):', savedPlayer);
        setCurrentPlayer(savedPlayer);
      }
    }
  }, [room, propRoomId, currentPlayer, setCurrentPlayer, hasStartedLoading]);
    
  // Таймаут для проверки загрузки комнаты (чтобы не делать навигацию слишком рано)
  const [loadTimeout, setLoadTimeout] = useState(false);
  useEffect(() => {
    if (hasStartedLoading && !loadTimeout) {
      const timeout = setTimeout(() => {
        setLoadTimeout(true);
      }, 3000); // Даем 3 секунды на загрузку
      return () => clearTimeout(timeout);
    }
  }, [hasStartedLoading, loadTimeout]);
    
  useEffect(() => {
    console.log('RoomPage useEffect - room:', room?.id, 'currentPlayer:', currentPlayer?.id, 'propRoomId:', propRoomId, 'hasStartedLoading:', hasStartedLoading, 'loadTimeout:', loadTimeout);
    
    // Если нет roomId в пропсах - возвращаемся на главную
    if (!propRoomId) {
      console.log('No roomId - navigating to /');
      navigate('/');
      return;
    }
    
    // Если ещё не начали загружать - не делаем ничего
    if (!hasStartedLoading) {
      console.log('Not started loading yet...');
      return;
    }
    
    // Если roomId не совпадает с комнатой - возвращаемся
    if (room && room.id !== propRoomId) {
      console.log('roomId mismatch - navigating to /');
      navigate('/');
      return;
    }
    
    // Если комната не загрузилась за 3 секунды - возвращаемся
    if (!room && loadTimeout) {
      console.log('Room not loaded after timeout - navigating to /');
      navigate('/');
      return;
    }
    
    // Если комната загружена, но нет currentPlayer - ждём ещё немного
    if (room && room.id === propRoomId && !currentPlayer) {
      console.log('Room loaded, waiting for currentPlayer...');
      return;
    }
    
    // Если есть комната и currentPlayer - всё ок
    if (room && currentPlayer) {
      console.log('Room and currentPlayer loaded - staying');
      return;
    }
    
    // Иначе ждём
    console.log('Waiting...');
  }, [propRoomId, room, currentPlayer, navigate, hasStartedLoading, loadTimeout]);

  if (!hasStartedLoading || (!room && !loadTimeout) || !currentPlayer) {
    return <div className="loading">Загрузка...</div>;
  }

  const isHost = currentPlayer.role === 'host';
  const isObserver = currentPlayer.role === 'observer';
  const hasVoted = myVote !== null;

  const handleStartRound = async () => {
    try {
      await startRound(taskDescription);
      setTaskDescription('');
      setSelectedCard(null);
    } catch (err) {
      console.error(err);
    }
  };

  const handleVote = async (value: number | null) => {
    if (value === null || !activeRound) return;
    try {
      await castVote(value);
      setSelectedCard(value);
    } catch (err) {
      console.error(err);
    }
  };

  const handleReveal = async () => {
    try {
      await revealVotes();
    } catch (err) {
      console.error(err);
    }
  };

  // Проверяем проголосовал ли игрок в текущем раунде
  const getPlayerVoteStatus = (playerId: string) => {
    if (playerId === currentPlayer.id) {
      return { voted: hasVoted, value: myVote };
    }
    const vote = allVotes.find(v => v.player_id === playerId);
    return { voted: !!vote, value: null };
  };

  return (
    <div className="room-container">
      <header className="room-header">
        <h1>{room.name}</h1>
        <div className="room-info">
          <span>ID: {room.id.slice(0, 8)}...</span>
          <a
            href={`${window.location.origin}/?room=${room.id}`}
            className="invite-link"
            onClick={(e) => {
              e.preventDefault();
              navigator.clipboard.writeText(`${window.location.origin}/?room=${room.id}`);
              alert('Ссылка скопирована!');
            }}
          >
            Копировать ссылку
          </a>
        </div>
      </header>

      {error && <div className="error-message">{error}</div>}

      {/* Участники */}
      <section className="players-section">
        <h2>Участники</h2>
        <div className="players-grid">
          {room.players.map((player) => (
            <div
              key={player.id}
              className={`player-card ${player.id === currentPlayer.id ? 'me' : ''}`}
            >
              <span className="player-nickname">{player.nickname}</span>
              <span className={`player-role ${player.role}`}>
                {player.role === 'host' ? '👑 Ведущий' : 
                 player.role === 'observer' ? '👁 Наблюдатель' : '👤 Игрок'}
              </span>
              {activeRound && (
                <span className="vote-status">
                  {player.role !== 'observer' && (
                    <VoteIndicator 
                      playerId={player.id} 
                      getPlayerVoteStatus={getPlayerVoteStatus}
                    />
                  )}
                </span>
              )}
            </div>
          ))}
        </div>
      </section>

      {/* Раунд */}
      {isHost && !activeRound && (
        <section className="start-round-section">
          <h2>Начать новый раунд</h2>
          <div className="start-round-form">
            <input
              type="text"
              value={taskDescription}
              onChange={(e) => setTaskDescription(e.target.value)}
              placeholder="Описание стори"
              className="task-input"
            />
            <button
              onClick={handleStartRound}
              className="btn-primary"
              disabled={loading}
            >
              Начать раунд
            </button>
          </div>
        </section>
      )}

      {activeRound && (
        <section className="active-round-section">
          <h2>
            {activeRoundTask || `Раунд #${activeRound}`}
          </h2>

          {!isObserver && (
            <div className="voting-cards">
              {CARDS.map((card) => (
                <button
                  key={card}
                  className={`card ${selectedCard === card ? 'selected' : ''}`}
                  onClick={() => handleVote(typeof card === 'number' ? card : null)}
                  disabled={false}
                >
                  {card}
                </button>
              ))}
            </div>
          )}

          {hasVoted && (
            <div className="vote-confirmed">
              ✅ Вы выбрали карту {myVote}
            </div>
          )}

          {isHost && (
            <button
              onClick={handleReveal}
              className="btn-primary"
            >
              Вскрыть карты
            </button>
          )}
        </section>
      )}

      {/* Результаты - показываем только после вскрытия карт */}
      {!activeRound && allVotes.length > 0 && (
        <section className="results-section">
          <h2>
            Результаты
            {(() => {
              const median = calculateMedian(allVotes);
              const average = calculateAverage(allVotes);
              return (median !== null || average !== null) ? (
                <>
                  {median !== null && <span className="median-value">Медиана — {median}</span>}
                  {average !== null && <span className="median-value">Среднее — {average}</span>}
                </>
              ) : null;
            })()}
          </h2>
          <div className="results-grid">
            {allVotes.map((vote) => (
              <div key={vote.player_id} className="result-card">
                <span className="result-nickname">{vote.player_nickname}</span>
                <span className="result-value">{vote.value ?? '?'}</span>
              </div>
            ))}
          </div>
        </section>
      )}
    </div>
  );
}

function VoteIndicator({ playerId, getPlayerVoteStatus }: { playerId: string; getPlayerVoteStatus: (id: string) => { voted: boolean; value: number | null } }) {
  const voteData = getPlayerVoteStatus(playerId);
  
  if (voteData.voted) {
    return <span className="voted">✓</span>;
  }
  
  return <span className="not-voted">⏳</span>;
}

function calculateMedian(votes: FullVote[]): number | null {
  const values = votes
    .map(v => v.value)
    .filter((v): v is number => v !== null)
    .sort((a, b) => a - b);
  
  if (values.length === 0) return null;
  
  const mid = Math.floor(values.length / 2);
  
  if (values.length % 2 === 0) {
    // Чётное количество - берём большее из двух средних
    return Math.max(values[mid - 1], values[mid]);
  } else {
    // Нечётное количество - берём среднее
    return values[mid];
  }
}

function calculateAverage(votes: FullVote[]): number | null {
  const values = votes
    .map(v => v.value)
    .filter((v): v is number => v !== null);
  
  if (values.length === 0) return null;
  
  const sum = values.reduce((a, b) => a + b, 0);
  return Math.round(sum / values.length * 10) / 10; // Округляем до 1 знака после запятой
}
