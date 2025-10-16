# CARINA Critical Systems Tools
# Rationalized from: critical-systems-status_tools.rb
# Category: Systems
# Description: Tools for monitoring critical system components

module CARINA
  module Systems
    class CriticalSystems
      
      # Original implementation refactored into class methods
                def get_system_health_status(params = {})
            # Extract and validate parameters
            system_type = params[:system_type] || 'all'
            time_window = params[:time_window] || '1h'
            
            # Validate system type
            valid_systems = ['all', 'pos', 'inventory', 'database', 'network', 'payment']
            unless valid_systems.include?(system_type)
              return { error: "Invalid system_type. Must be one of: #{valid_systems.join(', ')}" }
            end
            
            # Validate time window
            valid_windows = ['15m', '1h', '4h', '24h']
            unless valid_windows.include?(time_window)
              return { error: "Invalid time_window. Must be one of: #{valid_windows.join(', ')}" }
            end
            
            begin
              # Mock system health data
              systems = {
                'pos' => {
                  name: 'Point of Sale System',
                  status: 'healthy',
                  uptime_percentage: 99.7,
                  response_time_ms: 145,
                  active_terminals: 47,
                  failed_terminals: 1,
                  last_check: Time.now - 120
                },
                'inventory' => {
                  name: 'Inventory Management',
                  status: 'warning',
                  uptime_percentage: 98.2,
                  response_time_ms: 890,
                  sync_status: 'delayed',
                  last_sync: Time.now - 1800,
                  pending_updates: 23
                },
                'database' => {
                  name: 'Primary Database Cluster',
                  status: 'healthy',
                  uptime_percentage: 99.9,
                  response_time_ms: 45,
                  active_connections: 234,
                  max_connections: 500,
                  cpu_usage: 67.3,
                  memory_usage: 78.1
                },
                'network' => {
                  name: 'Network Infrastructure',
                  status: 'critical',
                  uptime_percentage: 96.8,
                  latency_ms: 234,
                  packet_loss: 2.1,
                  bandwidth_usage: 87.4,
                  affected_stores: ['Store-105', 'Store-112']
                },
                'payment' => {
                  name: 'Payment Processing',
                  status: 'healthy',
                  uptime_percentage: 99.4,
                  success_rate: 98.7,
                  failed_transactions: 12,
                  processor_status: {
                    'visa' => 'healthy',
                    'mastercard' => 'healthy',
                    'amex' => 'degraded'
                  }
                }
              }
              
              # Filter by system type if specified
              result_systems = system_type == 'all' ? systems : { system_type => systems[system_type] }
              
              {
                timestamp: Time.now,
                time_window: time_window,
                overall_status: determine_overall_status(result_systems.values),
                systems: result_systems,
                summary: {
                  total_systems: result_systems.count,
                  healthy: result_systems.values.count { |s| s[:status] == 'healthy' },
                  warning: result_systems.values.count { |s| s[:status] == 'warning' },
                  critical: result_systems.values.count { |s| s[:status] == 'critical' }
                }
              }
            rescue => e
              { error: "Failed to retrieve system health status: #{e.message}" }
            end
          end
          

          def get_active_alerts(params = {})
            # Extract and validate parameters
            severity = params[:severity] || 'all'
            limit = params[:limit] || 50
            category = params[:category] || 'all'
            
            # Validate severity
            valid_severities = ['all', 'critical', 'high', 'medium', 'low']
            unless valid_severities.include?(severity)
              return { error: "Invalid severity. Must be one of: #{valid_severities.join(', ')}" }
            end
            
            # Validate limit
            limit = limit.to_i
            if limit <= 0 || limit > 1000
              return { error: "Invalid limit. Must be between 1 and 1000" }
            end
            
            begin
              # Mock active alerts data
              all_alerts = [
                {
                  id: 'ALT-2024-001',
                  title: 'Network connectivity issues in Store 105',
                  severity: 'critical',
                  category: 'network',
                  status: 'active',
                  created_at: Time.now - 3600,
                  affected_systems: ['pos', 'inventory'],
                  store_locations: ['Store-105'],
                  description: 'Multiple POS terminals offline due to network connectivity issues',
                  estimated_impact: 'High - Customer transactions affected'
                },
                {
                  id: 'ALT-2024-002',
                  title: 'Payment processor latency spike',
                  severity: 'high',
                  category: 'payment',
                  status: 'investigating',
                  created_at: Time.now - 1800,
                  affected_systems: ['payment'],
                  store_locations: ['All'],
                  description: 'American Express transactions experiencing 5-10 second delays',
                  estimated_impact: 'Medium - Slower checkout times'
                },
                {
                  id: 'ALT-2024-003',
                  title: 'Inventory sync delay',
                  severity: 'medium',
                  category: 'inventory',
                  status: 'acknowledged',
                  created_at: Time.now - 7200,
                  affected_systems: ['inventory'],
                  store_locations: ['Store-112', 'Store-118'],
                  description: 'Product availability updates delayed by 30+ minutes',
                  estimated_impact: 'Low - Potential stock discrepancies'
                },
                {
                  id: 'ALT-2024-004',
                  title: 'Database connection pool near capacity',
                  severity: 'medium',
                  category: 'database',
                  status: 'monitoring',
                  created_at: Time.now - 900,
                  affected_systems: ['database'],
                  store_locations: ['All'],
                  description: 'Database connections at 85% capacity during peak hours',
                  estimated_impact: 'Low - Performance degradation possible'
                },
                {
                  id: 'ALT-2024-005',
                  title: 'POS terminal hardware failure',
                  severity: 'low',
                  category: 'hardware',
                  status: 'scheduled',
                  created_at: Time.now - 14400,
                  affected_systems: ['pos'],
                  store_locations: ['Store-092'],
                  description: 'Terminal #7 receipt printer malfunction',
                  estimated_impact: 'Very Low - Single terminal affected'
                }
              ]
              
              # Filter alerts based on parameters
              filtered_alerts = all_alerts
              
              if severity != 'all'
                filtered_alerts = filtered_alerts.select { |alert| alert[:severity] == severity }
              end
              
              if category != 'all'
                filtered_alerts = filtered_alerts.select { |alert| alert[:category] == category }
              end
              
              # Limit results
              filtered_alerts = filtered_alerts.first(limit)
              
              {
                timestamp: Time.now,
                total_alerts: filtered_alerts.count,
                filters: { severity: severity, category: category, limit: limit },
                alerts: filtered_alerts,
                summary_by_severity: {
                  critical: all_alerts.count { |a| a[:severity] == 'critical' },
                  high: all_alerts.count { |a| a[:severity] == 'high' },
                  medium: all_alerts.count { |a| a[:severity] == 'medium' },
                  low: all_alerts.count { |a| a[:severity] == 'low' }
                }
              }
            rescue => e
              { error: "Failed to retrieve active alerts: #{e.message}" }
            end
          end
          

          def check_service_availability(params = {})
            # Extract and validate parameters
            service_name = params[:service_name]
            store_id = params[:store_id] || 'all'
            
            # Validate required parameters
            if service_name.nil? || service_name.empty?
              return { error: "service_name parameter is required" }
            end
            
            # Validate service name
            valid_services = ['pos', 'inventory', 'payment', 'customer_portal', 'loyalty', 'analytics', 'security']
            unless valid_services.include?(service_name)
              return { error: "Invalid service_name. Must be one of: #{valid_services.join(', ')}" }
            end
            
            begin
              # Mock service availability data by store
              store_availability = {
                'Store-101' => {
                  pos: { available: true, response_time: 120, last_check: Time.now - 60 },
                  inventory: { available: true, response_time: 340, last_check: Time.now - 180 },
                  payment: { available: true, response_time: 89, last_check: Time.now - 45 },
                  customer_portal: { available: true, response_time: 567, last_check: Time.now - 90 },
                  loyalty: { available: true, response_time: 234, last_check: Time.now - 120 },
                  analytics: { available: true, response_time: 1230, last_check: Time.now - 300 },
                  security: { available: true, response_time: 78, last_check: Time.now - 30 }
                },
                'Store-105' => {
                  pos: { available: false, response_time: nil, last_check: Time.now - 60, error: 'Network timeout' },
                  inventory: { available: false, response_time: nil, last_check: Time.now - 180, error: 'Connection refused' },
                  payment: { available: true, response_time: 156, last_check: Time.now - 45 },
                  customer_portal: { available: true, response_time: 890, last_check: Time.now - 90 },
                  loyalty: { available: true, response_time: 445, last_check: Time.now - 120 },
                  analytics: { available: true, response_time: 2100, last_check: Time.now - 300 },
                  security: { available: true, response_time: 134, last_check: Time.now - 30 }
                },
                'Store-112' => {
                  pos: { available: true, response_time: 98, last_check: Time.now - 60 },
                  inventory: { available: true, response_time: 2100, last_check: Time.now - 180 },
                  payment: { available: true, response_time: 234, last_check: Time.now - 45 },
                  customer_portal: { available: true, response_time: 456, last_check: Time.now - 90 },
                  loyalty: { available: false, response_time: nil, last_check: Time.now - 120, error: 'Service unavailable' },
                  analytics: { available: true, response_time: 890, last_check: Time.now - 300 },
                  security: { available: true, response_time: 67, last_check: Time.now - 30 }
                }
              }
              
              service_sym = service_name.to_sym
              
              if store_id == 'all'
                # Return availability for all stores
                availability_data = {}
                store_availability.each do |store, services|
                  availability_data[store] = services[service_sym]
                end
                
                # Calculate summary statistics
                total_stores = availability_data.count
                available_stores = availability_data.values.count { |service| service[:available] }
                avg_response_time = calculate_average_response_time(availability_data.values)
                
                {
                  timestamp: Time.now,
                  service_name: service_name,
                  store_scope: 'all',
                  availability_by_store: availability_data,
                  summary: {
                    total_stores: total_stores,
                    available_stores: available_stores,
                    unavailable_stores: total_stores - available_stores,
                    availability_percentage: ((available_stores.to_f / total_stores) * 100).round(1),
                    average_response_time_ms: avg_response_time
                  }
                }
              else
                # Return availability for specific store
                unless store_availability.key?(store_id)
                  return { error: "Store ID '#{store_id}' not found" }
                end
                
                service_data = store_availability[store_id][service_sym]
                
                {
                  timestamp: Time.now,
                  service_name: service_name,
                  store_id: store_id,
                  availability: service_data
                }
              end
            rescue => e
              { error: "Failed to check service availability: #{e.message}" }
            end
          end
          

          def get_infrastructure_summary(params = {})
            # Extract and validate parameters
            include_metrics = params[:include_metrics] || true
            time_range = params[:time_range] || '1h'
            
            # Validate time range
            valid_ranges = ['15m', '1h', '4h', '24h', '7d']
            unless valid_ranges.include?(time_range)
              return { error: "Invalid time_range. Must be one of: #{valid_ranges.join(', ')}" }
            end
            
            begin
              # Mock infrastructure summary data
              summary = {
                timestamp: Time.now,
                time_range: time_range,
                overall_status: 'degraded',
                infrastructure_components: {
                  compute: {
                    status: 'healthy',
                    total_servers: 24,
                    active_servers: 23,
                    failed_servers: 1,
                    cpu_utilization: 68.4,
                    memory_utilization: 74.2,
                    disk_utilization: 45.8
                  },
                  storage: {
                    status: 'healthy',
                    total_capacity_tb: 50,
                    used_capacity_tb: 32.4,
                    available_capacity_tb: 17.6,
                    utilization_percentage: 64.8,
                    io_performance: 'optimal',
                    backup_status: 'completed'
                  },
                  network: {
                    status: 'warning',
                    total_bandwidth_gbps: 10,
                    current_utilization_gbps: 8.7,
                    utilization_percentage: 87.0,
                    latency_ms: 15.6,
                    packet_loss_percentage: 0.12,
                    affected_locations: 2
                  },
                  security: {
                    status: 'healthy',
                    firewall_status: 'active',
                    intrusion_detection: 'monitoring',
                    ssl_certificates: {
                      total: 15,
                      expiring_soon: 2,
                      expired: 0
                    },
                    security_incidents: 0
                  }
                },
                store_connectivity: {
                  total_stores: 125,
                  connected_stores: 122,
                  disconnected_stores: 3,
                  stores_with_issues: ['Store-105', 'Store-112', 'Store-134'],
                  average_latency_ms: 45.6,
                  connection_quality: 'good'
                },
                critical_services: {
                  payment_gateway: {
                    status: 'healthy',
                    uptime_percentage: 99.7,
                    transactions_per_minute: 1247,
                    error_rate: 0.3
                  },
                  database_cluster: {
                    status: 'healthy',
                    primary_db: 'active',
                    replica_count: 3,
                    replication_lag_ms: 12,
                    connection_pool_usage: 67
                  },
                  load_balancers: {
                    status: 'healthy',
                    active_instances: 4,
                    traffic_distribution: 'balanced',
                    health_check_failures: 0
                  },
                  content_delivery: {
                    status: 'healthy',
                    cache_hit_ratio: 94.2,
                    edge_locations: 12,
                    bandwidth_savings: '78
      
    end
  end
end
