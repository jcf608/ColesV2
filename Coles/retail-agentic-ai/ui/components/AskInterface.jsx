import React, { useState } from 'react';
import { Send, Mic } from 'lucide-react';

export default function AskInterface() {
  const [message, setMessage] = useState('');
  const [conversation, setConversation] = useState([]);

  const suggestions = [
    "Which stores need additional staff this weekend?",
    "How can I get restock sooner? What are my options?",
    "Staff allocation optimization recommendations"
  ];

  // Validate and format tool calls to ensure proper schema alignment
  const formatToolCalls = (toolCalls) => {
    if (!Array.isArray(toolCalls)) return [];
    
    return toolCalls.map(tool => ({
      name: tool.name || 'Unknown Tool',
      input: tool.input || tool.parameters || {},
      result: tool.result || tool.response || null,
      status: tool.status || 'executed'
    }));
  };

  const handleSend = async () => {
    if (!message.trim()) return;

    const userMessage = { role: 'user', content: message };
    setConversation([...conversation, userMessage]);
    setMessage('');

    // Call API
    try {
      const response = await fetch('/api/ask', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message })
      });
      const data = await response.json();
      
      setConversation(prev => [...prev, {
        role: 'assistant',
        content: data.response,
        toolCalls: formatToolCalls(data.tool_calls)
      }]);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div className="ask-interface">
      <div className="mode-badge">Ask Mode</div>
      <h2>Ask</h2>
      
      <div className="ask-header">
        <h3>Hi Carina, what would you like to know?</h3>
        <p>Ask a question to get detailed, actionable insights for your stores</p>
      </div>

      <div className="suggestions">
        {suggestions.map((suggestion, idx) => (
          <button
            key={idx}
            onClick={() => setMessage(suggestion)}
            className="suggestion-card"
          >
            {suggestion}
          </button>
        ))}
      </div>

      <div className="conversation">
        {conversation.map((msg, idx) => (
          <div key={idx} className={`message message-${msg.role}`}>
            <div className="message-content">{msg.content}</div>
            {msg.toolCalls && msg.toolCalls.length > 0 && (
              <div className="tool-calls">
                {msg.toolCalls.map((tool, i) => (
                  <div key={i} className="tool-call">
                    <div className="tool-header">
                      <strong>🔧 {tool.name}</strong>
                      <span className="tool-status">Executed</span>
                    </div>
                    {tool.input && (
                      <div className="tool-input">
                        <h5>Input Parameters:</h5>
                        <pre>{JSON.stringify(tool.input, null, 2)}</pre>
                      </div>
                    )}
                    {tool.result && (
                      <div className="tool-result">
                        <h5>Response:</h5>
                        <pre>{typeof tool.result === 'string' ? tool.result : JSON.stringify(tool.result, null, 2)}</pre>
                      </div>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="input-container">
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSend()}
          placeholder="Ask here ..."
          className="message-input"
        />
        <button onClick={handleSend} className="send-button">
          <Send size={20} />
        </button>
        <button className="voice-button">
          <Mic size={20} />
        </button>
      </div>
    </div>
  );
}
