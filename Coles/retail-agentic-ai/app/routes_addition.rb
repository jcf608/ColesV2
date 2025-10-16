# Add to app/app.rb

require_relative 'services/mode_router'
require_relative 'services/action_executor'
require_relative 'services/alert_monitor'

# Ask Mode Endpoint
post '/api/ask' do
  content_type :json
  
  message = params[:message]
  
  # Route through mode orchestrator
  mode = ModeRouter.route(message)
  
  # Process through Ask mode handler
  # Call MCP tools as needed
  # Return conversational response
  
  {
    success: true,
    mode: mode,
    response: "This is a response from Ask mode",
    tool_calls: []
  }.to_json
end

# Get Actions
get '/api/actions' do
  content_type :json
  
  {
    pending: [],
    completed: []
  }.to_json
end

# Execute Action
post '/api/actions/:id/execute' do
  content_type :json
  
  action_id = params[:id]
  approval_token = request.env['HTTP_AUTHORIZATION']
  
  result = ActionExecutor.execute(action_id, approval_token)
  
  result.to_json
end

# Get Alerts
get '/api/alerts' do
  content_type :json
  
  filters = {
    priority: params[:priority],
    time_range_hours: params[:time_range_hours]&.to_i || 24
  }
  
  alerts = AlertMonitor.get_active_alerts(filters)
  
  { alerts: alerts }.to_json
end

# Create Alert
post '/api/alerts' do
  content_type :json
  
  data = JSON.parse(request.body.read)
  
  alert = AlertMonitor.create_alert(
    title: data['title'],
    description: data['description'],
    priority: data['priority'],
    source: data['source'],
    action_items: data['action_items'] || []
  )
  
  { alert: alert }.to_json
end

# Dismiss Alert
post '/api/alerts/:id/dismiss' do
  content_type :json
  
  alert_id = params[:id]
  data = JSON.parse(request.body.read)
  
  result = AlertMonitor.dismiss_alert(alert_id, data['resolution_notes'])
  
  result.to_json
end
