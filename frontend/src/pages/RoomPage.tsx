import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useApp } from '../contexts/AppContext';
import { FullVote } from '../types';

// Карты Фибоначчи для Scrum Poker
const CARDS = [0, 1, 2, 3, 5, 8, 13, 21, 34, 55, '?'];

export function RoomPage() {
  const navigate = useNavigate();
  const {
    room,
    currentPlayer,
    activeRound,
    myVote,
    allVotes,
    startRound,
    castVote,
    revealVotes,
    loading,
    error,
  } = useApp();

  const [taskDescription, setTaskDescription] = useState('');
  const [selectedCard, setSelectedCard] = useState<number | null>(null);
  const [showRevealConfirm, setShowRevealConfirm] = useState(false);

  useEffect(() => {
    if (!room || !currentPlayer) {
      navigate('/');
    }
  }, [room, currentPlayer, navigate]);

  if (!room || !currentPlayer) {
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
      setShowRevealConfirm(false);
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <div className="room-container">
      <header className="room-header">
        <h1>{room.name}</h1>
        <div className="room-info">
          <span>ID: {room.id.slice(0, 8)}...</span>
          <a
            href={`/?room=${room.id}`}
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
                    <VoteIndicator playerId={player.id} votes={allVotes} />
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
              placeholder="Описание задачи (необязательно)"
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
            Раунд #{activeRound}
            {taskDescription && <span className="task-desc">: {taskDescription}</span>}
          </h2>

          {!isObserver && (
            <div className="voting-cards">
              {CARDS.map((card) => (
                <button
                  key={card}
                  className={`card ${selectedCard === card ? 'selected' : ''} ${
                    hasVoted && !allVotes.find(v => v.player_id === currentPlayer.id) ? 'voted' : ''
                  }`}
                  onClick={() => handleVote(typeof card === 'number' ? card : null)}
                  disabled={hasVoted}
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

          {isHost && !showRevealConfirm && (
            <button
              onClick={() => setShowRevealConfirm(true)}
              className="btn-primary"
            >
              Вскрыть карты
            </button>
          )}

          {showRevealConfirm && (
            <div className="confirm-dialog">
              <p>Вы уверены, что хотите вскрыть карты?</p>
              <div className="confirm-buttons">
                <button onClick={handleReveal} className="btn-primary">
                  Да, вскрыть
                </button>
                <button onClick={() => setShowRevealConfirm(false)} className="btn-secondary">
                  Отмена
                </button>
              </div>
            </div>
          )}
        </section>
      )}

      {/* Результаты */}
      {allVotes.length > 0 && (
        <section className="results-section">
          <h2>Результаты</h2>
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

function VoteIndicator({ playerId, votes }: { playerId: string; votes: FullVote[] }) {
  const myVoteData = votes.find(v => v.player_id === playerId);
  
  if (myVoteData) {
    return <span className="voted">{myVoteData.value ?? '?'}</span>;
  }
  
  return <span className="not-voted">⏳</span>;
}
