import React, { useState, useEffect } from 'react';
import { Search, Mic, Send, ChevronDown } from 'lucide-react';

export default function ActInterface() {
  const [pendingActions, setPendingActions] = useState([]);
  const [completedActions, setCompletedActions] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadActions();
  }, []);

  const loadActions = async () => {
    try {
      const response = await fetch('/api/actions');
      const data = await response.json();
      setPendingActions(data.pending || []);
      setCompletedActions(data.completed || []);
    } catch (error) {
      console.error('Error loading actions:', error);
    }
  };

  const handleTakeAction = async (actionId) => {
    try {
      await fetch(`/api/actions/${actionId}/execute`, {
        method: 'POST'
      });
      loadActions();
    } catch (error) {
      console.error('Error executing action:', error);
    }
  };

  return (
    <div className="act-interface">
      <div className="mode-badge mode-badge-act">Act Mode</div>
      
      <div className="act-header">
        <h2>Review & Execute Actions</h2>
        <p>Confirm and execute recommended interventions</p>
      </div>

      <div className="completed-section">
        <button className="collapsible-header">
          <span>Completed Actions ({completedActions.length})</span>
          <ChevronDown size={20} />
        </button>
      </div>

      {pendingActions.length === 0 ? (
        <div className="empty-state">
          <p>No pending actions. All actions completed.</p>
        </div>
      ) : (
        <div className="actions-list">
          {pendingActions.map(action => (
            <div key={action.id} className={`action-card action-${action.priority}`}>
              <div className="action-header">
                <h3>{action.title}</h3>
                <span className={`priority-badge priority-${action.priority}`}>
                  {action.priority}
                </span>
              </div>
              <p className="action-description">{action.description}</p>
              <div className="action-meta">
                <span>{action.source}</span>
                <span>{action.timestamp}</span>
              </div>
              <div className="action-buttons">
                <button 
                  onClick={() => handleTakeAction(action.id)}
                  className="btn-take-action"
                >
                  Take Action
                </button>
                <button className="btn-investigate">
                  Investigate
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      <div className="search-container">
        <Search size={20} className="search-icon" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search actions or type command..."
          className="search-input"
        />
        <Mic size={20} className="voice-icon" />
        <button className="send-icon-btn">
          <Send size={20} />
        </button>
      </div>
    </div>
  );
}
