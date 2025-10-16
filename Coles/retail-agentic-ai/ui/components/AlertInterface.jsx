import React, { useState, useEffect } from 'react';
import { Search, Mic, Send, X } from 'lucide-react';

export default function AlertInterface() {
  const [alerts, setAlerts] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    loadAlerts();
    const interval = setInterval(loadAlerts, 30000); // Refresh every 30s
    return () => clearInterval(interval);
  }, []);

  const loadAlerts = async () => {
    try {
      const response = await fetch('/api/alerts');
      const data = await response.json();
      setAlerts(data.alerts || []);
    } catch (error) {
      console.error('Error loading alerts:', error);
    }
  };

  const handleDismiss = async (alertId) => {
    try {
      await fetch(`/api/alerts/${alertId}/dismiss`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ resolution_notes: 'Dismissed by user' })
      });
      loadAlerts();
    } catch (error) {
      console.error('Error dismissing alert:', error);
    }
  };

  const getPriorityColor = (priority) => {
    const colors = {
      critical: 'red',
      actionable: 'yellow',
      informational: 'blue'
    };
    return colors[priority] || 'gray';
  };

  return (
    <div className="alert-interface">
      <div className="mode-badge mode-badge-alert">Alert Mode</div>
      
      <div className="alert-header">
        <h2>Monitor & Respond</h2>
        <p>Stay informed about critical updates and take action on what matters</p>
      </div>

      <div className="loading-placeholder">...</div>

      <div className="alerts-list">
        {alerts.map(alert => (
          <div 
            key={alert.id} 
            className={`alert-card alert-priority-${getPriorityColor(alert.priority)}`}
          >
            <button 
              onClick={() => handleDismiss(alert.id)}
              className="dismiss-button"
            >
              <X size={16} />
            </button>
            
            <div className="alert-icon-container">
              <div className={`alert-icon alert-icon-${getPriorityColor(alert.priority)}`}>
                !
              </div>
            </div>

            <div className="alert-content">
              <div className="alert-title-row">
                <h3>{alert.title}</h3>
                <span className={`priority-tag priority-${alert.priority}`}>
                  {alert.priority}
                </span>
              </div>
              
              <p className="alert-description">{alert.description}</p>
              
              <div className="alert-meta">
                <span className="alert-source">{alert.source}</span>
                <span className="alert-time">{alert.timestamp}</span>
              </div>

              <div className="alert-actions">
                <button className="btn-take-action">Take Action</button>
                <button className="btn-investigate">Investigate</button>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="search-container">
        <Search size={20} className="search-icon" />
        <input
          type="text"
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          placeholder="Search alerts or type command..."
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
