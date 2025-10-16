# Tool implementations for: Recent Incidents
# Generated: 2025-10-16 15:10:09 +1100

def get_recent_incidents(params = {})
  # Extract and validate parameters
  limit = params[:limit] || 10
  days = params[:days] || 7
  severity = params[:severity] # optional filter: 'critical', 'high', 'medium', 'low'
  store_id = params[:store_id] # optional filter by specific store
  
  # Validate limit parameter
  return { error: "Limit must be between 1 and 100" } if limit < 1 || limit > 100
  
  # Validate days parameter
  return { error: "Days must be between 1 and 30" } if days < 1 || days > 30
  
  begin
    # Mock incident data for grocery retail
    all_incidents = [
      {
        incident_id: "INC-2024-001",
        title: "Refrigeration System Failure - Dairy Section",
        severity: "critical",
        status: "resolved",
        store_id: "STR-001",
        store_name: "Downtown Fresh Market",
        category: "equipment",
        created_at: "2024-01-15T08:30:00Z",
        resolved_at: "2024-01-15T10:45:00Z",
        affected_products: ["dairy", "frozen_foods"],
        estimated_loss: 12500.00
      },
      {
        incident_id: "INC-2024-002",
        title: "Point of Sale System Outage",
        severity: "high",
        status: "in_progress",
        store_id: "STR-003",
        store_name: "Westside Grocery Plus",
        category: "technology",
        created_at: "2024-01-14T14:22:00Z",
        resolved_at: nil,
        affected_products: [],
        estimated_loss: 5200.00
      },
      {
        incident_id: "INC-2024-003",
        title: "Produce Delivery Delayed - Weather",
        severity: "medium",
        status: "monitoring",
        store_id: "STR-002",
        store_name: "Northgate Market",
        category: "supply_chain",
        created_at: "2024-01-14T06:15:00Z",
        resolved_at: nil,
        affected_products: ["fresh_produce", "organic_vegetables"],
        estimated_loss: 1800.00
      },
      {
        incident_id: "INC-2024-004",
        title: "Customer Slip and Fall - Wet Floor",
        severity: "high",
        status: "under_review",
        store_id: "STR-001",
        store_name: "Downtown Fresh Market",
        category: "safety",
        created_at: "2024-01-13T16:45:00Z",
        resolved_at: nil,
        affected_products: [],
        estimated_loss: 0.00
      },
      {
        incident_id: "INC-2024-005",
        title: "Inventory Discrepancy - Missing Stock",
        severity: "medium",
        status: "investigating",
        store_id: "STR-004",
        store_name: "Eastside Super Center",
        category: "inventory",
        created_at: "2024-01-13T11:30:00Z",
        resolved_at: nil,
        affected_products: ["electronics", "household_items"],
        estimated_loss: 3400.00
      },
      {
        incident_id: "INC-2024-006",
        title: "Fire Alarm System Malfunction",
        severity: "low",
        status: "resolved",
        store_id: "STR-002",
        store_name: "Northgate Market",
        category: "safety",
        created_at: "2024-01-12T09:15:00Z",
        resolved_at: "2024-01-12T11:20:00Z",
        affected_products: [],
        estimated_loss: 0.00
      }
    ]
    
    # Filter by severity if specified
    filtered_incidents = severity ? all_incidents.select { |i| i[:severity] == severity } : all_incidents
    
    # Filter by store_id if specified
    filtered_incidents = store_id ? filtered_incidents.select { |i| i[:store_id] == store_id } : filtered_incidents
    
    # Apply limit
    limited_incidents = filtered_incidents.first(limit)
    
    {
      success: true,
      incidents: limited_incidents,
      total_count: filtered_incidents.length,
      filters_applied: {
        limit: limit,
        days: days,
        severity: severity,
        store_id: store_id
      },
      summary: {
        critical: filtered_incidents.count { |i| i[:severity] == "critical" },
        high: filtered_incidents.count { |i| i[:severity] == "high" },
        medium: filtered_incidents.count { |i| i[:severity] == "medium" },
        low: filtered_incidents.count { |i| i[:severity] == "low" }
      }
    }
    
  rescue => e
    { error: "Failed to retrieve incidents: #{e.message}" }
  end
end

def get_incident_details(params = {})
  # Extract and validate parameters
  incident_id = params[:incident_id]
  
  # Validate required parameter
  return { error: "incident_id is required" } if incident_id.nil? || incident_id.empty?
  
  begin
    # Mock detailed incident data
    incident_details = {
      "INC-2024-001" => {
        incident_id: "INC-2024-001",
        title: "Refrigeration System Failure - Dairy Section",
        description: "Main refrigeration unit in dairy section experienced compressor failure, causing temperature to rise above safe storage levels.",
        severity: "critical",
        status: "resolved",
        priority: "P1",
        store_id: "STR-001",
        store_name: "Downtown Fresh Market",
        store_address: "123 Main St, Downtown",
        category: "equipment",
        subcategory: "refrigeration",
        created_at: "2024-01-15T08:30:00Z",
        updated_at: "2024-01-15T10:45:00Z",
        resolved_at: "2024-01-15T10:45:00Z",
        reported_by: "John Manager",
        assigned_to: "Mike Technician",
        affected_areas: ["dairy_section", "frozen_foods_aisle_3"],
        affected_products: ["milk", "yogurt", "cheese", "frozen_vegetables"],
        customer_impact: "High - products unavailable for purchase",
        estimated_loss: 12500.00,
        actual_loss: 11200.00,
        resolution: "Replaced compressor unit and restored normal operation",
        timeline: [
          { timestamp: "2024-01-15T08:30:00Z", event: "Incident reported by store manager", user: "John Manager" },
          { timestamp: "2024-01-15T08:45:00Z", event: "Technician dispatched", user: "System" },
          { timestamp: "2024-01-15T09:15:00Z", event: "On-site assessment completed", user: "Mike Technician" },
          { timestamp: "2024-01-15T10:45:00Z", event: "Repair completed, system operational", user: "Mike Technician" }
        ],
        root_cause: "Compressor bearing failure due to scheduled maintenance delay",
        preventive_actions: ["Implement proactive maintenance schedule", "Install temperature monitoring alerts"]
      },
      "INC-2024-002" => {
        incident_id: "INC-2024-002",
        title: "Point of Sale System Outage",
        description: "Complete POS system failure affecting all checkout lanes, customers unable to complete purchases.",
        severity: "high",
        status: "in_progress",
        priority: "P1",
        store_id: "STR-003",
        store_name: "Westside Grocery Plus",
        store_address: "456 West Ave, Westside",
        category: "technology",
        subcategory: "pos_systems",
        created_at: "2024-01-14T14:22:00Z",
        updated_at: "2024-01-14T16:30:00Z",
        resolved_at: nil,
        reported_by: "Sarah Supervisor",
        assigned_to: "IT Support Team",
        affected_areas: ["all_checkout_lanes", "customer_service_desk"],
        affected_products: [],
        customer_impact: "Critical - no transactions possible",
        estimated_loss: 5200.00,
        actual_loss: nil,
        resolution: "In progress - working with vendor support",
        timeline: [
          { timestamp: "2024-01-14T14:22:00Z", event: "System outage detected", user: "Sarah Supervisor" },
          { timestamp: "2024-01-14T14:30:00Z", event: "IT support engaged", user: "System" },
          { timestamp: "2024-01-14T15:15:00Z", event: "Vendor support contacted", user: "IT Support" },
          { timestamp: "2024-01-14T16:30:00Z", event: "Temporary manual processing implemented", user: "Sarah Supervisor" }
        ],
        root_cause: "Under investigation - suspected network connectivity issue",
        preventive_actions: ["To be determined pending resolution"]
      }
    }
    
    incident = incident_details[incident_id]
    
    if incident
      { success: true, incident: incident }
    else
      { error: "Incident not found with ID: #{incident_id}" }
    end
    
  rescue => e
    { error: "Failed to retrieve incident details: #{e.message}" }
  end
end

def get_incident_metrics(params = {})
  # Extract and validate parameters
  period = params[:period] || "week" # week, month, quarter
  store_id = params[:store_id] # optional filter by store
  
  # Validate period parameter
  valid_periods = ["week", "month", "quarter", "year"]
  return { error: "Period must be one of: #{valid_periods.join(', ')}" } unless valid_periods.include?(period)
  
  begin
    # Mock metrics data for grocery retail incidents
    base_metrics = {
      period: period,
      date_range: {
        start: "2024-01-01T00:00:00Z",
        end: "2024-01-15T23:59:59Z"
      },
      total_incidents: 23,
      incidents_by_severity: {
        critical: 3,
        high: 7,
        medium: 9,
        low: 4
      },
      incidents_by_category: {
        equipment: 8,
        technology: 5,
        supply_chain: 4,
        safety: 3,
        inventory: 2,
        other: 1
      },
      incidents_by_status: {
        resolved: 15,
        in_progress: 4,
        investigating: 2,
        monitoring: 1,
        under_review: 1
      },
      resolution_times: {
        average_hours: 4.2,
        median_hours: 2.8,
        critical_average_hours: 2.1,
        high_average_hours: 6.3,
        medium_average_hours: 12.5,
        low_average_hours: 8.7
      },
      financial_impact: {
        total_estimated_loss: 45600.00,
        total_actual_loss: 38200.00,
        average_loss_per_incident: 1980.87,
        loss_by_category: {
          equipment: 18500.00,
          technology: 12300.00,
          supply_chain: 5200.00,
          inventory: 2200.00,
          safety: 0.00,
          other: 0.00
        }
      },
      trends: {
        incidents_vs_previous_period: 15,
        percentage_change: 34.8,
        most_common_category: "equipment",
        most_affected_store: "STR-001",
        busiest_day: "Monday",
        peak_hour: "14:00"
      },
      store_breakdown: [
        { store_id: "STR-001", store_name: "Downtown Fresh Market", incident_count: 6, total_loss: 15700.00 },
        { store_id: "STR-002", store_name: "Northgate Market", incident_count: 4, total_loss: 6800.00 },
        { store_id: "STR-003", store_name: "Westside Grocery Plus", incident_count: 7, total_loss: 8900.00 },
        { store_id: "STR-004", store_name: "Eastside Super Center", incident_count: 6, total_loss: 6800.00 }
      ]
    }
    
    # Filter by store if specified
    if store_id
      store_data = base_metrics[:store_breakdown].find { |s| s[:store_id] == store_id }
      return { error: "Store not found with ID: #{store_id}" } unless store_data
      
      # Adjust metrics for single store
      base_metrics[:total_incidents] = store_data[:incident_count]
      base_metrics[:financial_impact][:total_actual_loss] = store_data[:total_loss]
      base_metrics[:store_breakdown] = [store_data]
      base_metrics[:filter] = { store_id: store_id, store_name: store_data[:store_name] }
    end
    
    {
      success: true,
      metrics: base_metrics,
      generated_at: Time.now.strftime("%Y-%m-%dT%H:%M:%SZ")
    }
    
  rescue => e
    { error: "Failed to retrieve incident metrics: #{e.message}" }
  end
end