# CARINA Staff Allocation Tools
# Rationalized from: staff-allocation_tools.rb
# Category: Operations
# Description: Tools for optimizing staff scheduling and allocation

module CARINA
  module Operations
    class StaffAllocation
      
      # Original implementation refactored into class methods
                def get_weekend_traffic_forecast(params)
            # Extract and validate parameters
            store_id = params[:store_id]
            weekend_date = params[:weekend_date] # Expected format: "YYYY-MM-DD" for Saturday
            
            # Validate required parameters
            raise ArgumentError, "store_id is required" if store_id.nil? || store_id.empty?
            raise ArgumentError, "weekend_date is required" if weekend_date.nil? || weekend_date.empty?
            
            begin
              # Parse and validate date
              date = Date.parse(weekend_date)
              raise ArgumentError, "Date must be a Saturday" unless date.saturday?
            rescue Date::Error
              raise ArgumentError, "Invalid date format. Use YYYY-MM-DD"
            end
            
            # Mock realistic weekend traffic data
            {
              store_id: store_id,
              forecast_date: weekend_date,
              saturday_forecast: {
                hourly_traffic: {
                  "08:00" => { customers: 45, checkout_transactions: 38 },
                  "09:00" => { customers: 120, checkout_transactions: 95 },
                  "10:00" => { customers: 180, checkout_transactions: 155 },
                  "11:00" => { customers: 220, checkout_transactions: 190 },
                  "12:00" => { customers: 280, checkout_transactions: 245 },
                  "13:00" => { customers: 320, checkout_transactions: 285 },
                  "14:00" => { customers: 290, checkout_transactions: 260 },
                  "15:00" => { customers: 250, checkout_transactions: 215 },
                  "16:00" => { customers: 200, checkout_transactions: 170 },
                  "17:00" => { customers: 160, checkout_transactions: 135 },
                  "18:00" => { customers: 110, checkout_transactions: 90 },
                  "19:00" => { customers: 75, checkout_transactions: 60 }
                },
                peak_hours: ["12:00", "13:00", "14:00"],
                total_customers: 2250,
                total_transactions: 1938
              },
              sunday_forecast: {
                hourly_traffic: {
                  "10:00" => { customers: 85, checkout_transactions: 70 },
                  "11:00" => { customers: 140, checkout_transactions: 120 },
                  "12:00" => { customers: 200, checkout_transactions: 175 },
                  "13:00" => { customers: 240, checkout_transactions: 210 },
                  "14:00" => { customers: 220, checkout_transactions: 195 },
                  "15:00" => { customers: 180, checkout_transactions: 155 },
                  "16:00" => { customers: 130, checkout_transactions: 110 },
                  "17:00" => { customers: 90, checkout_transactions: 75 }
                },
                peak_hours: ["12:00", "13:00", "14:00"],
                total_customers: 1285,
                total_transactions: 1110
              },
              weather_impact: "sunny",
              special_events: ["Local farmers market nearby", "Youth soccer tournament"],
              confidence_level: 0.85
            }
          rescue => e
            { error: e.message, status: "failed" }
          end
          

          def get_current_staff_schedules(params)
            # Extract and validate parameters
            store_id = params[:store_id]
            date_range = params[:date_range] || {}
            start_date = date_range[:start_date]
            end_date = date_range[:end_date]
            
            # Validate required parameters
            raise ArgumentError, "store_id is required" if store_id.nil? || store_id.empty?
            raise ArgumentError, "start_date is required" if start_date.nil? || start_date.empty?
            raise ArgumentError, "end_date is required" if end_date.nil? || end_date.empty?
            
            begin
              # Validate date formats
              Date.parse(start_date)
              Date.parse(end_date)
            rescue Date::Error
              raise ArgumentError, "Invalid date format. Use YYYY-MM-DD"
            end
            
            # Mock current staff schedule data
            {
              store_id: store_id,
              schedule_period: {
                start_date: start_date,
                end_date: end_date
              },
              scheduled_staff: [
                {
                  employee_id: "EMP001",
                  name: "Sarah Johnson",
                  position: "Cashier",
                  department: "Front End",
                  scheduled_hours: {
                    saturday: { start: "08:00", end: "16:00", hours: 8 },
                    sunday: { start: "10:00", end: "18:00", hours: 8 }
                  },
                  hourly_rate: 16.50,
                  experience_level: "experienced"
                },
                {
                  employee_id: "EMP002",
                  name: "Mike Rodriguez",
                  position: "Department Manager",
                  department: "Produce",
                  scheduled_hours: {
                    saturday: { start: "06:00", end: "14:00", hours: 8 },
                    sunday: { start: "off", end: "off", hours: 0 }
                  },
                  hourly_rate: 22.00,
                  experience_level: "expert"
                },
                {
                  employee_id: "EMP003",
                  name: "Jennifer Chen",
                  position: "Stock Clerk",
                  department: "Grocery",
                  scheduled_hours: {
                    saturday: { start: "07:00", end: "15:00", hours: 8 },
                    sunday: { start: "09:00", end: "17:00", hours: 8 }
                  },
                  hourly_rate: 15.00,
                  experience_level: "intermediate"
                },
                {
                  employee_id: "EMP004",
                  name: "David Thompson",
                  position: "Cashier",
                  department: "Front End",
                  scheduled_hours: {
                    saturday: { start: "12:00", end: "20:00", hours: 8 },
                    sunday: { start: "off", end: "off", hours: 0 }
                  },
                  hourly_rate: 16.50,
                  experience_level: "new"
                }
              ],
              coverage_summary: {
                saturday: {
                  total_staff_hours: 32,
                  cashier_hours: 16,
                  department_coverage: ["Front End", "Produce", "Grocery"]
                },
                sunday: {
                  total_staff_hours: 16,
                  cashier_hours: 8,
                  department_coverage: ["Front End", "Grocery"]
                }
              },
              overtime_hours: 0,
              total_labor_cost: 1056.00
            }
          rescue => e
            { error: e.message, status: "failed" }
          end
          

          def calculate_staffing_requirements(params)
            # Extract and validate parameters
            traffic_forecast = params[:traffic_forecast] || {}
            service_standards = params[:service_standards] || {}
            
            # Validate required parameters
            raise ArgumentError, "traffic_forecast data is required" if traffic_forecast.empty?
            
            # Set default service standards if not provided
            customers_per_cashier = service_standards[:customers_per_cashier] || 25
            transactions_per_hour_per_cashier = service_standards[:transactions_per_hour_per_cashier] || 15
            stock_clerks_per_100_customers = service_standards[:stock_clerks_per_100_customers] || 1.5
            
            # Calculate staffing requirements based on traffic forecast
            saturday_requirements = calculate_hourly_staffing(
              traffic_forecast.dig(:saturday_forecast, :hourly_traffic) || {},
              customers_per_cashier,
              transactions_per_hour_per_cashier,
              stock_clerks_per_100_customers
            )
            
            sunday_requirements = calculate_hourly_staffing(
              traffic_forecast.dig(:sunday_forecast, :hourly_traffic) || {},
              customers_per_cashier,
              transactions_per_hour_per_cashier,
              stock_clerks_per_100_customers
            )
            
            {
              store_id: traffic_forecast[:store_id],
              requirements_date: traffic_forecast[:forecast_date],
              service_standards: {
                customers_per_cashier: customers_per_cashier,
                transactions_per_hour_per_cashier: transactions_per_hour_per_cashier,
                stock_clerks_per_100_customers: stock_clerks_per_100_customers
              },
              saturday_requirements: saturday_requirements,
              sunday_requirements: sunday_requirements,
              weekend_summary: {
                total_cashier_hours_needed: saturday_requirements[:total_cashier_hours] + sunday_requirements[:total_cashier_hours],
                total_stock_clerk_hours_needed: saturday_requirements[:total_stock_hours] + sunday_requirements[:total_stock_hours],
                peak_staffing_saturday: saturday_requirements[:peak_hour_staff],
                peak_staffing_sunday: sunday_requirements[:peak_hour_staff]
              }
            }
          rescue => e
            { error: e.message, status: "failed" }
          end
          

          def get_available_staff_pool(params)
            # Extract and validate parameters
            store_id = params[:store_id]
            date_range = params[:date_range] || {}
            positions_needed = params[:positions_needed] || []
            
            # Validate required parameters
            raise ArgumentError, "store_id is required" if store_id.nil? || store_id.empty?
            
            # Mock available staff pool data
            {
              store_id: store_id,
              query_date: Date.today.strftime("%Y-%m-%d"),
              available_staff: [
                {
                  employee_id: "EMP005",
                  name: "Lisa Wang",
                  position: "Cashier",
                  department: "Front End",
                  availability: {
                    saturday: { available: true, preferred_hours: "09:00-17:00" },
                    sunday: { available: true, preferred_hours: "11:00-19:00" }
                  },
                  hourly_rate: 17.00,
                  experience_level: "experienced",
                  skills: ["POS systems", "Customer service", "Money handling"],
                  max_hours_per_week: 35
                },
                {
                  employee_id: "EMP006",
                  name: "Carlos Martinez",
                  position: "Stock Clerk",
                  department: "Grocery",
                  availability: {
                    saturday: { available: true, preferred_hours: "06:00-14:00" },
                    sunday: { available: false, preferred_hours: nil }
                  },
                  hourly_rate: 15.50,
                  experience_level: "intermediate",
                  skills: ["Inventory management", "Heavy lifting", "Forklift certified"],
                  max_hours_per_week: 40
                },
                {
                  employee_id: "EMP007",
                  name: "Amanda Foster",
                  position: "Cashier",
                  department: "Front End",
                  availability: {
                    saturday: { available: false, preferred_hours: nil },
                    sunday: { available: true, preferred_hours: "10:00-18:00" }
                  },
                  hourly_rate: 16.00,
                  experience_level: "new",
                  skills: ["Customer service", "Basic POS"],
                  max_hours_per_week: 25
                },
                {
                  employee_id: "EMP008",
                  name: "Robert Kim",
                  position: "Department Associate",
                  department: "Produce",
                  availability: {
                    saturday: { available: true, preferred_hours: "07:00-15:00" },
                    sunday: { available: true, preferred_hours: "08:00-16:00" }
                  },
                  hourly_rate: 18.00,
                  experience_level: "experienced",
                  skills: ["Produce handling", "Display setup", "Quality control"],
                  max_hours_per_week: 32
                }
              ],
              staff_summary: {
                total_available: 4,
                by_position: {
                  "Cashier" => 2,
                  "Stock Clerk" => 1,
                  "Department Associate" => 1
                },
                saturday_available: 3,
                sunday_available: 3,
                total_available_hours: {
                  saturday: 24,
                  sunday: 24
                }
              },
              constraints: {
                union_overtime_rules: "Time and half after 8 hours daily, double time after 12 hours",
                minimum_break_requirements: "15 min break every 4 hours, 30 min lunch after 6 hours",
                scheduling_lead_time: "72 hours notice preferred"
              }
            }
          rescue => e
            { error: e.message, status: "failed" }
          end
          
          private
          

          def calculate_hourly_staffing(hourly_traffic, customers_per_cashier, transactions_per_cashier, stock_ratio)
            return { total_cashier_hours: 0, total_stock_hours: 0, peak_hour_staff: 0 } if hourly_traffic.empty?
            
            hourly_requirements = {}
            total_cashier_hours = 0
            total_stock_hours = 0
            max_staff = 0
            
            hourly_traffic.each do |hour, traffic|
              customers = traffic[:customers] || 0
              transactions = traffic[:checkout_transactions] || 0
              
              # Calculate cashiers needed based on both customers and transactions
              cashiers_for_customers = (customers.to_f / customers_per_cashier).ceil
              cashiers_for_transactions = (transactions.to_f / transactions_per_cashier).ceil
              cashiers_needed = [cashiers_for_customers, cashiers_for_transactions].max
              
              # Calculate stock clerks needed
              stock_clerks_needed = (customers.to_f / 100 * stock_ratio).ceil
              
              total_staff = cashiers_needed + stock_clerks_needed
              max_staff = total_staff if total_staff > max_staff
              
              hourly_requirements[hour] = {
                cashiers_needed: cashiers_needed,
                stock_clerks_needed: stock_clerks_needed,
                total_staff: total_staff
              }
              
              total_cashier_hours += cashiers_needed
              total_stock_hours += stock_clerks_needed
            end
            
            {
              hourly_breakdown: hourly_requirements,
              total_cashier_hours: total_cashier_hours,
              total_stock_hours: total_stock_hours,
              peak_hour_staff: max_staff
            }
          end
      
    end
  end
end
