#!/usr/bin/env ruby

# CARINA Tool Rationalization Script
# This script maps the current tool files to their new rationalized structure

TOOL_MAPPING = {
  # Retail Operations
  'competitor-pricing_tools.rb' => 'retail/competitor_pricing.rb',
  'expiring-soon_tools.rb' => 'retail/expiring_products.rb',
  'items-at-risk_tools.rb' => 'retail/inventory_risk.rb',
  'restock-options_tools.rb' => 'retail/restock_management.rb',
  'policy-check_tools.rb' => 'retail/policy_compliance.rb',
  
  # Operations Management
  'staff-allocation_tools.rb' => 'operations/staff_allocation.rb',
  'impact-of-staff-shortfall_tools.rb' => 'operations/staff_shortfall_analysis.rb',
  'capacity-planning_tools.rb' => 'operations/capacity_planning.rb',
  
  # System Management
  'backup-status_tools.rb' => 'systems/backup_status.rb',
  'system-health_tools.rb' => 'systems/system_health.rb',
  'server-outage-impact_tools.rb' => 'systems/server_outage_analysis.rb',
  'critical-systems-status_tools.rb' => 'systems/critical_systems.rb',
  
  # Security
  'security-alerts_tools.rb' => 'security/security_alerts.rb',
  
  # Incident Management  
  'incident-summary_tools.rb' => 'incidents/incident_management.rb',
  'change-calendar_tools.rb' => 'incidents/change_calendar.rb',
  
  # External Services
  'weather-impact-analysis_tools.rb' => 'external/weather_analysis.rb'
}

CONFIG_MAPPING = {
  # Retail Operations
  'competitor-pricing_tools.json' => 'retail/competitor_pricing.json',
  'expiring-soon_tools.json' => 'retail/expiring_products.json',
  'items-at-risk_tools.json' => 'retail/inventory_risk.json',
  'restock-options_tools.json' => 'retail/restock_management.json',
  'policy-check_tools.json' => 'retail/policy_compliance.json',
  
  # Operations Management
  'staff-allocation_tools.json' => 'operations/staff_allocation.json',
  'impact-of-staff-shortfall_tools.json' => 'operations/staff_shortfall_analysis.json',
  'capacity-planning_tools.json' => 'operations/capacity_planning.json',
  
  # System Management
  'backup-status_tools.json' => 'systems/backup_status.json',
  'system-health_tools.json' => 'systems/system_health.json',
  'server-outage-impact_tools.json' => 'systems/server_outage_analysis.json',
  'critical-systems-status_tools.json' => 'systems/critical_systems.json',
  
  # Security
  'security-alerts_tools.json' => 'security/security_alerts.json',
  
  # Incident Management  
  'incident-summary_tools.json' => 'incidents/incident_management.json',
  'change-calendar_tools.json' => 'incidents/change_calendar.json',
  
  # External Services
  'weather-impact-analysis.json' => 'external/weather_analysis.json',
  'impact-of-staff-shortfall.json' => 'operations/staff_shortfall_analysis.json'
}

puts "CARINA Tool Rationalization Mapping:"
puts "=" * 50

puts "\nTool Files (Ruby):"
TOOL_MAPPING.each do |old_name, new_path|
  puts "  #{old_name} -> #{new_path}"
end

puts "\nConfig Files (JSON):"
CONFIG_MAPPING.each do |old_name, new_path|
  puts "  #{old_name} -> #{new_path}"
end

puts "\nDuplicates to Remove:"
puts "  /app/tools/impact-of-staff-shortfall_tools.rb (use /tools/ version)"
puts "  /app/tools/server-outage-impact_tools.rb (use /tools/ version)"
puts "  /app/config/tools/ directory (consolidate into /config/)"