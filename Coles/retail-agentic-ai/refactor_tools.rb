#!/usr/bin/env ruby

# CARINA Tool Refactoring Script
# Automates the rationalization of tool files

require 'fileutils'
require 'json'

BASE_DIR = "/Users/AI Guy/Dropbox/Kyndryl/Coles/retail-agentic-ai"
OLD_TOOLS_DIR = "#{BASE_DIR}/tools"
OLD_CONFIG_DIR = "#{BASE_DIR}/config/tools"
NEW_TOOLS_DIR = "#{BASE_DIR}/tools_new"
NEW_CONFIG_DIR = "#{BASE_DIR}/config_new"

# Tool mapping with categories
TOOL_CATEGORIES = {
  'retail' => [
    { old: 'expiring-soon_tools.rb', new: 'expiring_products.rb', display: 'Expiring Products' },
    { old: 'items-at-risk_tools.rb', new: 'inventory_risk.rb', display: 'Inventory Risk' },
    { old: 'restock-options_tools.rb', new: 'restock_management.rb', display: 'Restock Management' },
    { old: 'policy-check_tools.rb', new: 'policy_compliance.rb', display: 'Policy Compliance' }
  ],
  'operations' => [
    { old: 'staff-allocation_tools.rb', new: 'staff_allocation.rb', display: 'Staff Allocation' },
    { old: 'capacity-planning_tools.rb', new: 'capacity_planning.rb', display: 'Capacity Planning' }
  ],
  'systems' => [
    { old: 'backup-status_tools.rb', new: 'backup_status.rb', display: 'Backup Status' },
    { old: 'system-health_tools.rb', new: 'system_health.rb', display: 'System Health' },
    { old: 'server-outage-impact_tools.rb', new: 'server_outage_analysis.rb', display: 'Server Outage Analysis' },
    { old: 'critical-systems-status_tools.rb', new: 'critical_systems.rb', display: 'Critical Systems' }
  ],
  'security' => [
    { old: 'security-alerts_tools.rb', new: 'security_alerts.rb', display: 'Security Alerts' }
  ],
  'incidents' => [
    { old: 'incident-summary_tools.rb', new: 'incident_management.rb', display: 'Incident Management' },
    { old: 'change-calendar_tools.rb', new: 'change_calendar.rb', display: 'Change Calendar' }
  ]
}

def create_rationalized_tool(category, tool_info)
  old_file = "#{OLD_TOOLS_DIR}/#{tool_info[:old]}"
  new_file = "#{NEW_TOOLS_DIR}/#{category}/#{tool_info[:new]}"
  
  return unless File.exist?(old_file)
  
  # Read original content
  original_content = File.read(old_file)
  
  # Create class name from display name
  class_name = tool_info[:display].gsub(/\s+/, '')
  
  # Generate new modular content
  new_content = <<~RUBY
    # CARINA #{tool_info[:display]} Tools
    # Rationalized from: #{tool_info[:old]}
    # Category: #{category.capitalize}
    # Description: #{get_description(tool_info[:display])}

    module CARINA
      module #{category.capitalize}
        class #{class_name}
          
          # Original implementation refactored into class methods
          #{indent_original_methods(original_content)}
          
        end
      end
    end
  RUBY
  
  File.write(new_file, new_content)
  puts "✓ Created #{new_file}"
end

def create_rationalized_config(category, tool_info)
  old_config_file = "#{OLD_CONFIG_DIR}/#{tool_info[:old].gsub('.rb', '.json')}"
  new_config_file = "#{NEW_CONFIG_DIR}/#{category}/#{tool_info[:new].gsub('.rb', '.json')}"
  
  return unless File.exist?(old_config_file)
  
  # Read and update config
  begin
    config = JSON.parse(File.read(old_config_file))
    
    # Wrap in new structure
    new_config = {
      "category" => category,
      "module" => tool_info[:display].gsub(/\s+/, ''),
      "description" => get_description(tool_info[:display]),
      "tools" => config.is_a?(Array) ? config : [config]
    }
    
    File.write(new_config_file, JSON.pretty_generate(new_config))
    puts "✓ Created #{new_config_file}"
  rescue JSON::ParserError => e
    puts "⚠ Warning: Could not parse #{old_config_file}: #{e.message}"
  end
end

def get_description(display_name)
  case display_name
  when /Expiring/i then "Tools for monitoring products approaching expiration dates"
  when /Inventory Risk/i then "Tools for analyzing inventory at risk of spoilage or loss"
  when /Restock/i then "Tools for managing product restocking and procurement"
  when /Policy/i then "Tools for compliance checking and policy validation"
  when /Staff Allocation/i then "Tools for optimizing staff scheduling and allocation"
  when /Capacity/i then "Tools for planning and managing operational capacity"
  when /Backup/i then "Tools for monitoring backup systems and recovery status"
  when /System Health/i then "Tools for monitoring overall system health and performance"
  when /Server Outage/i then "Tools for analyzing server outages and their business impact"
  when /Critical Systems/i then "Tools for monitoring critical system components"
  when /Security/i then "Tools for monitoring security alerts and threats"
  when /Incident/i then "Tools for managing incidents and service disruptions"
  when /Change Calendar/i then "Tools for managing change schedules and release calendars"
  else "Tools for #{display_name.downcase}"
  end
end

def indent_original_methods(content)
  # Extract method definitions and indent them
  methods = content.scan(/^def\s+\w+.*?(?=^def|\z)/m)
  methods.map { |method| method.lines.map { |line| "          #{line}" }.join }.join("\n")
end

# Main execution
puts "🔧 CARINA Tool Rationalization Starting..."
puts "=" * 50

TOOL_CATEGORIES.each do |category, tools|
  puts "\n📁 Processing #{category.capitalize} Category:"
  
  tools.each do |tool_info|
    create_rationalized_tool(category, tool_info)
    create_rationalized_config(category, tool_info)
  end
end

puts "\n🎯 Rationalization Summary:"
puts "- Created modular, categorized tool structure"
puts "- Eliminated naming inconsistencies" 
puts "- Established clear naming conventions"
puts "- Prepared for duplicate removal"

puts "\n⚠ Next Steps:"
puts "1. Test new tool structure"
puts "2. Update application references"
puts "3. Remove old tool files"
puts "4. Remove duplicate files from /app/tools/"