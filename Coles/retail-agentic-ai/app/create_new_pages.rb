#!/usr/bin/env ruby
# Version: 1.1.0 - Fixed for paths with spaces

puts "Version: 1.1.0"
puts "✨ Creating New Lovable.dev Inspired Pages"
puts "=" * 60

require 'fileutils'

# Get the current directory (should be the app directory)
APP_ROOT = File.expand_path(File.dirname(__FILE__))

puts "\n📁 Working directory: #{APP_ROOT}"
puts "\n⚠️  Make sure you're running this from the /app directory!"
puts "   Current path: #{APP_ROOT}"

# Verify we're in the right place
unless File.exist?(File.join(APP_ROOT, 'app.rb'))
  puts "\n❌ ERROR: Can't find app.rb in current directory!"
  puts "   Please run this script FROM the /app directory:"
  puts "   cd /path/to/retail-agentic-ai/app"
  puts "   ruby create_new_pages.rb"
  exit 1
end

# Create directories if needed
puts "\n📁 Ensuring directories exist..."
FileUtils.mkdir_p(File.join(APP_ROOT, 'views'))
FileUtils.mkdir_p(File.join(APP_ROOT, 'public', 'css'))
puts "✅ Directories ready"

# Modern CSS
modern_css = File.read(DATA).split("__MODERN_CSS_END__")[0]

puts "\n📝 Writing modern CSS file..."
File.write(File.join(APP_ROOT, 'public', 'css', 'modern-style.css'), modern_css)
puts "✅ Created: public/css/modern-style.css"

# Modern Layout
modern_layout = File.read(DATA).split("__MODERN_CSS_END__")[1].split("__MODERN_LAYOUT_END__")[0]

puts "\n📝 Writing new layout..."
File.write(File.join(APP_ROOT, 'views', 'modern_layout.erb'), modern_layout)
puts "✅ Created: views/modern_layout.erb"

# Home Page
home_page = File.read(DATA).split("__MODERN_LAYOUT_END__")[1].split("__HOME_PAGE_END__")[0]

puts "\n📝 Writing home page..."
File.write(File.join(APP_ROOT, 'views', 'home.erb'), home_page)
puts "✅ Created: views/home.erb"

# Ask Page
ask_page = File.read(DATA).split("__HOME_PAGE_END__")[1].split("__ASK_PAGE_END__")[0]

puts "\n📝 Writing ask page..."
File.write(File.join(APP_ROOT, 'views', 'ask.erb'), ask_page)
puts "✅ Created: views/ask.erb"

# Act Page
act_page = File.read(DATA).split("__ASK_PAGE_END__")[1].split("__ACT_PAGE_END__")[0]

puts "\n📝 Writing act page..."
File.write(File.join(APP_ROOT, 'views', 'act.erb'), act_page)
puts "✅ Created: views/act.erb"

# Alert Page
alert_page = File.read(DATA).split("__ACT_PAGE_END__")[1]

puts "\n📝 Writing alert page..."
File.write(File.join(APP_ROOT, 'views', 'alert.erb'), alert_page)
puts "✅ Created: views/alert.erb"

puts "\n" + "=" * 60
puts "✨ ALL NEW PAGES CREATED SUCCESSFULLY!"
puts "\n📋 Created Files:"
puts "   ✅ public/css/modern-style.css"
puts "   ✅ views/modern_layout.erb"
puts "   ✅ views/home.erb"
puts "   ✅ views/ask.erb"
puts "   ✅ views/act.erb"
puts "   ✅ views/alert.erb"
puts "\n💡 Next Steps:"
puts "   1. Make sure you've updated app.rb with the new routes"
puts "   2. Restart your server (Ctrl+C then ruby start.rb)"
puts "   3. Visit http://localhost:4567/home"
puts "\n🎨 Enjoy your new Lovable.dev inspired design!"
puts "=" * 60

__END__
/* ============================================
   🌟 LOVABLE.DEV INSPIRED DESIGN SYSTEM
   Clean, Minimal, Light Theme with Colored Accents
   ============================================ */

:root {
  /* Color Palette */
  --color-blue: #3B82F6;
  --color-blue-light: #DBEAFE;
  --color-green: #10B981;
  --color-green-light: #D1FAE5;
  --color-yellow: #F59E0B;
  --color-yellow-light: #FEF3C7;
  --color-red: #EF4444;
  --color-red-light: #FEE2E2;
  
  /* Neutrals */
  --bg-primary: #FFFFFF;
  --bg-secondary: #F9FAFB;
  --bg-sidebar: #1F2937;
  --text-primary: #111827;
  --text-secondary: #6B7280;
  --text-muted: #9CA3AF;
  --border: #E5E7EB;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
  
  /* Border Radius */
  --radius-sm: 0.375rem;
  --radius-md: 0.5rem;
  --radius-lg: 0.75rem;
  --radius-xl: 1rem;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body.modern-layout {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', sans-serif;
  background: var(--bg-secondary);
  color: var(--text-primary);
  line-height: 1.5;
  display: flex;
  min-height: 100vh;
}

/* ============================================
   SIDEBAR NAVIGATION
   ============================================ */

.sidebar {
  width: 60px;
  background: var(--bg-sidebar);
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1.5rem 0;
  gap: 2rem;
  position: fixed;
  left: 0;
  top: 0;
  bottom: 0;
  z-index: 1000;
}

.sidebar-logo {
  font-size: 1.25rem;
  font-weight: 700;
  color: white;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #3B82F6 0%, #8B5CF6 100%);
  border-radius: var(--radius-md);
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  width: 100%;
  align-items: center;
}

.sidebar-link {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #9CA3AF;
  text-decoration: none;
  border-radius: var(--radius-md);
  transition: all 0.2s;
  font-size: 1.25rem;
}

.sidebar-link:hover, .sidebar-link.active {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.sidebar-user {
  margin-top: auto;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
}

.sidebar-user img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* ============================================
   MAIN CONTENT AREA
   ============================================ */

.main-content {
  flex: 1;
  margin-left: 60px;
  display: flex;
  flex-direction: column;
}

.top-bar {
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border);
  padding: 1rem 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.mode-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  font-weight: 600;
}

.mode-badge.ask-mode {
  background: var(--color-blue-light);
  color: var(--color-blue);
}

.mode-badge.act-mode {
  background: var(--color-green-light);
  color: var(--color-green);
}

.mode-badge.alert-mode {
  background: var(--color-yellow-light);
  color: var(--color-yellow);
}

.btn-publish {
  background: var(--text-primary);
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: var(--radius-md);
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-publish:hover {
  opacity: 0.9;
}

.content-wrapper {
  flex: 1;
  padding: 3rem 2rem;
  max-width: 1200px;
  width: 100%;
  margin: 0 auto;
}

/* HOME PAGE */
.home-hero {
  text-align: center;
  margin-bottom: 3rem;
}

.home-hero h1 {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: var(--text-primary);
}

.home-hero p {
  font-size: 1.125rem;
  color: var(--text-secondary);
  margin-bottom: 2rem;
}

.search-box {
  max-width: 700px;
  margin: 0 auto 3rem;
  position: relative;
}

.search-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  font-size: 1rem;
  background: var(--bg-primary);
  transition: all 0.2s;
}

.search-input:focus {
  outline: none;
  border-color: var(--color-blue);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
  font-size: 1.25rem;
}

.mode-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.mode-card {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 2rem;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  color: inherit;
  display: block;
}

.mode-card:hover {
  box-shadow: var(--shadow-lg);
  transform: translateY(-4px);
  border-color: transparent;
}

.mode-card.ask-card:hover {
  border-color: var(--color-blue);
}

.mode-card.act-card:hover {
  border-color: var(--color-green);
}

.mode-card.alert-card:hover {
  border-color: var(--color-yellow);
}

.mode-icon {
  width: 56px;
  height: 56px;
  margin: 0 auto 1rem;
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.75rem;
}

.mode-card.ask-card .mode-icon {
  background: var(--color-blue-light);
  color: var(--color-blue);
}

.mode-card.act-card .mode-icon {
  background: var(--color-green-light);
  color: var(--color-green);
}

.mode-card.alert-card .mode-icon {
  background: var(--color-yellow-light);
  color: var(--color-yellow);
}

.mode-card h3 {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.mode-card p {
  color: var(--text-secondary);
  font-size: 0.9375rem;
  line-height: 1.6;
}

.workflow-note {
  text-align: center;
  color: var(--text-muted);
  font-size: 0.9375rem;
}

/* ASK/ACT/ALERT PAGES */
.page-header {
  margin-bottom: 2rem;
}

.page-header h1 {
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.page-header p {
  font-size: 1.0625rem;
  color: var(--text-secondary);
}

.page-section {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 2rem;
  margin-bottom: 2rem;
}

.quick-questions {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
  margin-bottom: 3rem;
}

.quick-question {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 1.25rem;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.9375rem;
  color: var(--text-primary);
  text-align: left;
}

.quick-question:hover {
  border-color: var(--color-blue);
  box-shadow: var(--shadow-md);
}

.chat-area {
  background: var(--bg-primary);
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 2rem;
  min-height: 400px;
  margin-bottom: 1.5rem;
}

.input-bar {
  position: relative;
  margin-top: 2rem;
}

.input-field {
  width: 100%;
  padding: 1rem 6rem 1rem 3rem;
  border: 1px solid var(--border);
  border-radius: var(--radius-xl);
  font-size: 1rem;
  background: var(--bg-primary);
  transition: all 0.2s;
}

.input-field:focus {
  outline: none;
  border-color: var(--color-blue);
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.input-icon {
  position: absolute;
  left: 1rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
  font-size: 1.125rem;
}

.input-actions {
  position: absolute;
  right: 1rem;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  gap: 0.5rem;
}

.icon-btn {
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  font-size: 1.125rem;
  width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  transition: all 0.2s;
}

.icon-btn:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

.icon-btn.send-btn {
  background: var(--color-blue);
  color: white;
  border-radius: 50%;
}

.icon-btn.send-btn:hover {
  opacity: 0.9;
}

.input-hint {
  text-align: center;
  color: var(--text-muted);
  font-size: 0.875rem;
  margin-top: 1rem;
}

.empty-state {
  text-align: center;
  padding: 4rem 2rem;
  color: var(--text-secondary);
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: 700;
}

.section-subtitle {
  color: var(--text-secondary);
  font-size: 0.9375rem;
  margin-top: 0.25rem;
}

.collapsible-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  cursor: pointer;
  padding: 1rem 0;
  border-bottom: 1px solid var(--border);
}

.collapsible-header h3 {
  font-size: 1.125rem;
  font-weight: 600;
}

/* ALERT CARDS */
.alert-card {
  background: var(--bg-primary);
  border-left: 4px solid;
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  margin-bottom: 1rem;
  position: relative;
  box-shadow: var(--shadow-sm);
}

.alert-card.critical {
  border-left-color: var(--color-red);
  background: linear-gradient(90deg, rgba(239, 68, 68, 0.05) 0%, transparent 100%);
}

.alert-card.actionable {
  border-left-color: var(--color-yellow);
  background: linear-gradient(90deg, rgba(245, 158, 11, 0.05) 0%, transparent 100%);
}

.alert-card.informational {
  border-left-color: var(--color-blue);
  background: linear-gradient(90deg, rgba(59, 130, 246, 0.05) 0%, transparent 100%);
}

.alert-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 0.75rem;
}

.alert-title {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex: 1;
}

.alert-icon {
  font-size: 1.25rem;
}

.alert-title h4 {
  font-size: 1.0625rem;
  font-weight: 600;
  margin: 0;
}

.alert-priority {
  padding: 0.25rem 0.75rem;
  border-radius: var(--radius-md);
  font-size: 0.8125rem;
  font-weight: 600;
}

.alert-priority.critical {
  background: var(--color-red-light);
  color: var(--color-red);
}

.alert-priority.actionable {
  background: var(--color-yellow-light);
  color: var(--color-yellow);
}

.alert-priority.informational {
  background: var(--color-blue-light);
  color: var(--color-blue);
}

.alert-close {
  background: none;
  border: none;
  cursor: pointer;
  color: var(--text-muted);
  font-size: 1.25rem;
  width: 28px;
  height: 28px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
  transition: all 0.2s;
  flex-shrink: 0;
  margin-left: 0.5rem;
}

.alert-close:hover {
  background: var(--bg-secondary);
  color: var(--text-primary);
}

.alert-body {
  color: var(--text-secondary);
  font-size: 0.9375rem;
  line-height: 1.6;
  margin-bottom: 0.75rem;
}

.alert-meta {
  display: flex;
  gap: 1.5rem;
  color: var(--text-muted);
  font-size: 0.8125rem;
  margin-bottom: 1rem;
}

.alert-actions {
  display: flex;
  gap: 0.75rem;
}

.btn-action {
  padding: 0.5rem 1rem;
  border-radius: var(--radius-md);
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  border: 1px solid;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-take-action {
  background: var(--color-green);
  color: white;
  border-color: var(--color-green);
}

.btn-take-action:hover {
  opacity: 0.9;
}

.btn-investigate {
  background: transparent;
  color: var(--color-blue);
  border-color: var(--color-blue);
}

.btn-investigate:hover {
  background: var(--color-blue-light);
}

@media (max-width: 768px) {
  .mode-cards {
    grid-template-columns: 1fr;
  }
  
  .quick-questions {
    grid-template-columns: 1fr;
  }
  
  .home-hero h1 {
    font-size: 2rem;
  }
  
  .content-wrapper {
    padding: 2rem 1rem;
  }
}
__MODERN_CSS_END__
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Produce Optimization Agent</title>
  <link rel="stylesheet" href="/css/modern-style.css">
</head>
<body class="modern-layout">
  <!-- Sidebar -->
  <div class="sidebar">
    <div class="sidebar-logo">CA</div>
    <nav class="sidebar-nav">
      <a href="/home" class="sidebar-link <%= 'active' if request.path_info == '/home' %>" title="Home">🏠</a>
      <a href="/ask" class="sidebar-link <%= 'active' if request.path_info == '/ask' %>" title="Ask">💬</a>
      <a href="/act" class="sidebar-link <%= 'active' if request.path_info == '/act' %>" title="Act">⚡</a>
      <a href="/alert" class="sidebar-link <%= 'active' if request.path_info == '/alert' %>" title="Alert">🔔</a>
    </nav>
    <div class="sidebar-user">
      <img src="https://ui-avatars.com/api/?name=Carina&background=3B82F6&color=fff" alt="User">
    </div>
  </div>

  <!-- Main Content -->
  <div class="main-content">
    <div class="top-bar">
      <div>
        <%= yield :mode_badge %>
      </div>
      <button class="btn-publish">Publish your project</button>
    </div>
    
    <div class="content-wrapper">
      <%= yield %>
    </div>
  </div>
</body>
</html>
__MODERN_LAYOUT_END__
<% content_for :mode_badge do %>
  <!-- No mode badge on home -->
<% end %>

<div class="home-hero">
  <h1>Hey Carina</h1>
  <p>Ask questions, take actions, and manage alerts.</p>
  
  <div class="search-box">
    <span class="search-icon">🔍</span>
    <input type="text" class="search-input" placeholder="Ask a question or search..." />
  </div>
</div>

<div class="mode-cards">
  <a href="/ask" class="mode-card ask-card">
    <div class="mode-icon">💬</div>
    <h3>Ask</h3>
    <p>Query the system and get detailed insights</p>
  </a>
  
  <a href="/act" class="mode-card act-card">
    <div class="mode-icon">⚡</div>
    <h3>Act</h3>
    <p>Review and execute recommended actions</p>
  </a>
  
  <a href="/alert" class="mode-card alert-card">
    <div class="mode-icon">🔔</div>
    <h3>Alert</h3>
    <p>Monitor outcomes and receive notifications</p>
  </a>
</div>

<p class="workflow-note">Select a mode to begin your workflow</p>
__HOME_PAGE_END__
<% content_for :mode_badge do %>
  <span class="mode-badge ask-mode">Ask Mode</span>
<% end %>

<div class="page-header">
  <h1>Ask</h1>
</div>

<div class="page-section">
  <h2 style="font-size: 1.5rem; margin-bottom: 1rem; text-align: center;">Hi Carina, what would you like to know?</h2>
  <p style="text-align: center; color: var(--text-secondary); margin-bottom: 2rem;">Ask a question to get detailed, actionable insights for your stores</p>
  
  <div class="quick-questions">
    <div class="quick-question" onclick="askQuestion('Which stores need additional staff this weekend?')">
      Which stores need additional staff this weekend?
    </div>
    <div class="quick-question" onclick="askQuestion('How can I get restock sooner? What are my options?')">
      How can I get restock sooner? What are my options?
    </div>
    <div class="quick-question" onclick="askQuestion('Staff allocation optimization recommendations')">
      Staff allocation optimization recommendations
    </div>
  </div>
</div>

<div class="chat-area" id="chat-area">
  <!-- Chat messages will appear here -->
</div>

<div class="input-bar">
  <span class="input-icon">💬</span>
  <input type="text" id="ask-input" class="input-field" placeholder="Ask here ..." />
  <div class="input-actions">
    <button class="icon-btn" onclick="startVoiceInput()">🎤</button>
    <button class="icon-btn send-btn" onclick="sendQuestion()">➜</button>
  </div>
</div>

<p class="input-hint">Press Enter to send or use voice input</p>

<script>
function askQuestion(question) {
  document.getElementById('ask-input').value = question;
  sendQuestion();
}

function sendQuestion() {
  const input = document.getElementById('ask-input');
  const question = input.value.trim();
  if (!question) return;
  
  const chatArea = document.getElementById('chat-area');
  chatArea.innerHTML += `
    <div style="margin-bottom: 1rem; padding: 1rem; background: var(--bg-secondary); border-radius: var(--radius-lg);">
      <strong>You:</strong> ${question}
    </div>
    <div style="margin-bottom: 1rem; padding: 1rem; background: var(--color-blue-light); border-radius: var(--radius-lg);">
      <strong>Assistant:</strong> I'm analyzing your question about "${question}". This feature will connect to your backend API.
    </div>
  `;
  
  input.value = '';
  chatArea.scrollTop = chatArea.scrollHeight;
}

function startVoiceInput() {
  alert('Voice input feature coming soon!');
}

document.getElementById('ask-input').addEventListener('keypress', function(e) {
  if (e.key === 'Enter') {
    sendQuestion();
  }
});
</script>
__ASK_PAGE_END__
<% content_for :mode_badge do %>
  <span class="mode-badge act-mode">Act Mode</span>
<% end %>

<div class="page-section">
  <div class="section-header">
    <div>
      <h1 class="section-title">Review & Execute Actions</h1>
      <p class="section-subtitle">Confirm and execute recommended interventions</p>
    </div>
  </div>
</div>

<div class="page-section">
  <div class="collapsible-header" onclick="toggleSection('completed')">
    <h3>Completed Actions (3)</h3>
    <span id="completed-icon">▼</span>
  </div>
  <div id="completed-section" style="display: none; margin-top: 1rem;">
    <!-- Completed actions would go here -->
  </div>
</div>

<div class="empty-state">
  <p style="font-size: 1.125rem; margin-bottom: 0.5rem;">No pending actions. All actions completed.</p>
  <p style="font-size: 0.9375rem;">Check back later for new recommendations.</p>
</div>

<div class="input-bar">
  <span class="input-icon">🔍</span>
  <input type="text" class="input-field" placeholder="Search actions or type command..." />
  <div class="input-actions">
    <button class="icon-btn" onclick="startVoiceInput()">🎤</button>
    <button class="icon-btn send-btn">➜</button>
  </div>
</div>

<p class="input-hint">Press Enter to search, or use voice input</p>

<script>
function toggleSection(sectionId) {
  const section = document.getElementById(sectionId + '-section');
  const icon = document.getElementById(sectionId + '-icon');
  if (section.style.display === 'none') {
    section.style.display = 'block';
    icon.textContent = '▲';
  } else {
    section.style.display = 'none';
    icon.textContent = '▼';
  }
}

function startVoiceInput() {
  alert('Voice input feature coming soon!');
}
</script>
__ACT_PAGE_END__
<% content_for :mode_badge do %>
  <span class="mode-badge alert-mode">Alert Mode</span>
<% end %>

<div class="page-section">
  <div class="section-header">
    <div>
      <h1 class="section-title">Monitor & Respond</h1>
      <p class="section-subtitle">Stay informed about critical updates and take action on what matters</p>
    </div>
  </div>
</div>

<div style="margin: 2rem 0;">
  <p style="color: var(--text-muted); text-align: center;">...</p>
</div>

<!-- Critical Alert -->
<div class="alert-card critical">
  <div class="alert-header">
    <div class="alert-title">
      <span class="alert-icon">⛔</span>
      <h4>Critical Priority Task Blocker</h4>
    </div>
    <span class="alert-priority critical">critical</span>
    <button class="alert-close" onclick="dismissAlert(this)">×</button>
  </div>
  <div class="alert-body">
    Q4 Planning Review is blocked due to resource constraints from 2 dependent teams. Potential 5-day delay if not resolved within 48 hours.
  </div>
  <div class="alert-meta">
    <span>Task Monitor</span>
    <span>•</span>
    <span>Just now</span>
  </div>
  <div class="alert-actions">
    <button class="btn-action btn-take-action">
      ➜ Take Action
    </button>
    <button class="btn-action btn-investigate">
      🔍 Investigate
    </button>
  </div>
</div>

<!-- Actionable Alert -->
<div class="alert-card actionable">
  <div class="alert-header">
    <div class="alert-title">
      <span class="alert-icon">⚠️</span>
      <h4>Customer Feedback Analysis Behind Schedule</h4>
    </div>
    <span class="alert-priority actionable">Actionable</span>
    <button class="alert-close" onclick="dismissAlert(this)">×</button>
  </div>
  <div class="alert-body">
    Analysis task is tracking 15% behind target pace. Data team dependency may cause further delays. Recommend check-in meeting.
  </div>
  <div class="alert-meta">
    <span>Project Tracking</span>
    <span>•</span>
    <span>15 minutes ago</span>
  </div>
  <div class="alert-actions">
    <button class="btn-action btn-take-action">
      ➜ Take Action
    </button>
    <button class="btn-action btn-investigate">
      🔍 Investigate
    </button>
  </div>
</div>

<!-- Informational Alert -->
<div class="alert-card informational">
  <div class="alert-header">
    <div class="alert-title">
      <span class="alert-icon">ℹ️</span>
      <h4>System Integration Testing On Track</h4>
    </div>
    <span class="alert-priority informational">informational</span>
    <button class="alert-close" onclick="dismissAlert(this)">×</button>
  </div>
  <div class="alert-body">
    Testing proceeding as planned with 30% completion. No blockers detected. Team documented 12 test cases for knowledge base.
  </div>
  <div class="alert-meta">
    <span>Quality Assurance</span>
    <span>•</span>
    <span>1 hour ago</span>
  </div>
  <div class="alert-actions">
    <button class="btn-action btn-investigate">
      🔍 Investigate
    </button>
  </div>
</div>

<div class="input-bar">
  <span class="input-icon">🔍</span>
  <input type="text" class="input-field" placeholder="Search alerts or type command..." />
  <div class="input-actions">
    <button class="icon-btn" onclick="startVoiceInput()">🎤</button>
    <button class="icon-btn send-btn">➜</button>
  </div>
</div>

<p class="input-hint">Press Enter to search, or use voice input</p>

<script>
function dismissAlert(button) {
  const alertCard = button.closest('.alert-card');
  alertCard.style.opacity = '0';
  alertCard.style.transform = 'translateX(100%)';
  alertCard.style.transition = 'all 0.3s ease';
  setTimeout(() => {
    alertCard.remove();
  }, 300);
}

function startVoiceInput() {
  alert('Voice input feature coming soon!');
}
</script>
