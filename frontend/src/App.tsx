import { HashRouter, Routes, Route, Navigate, useParams } from 'react-router-dom';
import { AppProvider } from './contexts/AppContext';
import { HomePage } from './pages/HomePage';
import { RoomPage } from './pages/RoomPage';
import './App.css';

function RoomPageWrapper() {
  const { roomId } = useParams();
  return <RoomPage roomId={roomId} />;
}

function App() {
  return (
    <AppProvider>
      <HashRouter>
        <div className="app-wrapper">
          <main className="app-main">
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/room/:roomId" element={<RoomPageWrapper />} />
              <Route path="/room" element={<Navigate to="/" replace />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </main>
          <footer className="app-footer">
            <a
              href="https://github.com/safonovpro/scrum-poker-llm"
              target="_blank"
              rel="noopener noreferrer"
              className="footer-link"
            >
              Репозиторий проекта на GitHub
            </a>
          </footer>
        </div>
      </HashRouter>
    </AppProvider>
  );
}

export default App;
