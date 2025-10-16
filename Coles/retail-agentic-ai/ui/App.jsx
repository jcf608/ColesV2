import React, { useState } from 'react';
import ModeSelector from './components/ModeSelector';
import AskInterface from './components/AskInterface';
import ActInterface from './components/ActInterface';
import AlertInterface from './components/AlertInterface';
import './styles/app.css';

export default function App() {
  const [currentMode, setCurrentMode] = useState(null);

  const renderMode = () => {
    switch (currentMode) {
      case 'ask':
        return <AskInterface />;
      case 'act':
        return <ActInterface />;
      case 'alert':
        return <AlertInterface />;
      default:
        return <ModeSelector currentMode={currentMode} onModeChange={setCurrentMode} />;
    }
  };

  return (
    <div className="app">
      <nav className="sidebar">
        <div className="logo">CA</div>
        <div className="nav-items">
          <button onClick={() => setCurrentMode(null)} className="nav-item">🏠</button>
          <button onClick={() => setCurrentMode('ask')} className="nav-item">💬</button>
          <button onClick={() => setCurrentMode('act')} className="nav-item">⚡</button>
          <button onClick={() => setCurrentMode('alert')} className="nav-item">🔔</button>
        </div>
      </nav>
      <main className="main-content">
        {renderMode()}
      </main>
    </div>
  );
}
