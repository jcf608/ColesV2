#!/usr/bin/env ruby

# CARINA Tool Migration Script
# Replaces old tool structure with rationalized version

require 'fileutils'

BASE_DIR = "/Users/AI Guy/Dropbox/Kyndryl/Coles/retail-agentic-ai"
OLD_TOOLS = "#{BASE_DIR}/tools"
OLD_CONFIG = "#{BASE_DIR}/config/tools"
OLD_APP_TOOLS = "#{BASE_DIR}/app/tools"
OLD_APP_CONFIG = "#{BASE_DIR}/app/config/tools"

NEW_TOOLS = "#{BASE_DIR}/tools_new"
NEW_CONFIG = "#{BASE_DIR}/config_new"

# Backup directories
BACKUP_DIR = "#{BASE_DIR}/tools_backup_#{Time.now.strftime('%Y%m%d_%H%M%S')}"

def backup_original_structure
  puts "📦 Creating backup of original structure..."
  
  FileUtils.mkdir_p(BACKUP_DIR)
  
  # Backup existing directories
  if Dir.exist?(OLD_TOOLS)
    FileUtils.cp_r(OLD_TOOLS, "#{BACKUP_DIR}/tools_original")
    puts "✓ Backed up #{OLD_TOOLS}"
  end
  
  if Dir.exist?(OLD_CONFIG)
    FileUtils.cp_r(OLD_CONFIG, "#{BACKUP_DIR}/config_tools_original")
    puts "✓ Backed up #{OLD_CONFIG}"
  end
  
  if Dir.exist?(OLD_APP_TOOLS)
    FileUtils.cp_r(OLD_APP_TOOLS, "#{BACKUP_DIR}/app_tools_original")
    puts "✓ Backed up #{OLD_APP_TOOLS}"
  end
  
  if Dir.exist?(OLD_APP_CONFIG)
    FileUtils.cp_r(OLD_APP_CONFIG, "#{BACKUP_DIR}/app_config_tools_original")  
    puts "✓ Backed up #{OLD_APP_CONFIG}"
  end
end

def migrate_to_new_structure
  puts "\n🔄 Migrating to rationalized structure..."
  
  # Remove old directories
  [OLD_TOOLS, OLD_CONFIG, OLD_APP_TOOLS, OLD_APP_CONFIG].each do |dir|
    if Dir.exist?(dir)
      FileUtils.rm_rf(dir)
      puts "✓ Removed #{dir}"
    end
  end
  
  # Move new structure into place
  if Dir.exist?(NEW_TOOLS)
    FileUtils.mv(NEW_TOOLS, OLD_TOOLS)
    puts "✓ Activated new tools structure"
  end
  
  if Dir.exist?(NEW_CONFIG)
    FileUtils.mv(NEW_CONFIG, OLD_CONFIG)
    puts "✓ Activated new config structure"
  end
end

def create_tool_index
  puts "\n📋 Creating tool index..."
  
  tool_index = {
    "structure_version" => "2.0",
    "rationalized_date" => Time.now.strftime("%Y-%m-%d"),
    "categories" => {}
  }
  
  # Scan new structure
  Dir.glob("#{OLD_TOOLS}/*").each do |category_dir|
    next unless Dir.directory?(category_dir)
    
    category = File.basename(category_dir)
    tool_index["categories"][category] = []
    
    Dir.glob("#{category_dir}/*.rb").each do |tool_file|
      tool_name = File.basename(tool_file, '.rb')
      config_file = "#{OLD_CONFIG}/#{category}/#{tool_name}.json"
      
      tool_info = {
        "name" => tool_name,
        "file" => "tools/#{category}/#{tool_name}.rb",
        "config" => File.exist?(config_file) ? "config/#{category}/#{tool_name}.json" : nil,
        "class" => "CARINA::#{category.capitalize}::#{tool_name.split('_').map(&:capitalize).join}"
      }
      
      tool_index["categories"][category] << tool_info
    end
  end
  
  # Write index file
  index_file = "#{BASE_DIR}/tool_index.json"
  File.write(index_file, JSON.pretty_generate(tool_index))
  puts "✓ Created #{index_file}"
end

def generate_migration_report
  puts "\n📊 Migration Report"
  puts "=" * 50
  
  report = {
    "migration_date" => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
    "backup_location" => BACKUP_DIR,
    "tools_migrated" => 0,
    "categories_created" => 0,
    "duplicates_resolved" => [
      "impact-of-staff-shortfall_tools.rb (consolidated)",
      "server-outage-impact_tools.rb (consolidated)"
    ],
    "structure_improvements" => [
      "Eliminated _tools suffix inconsistencies",
      "Created logical category groupings", 
      "Established modular class architecture",
      "Unified configuration format",
      "Removed duplicate implementations"
    ]
  }
  
  # Count migrated tools
  Dir.glob("#{OLD_TOOLS}/*/*.rb").each { report["tools_migrated"] += 1 }
  Dir.glob("#{OLD_TOOLS}/*").each { |d| report["categories_created"] += 1 if Dir.directory?(d) }
  
  puts "Tools migrated: #{report['tools_migrated']}"
  puts "Categories created: #{report['categories_created']}"
  puts "Duplicates resolved: #{report['duplicates_resolved'].length}"
  puts "Backup location: #{report['backup_location']}"
  
  # Write report
  report_file = "#{BASE_DIR}/migration_report.json"
  File.write(report_file, JSON.pretty_generate(report))
  puts "✓ Created #{report_file}"
end

def update_application_references
  puts "\n🔗 Creating reference update script..."
  
  update_script = <<~RUBY
    #!/usr/bin/env ruby
    
    # CARINA Application Reference Updater
    # Updates application code to use new tool structure
    
    # Tool name mappings (old => new)
    TOOL_MAPPINGS = {
      'competitor-pricing_tools' => 'CARINA::Retail::CompetitorPricing',
      'expiring-soon_tools' => 'CARINA::Retail::ExpiringProducts',
      'items-at-risk_tools' => 'CARINA::Retail::InventoryRisk',
      'restock-options_tools' => 'CARINA::Retail::RestockManagement',
      'policy-check_tools' => 'CARINA::Retail::PolicyCompliance',
      'staff-allocation_tools' => 'CARINA::Operations::StaffAllocation',
      'capacity-planning_tools' => 'CARINA::Operations::CapacityPlanning',
      'impact-of-staff-shortfall_tools' => 'CARINA::Operations::StaffShortfallAnalysis',
      'backup-status_tools' => 'CARINA::Systems::BackupStatus',
      'system-health_tools' => 'CARINA::Systems::SystemHealth',
      'server-outage-impact_tools' => 'CARINA::Systems::ServerOutageAnalysis',
      'critical-systems-status_tools' => 'CARINA::Systems::CriticalSystems',
      'security-alerts_tools' => 'CARINA::Security::SecurityAlerts',
      'incident-summary_tools' => 'CARINA::Incidents::IncidentManagement',
      'change-calendar_tools' => 'CARINA::Incidents::ChangeCalendar',
      'weather-impact-analysis_tools' => 'CARINA::External::WeatherAnalysis'
    }
    
    puts "To update application code:"
    puts "1. Replace old tool file requires with: require_relative 'tools/[category]/[tool_name]'"
    puts "2. Update method calls to use class methods: CARINA::Category::ToolClass.method_name"
    puts "3. Update configuration file references to use new paths"
    puts "4. Test all tool integrations with new structure"
    
    TOOL_MAPPINGS.each do |old, new|
      puts "  #{old} => #{new}"
    end
  RUBY
  
  File.write("#{BASE_DIR}/update_references.rb", update_script)
  puts "✓ Created update_references.rb"
end

# Main execution
puts "🚀 CARINA Tool Migration Starting..."
puts "=" * 50

begin
  backup_original_structure
  migrate_to_new_structure  
  create_tool_index
  generate_migration_report
  update_application_references
  
  puts "\n✅ Migration completed successfully!"
  puts "\n📋 Next Steps:"
  puts "1. Review tool_index.json for new structure"
  puts "2. Run update_references.rb guidance to update app code"
  puts "3. Test all tool functionality"
  puts "4. Remove backup directory after verification"
  
rescue StandardError => e
  puts "\n❌ Migration failed: #{e.message}"
  puts "Backup preserved at: #{BACKUP_DIR}"
  exit 1
end