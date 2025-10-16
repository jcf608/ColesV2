import React from 'react';
import { MessageSquare, Zap, Bell } from 'lucide-react';

export default function ModeSelector({ currentMode, onModeChange }) {
  const modes = [
    {
      id: 'ask',
      name: 'Ask',
      icon: MessageSquare,
      color: 'blue',
      description: 'Query the system and get detailed insights'
    },
    {
      id: 'act',
      name: 'Act',
      icon: Zap,
      color: 'green',
      description: 'Review and execute recommended actions'
    },
    {
      id: 'alert',
      name: 'Alert',
      icon: Bell,
      color: 'yellow',
      description: 'Monitor outcomes and receive notifications'
    }
  ];

  return (
    <div className="mode-selector">
      <h1 className="title">Hey Carina</h1>
      <p className="subtitle">Ask questions, take actions, and manage alerts.</p>
      
      <div className="search-container">
        <input
          type="text"
          placeholder="Ask a question or search..."
          className="search-input"
        />
      </div>

      <div className="modes-grid">
        {modes.map((mode) => {
          const Icon = mode.icon;
          return (
            <button
              key={mode.id}
              onClick={() => onModeChange(mode.id)}
              className={`mode-card ${currentMode === mode.id ? 'active' : ''}`}
            >
              <div className={`icon-container icon-${mode.color}`}>
                <Icon size={24} />
              </div>
              <h3 className="mode-name">{mode.name}</h3>
              <p className="mode-description">{mode.description}</p>
            </button>
          );
        })}
      </div>

      <p className="footer-text">Select a mode to begin your workflow</p>
    </div>
  );
}
