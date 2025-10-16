# CARINA Change Calendar Tools
# Rationalized from: change-calendar_tools.rb
# Category: Incidents
# Description: Tools for managing change schedules and release calendars

module CARINA
  module Incidents
    class ChangeCalendar
      
      # Original implementation refactored into class methods
                def get_weekly_change_calendar(params)
            # Extract and validate parameters
            week_start = params[:week_start] || Date.today.beginning_of_week.strftime('%Y-%m-%d')
            department = params[:department] # optional filter
            
            begin
              start_date = Date.parse(week_start)
            rescue ArgumentError
              return { error: "Invalid week_start date format. Use YYYY-MM-DD." }
            end
            
            # Generate realistic weekly change calendar data
            changes = []
            
            # Monday changes
            changes << {
              date: start_date.strftime('%Y-%m-%d'),
              day: 'Monday',
              changes: [
                {
                  id: 'CHG-2024-001',
                  title: 'Dairy Section Temperature Control System Upgrade',
                  department: 'Dairy',
                  type: 'Infrastructure',
                  priority: 'High',
                  start_time: '02:00',
                  end_time: '04:00',
                  status: 'Scheduled'
                },
                {
                  id: 'CHG-2024-002',
                  title: 'Weekly Price Updates - Produce Section',
                  department: 'Produce',
                  type: 'Price Change',
                  priority: 'Medium',
                  start_time: '06:00',
                  end_time: '07:00',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Tuesday changes
            changes << {
              date: (start_date + 1).strftime('%Y-%m-%d'),
              day: 'Tuesday',
              changes: [
                {
                  id: 'CHG-2024-003',
                  title: 'POS System Security Patch Deployment',
                  department: 'IT',
                  type: 'System Update',
                  priority: 'Critical',
                  start_time: '01:00',
                  end_time: '03:00',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Wednesday changes
            changes << {
              date: (start_date + 2).strftime('%Y-%m-%d'),
              day: 'Wednesday',
              changes: [
                {
                  id: 'CHG-2024-004',
                  title: 'Bakery Oven Maintenance',
                  department: 'Bakery',
                  type: 'Maintenance',
                  priority: 'High',
                  start_time: '23:00',
                  end_time: '05:00',
                  status: 'Scheduled'
                },
                {
                  id: 'CHG-2024-005',
                  title: 'Inventory Management System Update',
                  department: 'IT',
                  type: 'System Update',
                  priority: 'Medium',
                  start_time: '03:00',
                  end_time: '04:30',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Thursday changes
            changes << {
              date: (start_date + 3).strftime('%Y-%m-%d'),
              day: 'Thursday',
              changes: [
                {
                  id: 'CHG-2024-006',
                  title: 'Frozen Foods Freezer Unit Replacement',
                  department: 'Frozen Foods',
                  type: 'Equipment',
                  priority: 'Critical',
                  start_time: '22:00',
                  end_time: '06:00',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Friday changes
            changes << {
              date: (start_date + 4).strftime('%Y-%m-%d'),
              day: 'Friday',
              changes: [
                {
                  id: 'CHG-2024-007',
                  title: 'Weekly Promotional Pricing Updates',
                  department: 'All',
                  type: 'Price Change',
                  priority: 'Medium',
                  start_time: '05:00',
                  end_time: '07:00',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Saturday changes
            changes << {
              date: (start_date + 5).strftime('%Y-%m-%d'),
              day: 'Saturday',
              changes: [
                {
                  id: 'CHG-2024-008',
                  title: 'Deli Counter Equipment Calibration',
                  department: 'Deli',
                  type: 'Maintenance',
                  priority: 'Low',
                  start_time: '07:00',
                  end_time: '08:00',
                  status: 'Scheduled'
                }
              ]
            }
            
            # Sunday changes
            changes << {
              date: (start_date + 6).strftime('%Y-%m-%d'),
              day: 'Sunday',
              changes: []
            }
            
            # Filter by department if specified
            if department
              changes.each do |day_data|
                day_data[:changes] = day_data[:changes].select do |change|
                  change[:department].downcase == department.downcase || change[:department] == 'All'
                end
              end
            end
            
            {
              week_start: week_start,
              week_end: (start_date + 6).strftime('%Y-%m-%d'),
              total_changes: changes.sum { |day| day[:changes].count },
              department_filter: department,
              changes: changes
            }
          end
          

          def filter_high_risk_changes(params)
            # Extract and validate parameters
            time_window = params[:time_window] || 'week' # week, month, day
            risk_level = params[:risk_level] || 'high' # critical, high, medium
            department = params[:department] # optional filter
            
            unless ['day', 'week', 'month'].include?(time_window)
              return { error: "Invalid time_window. Use 'day', 'week', or 'month'." }
            end
            
            unless ['critical', 'high', 'medium'].include?(risk_level)
              return { error: "Invalid risk_level. Use 'critical', 'high', or 'medium'." }
            end
            
            # Generate realistic high-risk changes data
            all_changes = [
              {
                id: 'CHG-2024-003',
                title: 'POS System Security Patch Deployment',
                department: 'IT',
                type: 'System Update',
                priority: 'Critical',
                risk_score: 95,
                risk_factors: ['Customer transaction impact', 'Payment processing downtime', 'Security vulnerability'],
                scheduled_date: '2024-01-16',
                scheduled_time: '01:00-03:00',
                estimated_duration: '2 hours',
                business_impact: 'All payment processing may be unavailable during maintenance window',
                rollback_plan: 'Automated rollback available within 15 minutes',
                approver: 'IT Director',
                status: 'Approved'
              },
              {
                id: 'CHG-2024-006',
                title: 'Frozen Foods Freezer Unit Replacement',
                department: 'Frozen Foods',
                type: 'Equipment',
                priority: 'Critical',
                risk_score: 88,
                risk_factors: ['Product spoilage risk', 'Customer shopping impact', 'Revenue loss'],
                scheduled_date: '2024-01-18',
                scheduled_time: '22:00-06:00',
                estimated_duration: '8 hours',
                business_impact: 'Frozen foods section will be inaccessible, potential product loss',
                rollback_plan: 'Emergency backup cooling units on standby',
                approver: 'Store Manager',
                status: 'Pending Approval'
              },
              {
                id: 'CHG-2024-001',
                title: 'Dairy Section Temperature Control System Upgrade',
                department: 'Dairy',
                type: 'Infrastructure',
                priority: 'High',
                risk_score: 75,
                risk_factors: ['Product quality impact', 'Temperature monitoring gap', 'Potential product loss'],
                scheduled_date: '2024-01-15',
                scheduled_time: '02:00-04:00',
                estimated_duration: '2 hours',
                business_impact: 'Dairy products may require manual temperature monitoring',
                rollback_plan: 'Revert to previous system configuration',
                approver: 'Operations Manager',
                status: 'Approved'
              },
              {
                id: 'CHG-2024-004',
                title: 'Bakery Oven Maintenance',
                department: 'Bakery',
                type: 'Maintenance',
                priority: 'High',
                risk_score: 70,
                risk_factors: ['Production scheduling impact', 'Fresh product availability', 'Customer disappointment'],
                scheduled_date: '2024-01-17',
                scheduled_time: '23:00-05:00',
                estimated_duration: '6 hours',
                business_impact: 'No fresh baked goods available until afternoon',
                rollback_plan: 'Source products from partner bakery if needed',
                approver: 'Bakery Manager',
                status: 'Scheduled'
              }
            ]
            
            # Filter by risk level
            risk_threshold = case risk_level
                            when 'critical' then 85
                            when 'high' then 70
                            when 'medium' then 50
                            end
            
            filtered_changes = all_changes.select { |change| change[:risk_score] >= risk_threshold }
            
            # Filter by department if specified
            if department
              filtered_changes = filtered_changes.select do |change|
                change[:department].downcase == department.downcase
              end
            end
            
            # Calculate risk statistics
            total_risk_score = filtered_changes.sum { |change| change[:risk_score] }
            avg_risk_score = filtered_changes.empty? ? 0 : (total_risk_score.to_f / filtered_changes.count).round(1)
            
            {
              time_window: time_window,
              risk_level: risk_level,
              department_filter: department,
              total_changes: filtered_changes.count,
              average_risk_score: avg_risk_score,
              highest_risk_change: filtered_changes.max_by { |c| c[:risk_score] },
              changes: filtered_changes,
              risk_summary: {
                critical_count: filtered_changes.count { |c| c[:risk_score] >= 85 },
                high_count: filtered_changes.count { |c| c[:risk_score] >= 70 && c[:risk_score] < 85 },
                pending_approval: filtered_changes.count { |c| c[:status] == 'Pending Approval' }
              }
            }
          end
          

          def get_change_details(params)
            # Extract and validate parameters
            change_id = params[:change_id]
            
            if change_id.nil? || change_id.empty?
              return { error: "change_id parameter is required" }
            end
            
            # Mock database of change details
            change_database = {
              'CHG-2024-001' => {
                id: 'CHG-2024-001',
                title: 'Dairy Section Temperature Control System Upgrade',
                description: 'Upgrade existing temperature monitoring system in dairy section to new IoT-enabled sensors with real-time alerting capabilities',
                department: 'Dairy',
                type: 'Infrastructure',
                priority: 'High',
                risk_score: 75,
                status: 'Approved',
                created_date: '2024-01-10',
                scheduled_date: '2024-01-15',
                scheduled_time: '02:00-04:00',
                estimated_duration: '2 hours',
                actual_duration: nil,
                created_by: 'John Smith, Facilities Manager',
                approved_by: 'Sarah Johnson, Operations Manager',
                assigned_team: ['Mike Chen - HVAC Technician', 'Lisa Wong - Systems Specialist'],
                business_justification: 'Current system has 15% failure rate causing product spoilage. New system will reduce waste by estimated $2,400/month.',
                business_impact: 'Dairy products may require manual temperature monitoring during upgrade window',
                risk_factors: [
                  'Product quality impact during sensor transition',
                  'Brief temperature monitoring gap',
                  'Potential product loss if upgrade fails'
                ],
                mitigation_steps: [
                  'Manual temperature checks every 15 minutes during upgrade',
                  'Backup sensors available for immediate deployment',
                  'Emergency contact list for after-hours support'
                ],
                rollback_plan: 'Revert to previous system configuration within 30 minutes if issues occur',
                success_criteria: [
                  'All new sensors reporting correctly',
                  'Temperature alerts functioning',
                  'Historical data migration complete'
                ],
                affected_systems: ['Temperature Monitoring', 'Alert Management', 'Inventory System'],
                dependencies: ['Network connectivity', 'Power systems'],
                change_history: [
                  { date: '2024-01-10', action: 'Change created', user: 'John Smith' },
                  { date: '2024-01-12', action: 'Risk assessment completed', user: 'Risk Team' },
                  { date: '2024-01-13', action: 'Approved by Operations Manager', user: 'Sarah Johnson' }
                ],
                communications: {
                  stakeholders_notified: ['Store Manager', 'Dairy Staff', 'Maintenance Team'],
                  notification_sent: '2024-01-14',
                  customer_impact_notice: 'None required - no customer-facing changes'
                }
              },
              'CHG-2024-003' => {
                id: 'CHG-2024-003',
                title: 'POS System Security Patch Deployment',
                description: 'Deploy critical security patches to all point-of-sale terminals to address recently discovered vulnerabilities',
                department: 'IT',
                type: 'System Update',
                priority: 'Critical',
                risk_score: 95,
                status: 'Approved',
                created_date: '2024-01-12',
                scheduled_date: '2024-01-16',
                scheduled_time: '01:00-03:00',
                estimated_duration: '2 hours',
                actual_duration: nil,
                created_by: 'David Park, IT Security Manager',
                approved_by: 'Jennifer Liu, IT Director',
                assigned_team: ['Alex Rodriguez - Systems Administrator', 'Emily Chen - Security Specialist'],
                business_justification: 'Critical security vulnerabilities discovered in POS software. Immediate patching required to prevent potential data breach.',
                business_impact: 'All payment processing will be unavailable during 2-hour maintenance window',
                risk_factors: [
                  'Complete payment processing downtime',
                  'Customer transaction impact',
                  'Potential patch installation failures',
                  'Staff training on any system changes'
                ],
                mitigation_steps: [
                  'Schedule during lowest customer traffic period',
                  'Backup POS system available for emergencies',
                  'IT staff on-site for immediate issue resolution',
                  'Communication to all staff about temporary cash-only operations'
                ],
                rollback_plan: 'Automated rollback to previous version available within 15 minutes',
                success_criteria: [
                  'All POS terminals successfully patched',
                  'Payment processing fully functional',
                  'Security scans show vulnerabilities resolved'
                ],
                affected_systems: ['POS Terminals', 'Payment Processing', 'Transaction Reporting'],
                dependencies: ['Network infrastructure', 'Payment gateway connectivity'],
                change_history: [
                  { date: '2024-01-12', action: 'Emergency change created', user: 'David Park' },
                  { date: '2024-01-12', action: 'Expedited risk assessment', user: 'Security Team' },
                  { date: '2024-01-13', action: 'Emergency approval granted', user: 'Jennifer Liu' }
                ],
                communications: {
                  stakeholders_notified: ['Store Manager', 'Cashiers', 'Customer Service', 'Security Team'],
                  notification_sent: '2024-01-14',
                  customer_impact_notice: 'Store signage prepared for cash
      
    end
  end
end
