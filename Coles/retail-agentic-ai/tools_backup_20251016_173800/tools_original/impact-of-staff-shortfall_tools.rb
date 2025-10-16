# Tool implementations for: Weather Impact
# Generated: 2025-10-16 15:23:29 +1100

def get_weather_forecast(params)
  # Extract and validate parameters
  location = params[:location]&.to_s&.strip
  days = params[:days]&.to_i || 7
  
  raise ArgumentError, "Location is required" if location.nil? || location.empty?
  raise ArgumentError, "Days must be between 1 and 14" unless (1..14).include?(days)
  
  begin
    # Mock weather data based on location
    base_temp = location.downcase.include?('florida') ? 75 : 
                location.downcase.include?('minnesot') ? 35 : 55
    
    forecast_days = (0...days).map do |day|
      temp_variation = rand(-10..10)
      precipitation_chance = rand(0..100)
      
      {
        date: (Date.today + day).to_s,
        high_temp: base_temp + temp_variation + 10,
        low_temp: base_temp + temp_variation - 5,
        precipitation_chance: precipitation_chance,
        precipitation_type: precipitation_chance > 70 ? (base_temp < 32 ? 'snow' : 'rain') : 'none',
        wind_speed: rand(5..25),
        humidity: rand(40..90),
        conditions: precipitation_chance > 70 ? 'stormy' : 
                   precipitation_chance > 40 ? 'cloudy' : 'clear'
      }
    end
    
    {
      success: true,
      location: location,
      forecast_days: forecast_days,
      alerts: forecast_days.any? { |day| day[:precipitation_chance] > 80 } ? 
              ['severe_weather_warning'] : [],
      last_updated: Time.now.iso8601
    }
    
  rescue => e
    {
      success: false,
      error: "Weather service unavailable: #{e.message}",
      location: location
    }
  end
end

def get_current_produce_orders(params)
  # Extract and validate parameters
  store_id = params[:store_id]&.to_s
  date_range = params[:date_range] || 'next_7_days'
  category = params[:category]&.to_s
  
  raise ArgumentError, "Store ID is required" if store_id.nil? || store_id.empty?
  
  valid_ranges = %w[next_7_days next_14_days current_week current_month]
  raise ArgumentError, "Invalid date range" unless valid_ranges.include?(date_range)
  
  begin
    # Mock produce orders data
    produce_items = [
      { name: 'Bananas', category: 'fruit', supplier: 'Tropical Fruits Inc', unit: 'lbs' },
      { name: 'Lettuce', category: 'vegetable', supplier: 'Green Valley Farms', unit: 'heads' },
      { name: 'Tomatoes', category: 'vegetable', supplier: 'Sunshine Agriculture', unit: 'lbs' },
      { name: 'Apples', category: 'fruit', supplier: 'Orchard Fresh Co', unit: 'lbs' },
      { name: 'Carrots', category: 'vegetable', supplier: 'Root Vegetable Supply', unit: 'lbs' },
      { name: 'Strawberries', category: 'fruit', supplier: 'Berry Best Farms', unit: 'containers' },
      { name: 'Spinach', category: 'vegetable', supplier: 'Leafy Greens Ltd', unit: 'bags' },
      { name: 'Avocados', category: 'fruit', supplier: 'California Avocado Co', unit: 'each' }
    ]
    
    # Filter by category if specified
    filtered_items = category ? produce_items.select { |item| item[:category] == category } : produce_items
    
    orders = filtered_items.map do |item|
      delivery_date = Date.today + rand(1..7)
      quantity = rand(50..500)
      unit_cost = rand(0.50..5.00).round(2)
      
      {
        order_id: "ORD-#{rand(10000..99999)}",
        item_name: item[:name],
        category: item[:category],
        supplier: item[:supplier],
        quantity_ordered: quantity,
        unit: item[:unit],
        unit_cost: unit_cost,
        total_cost: (quantity * unit_cost).round(2),
        delivery_date: delivery_date.to_s,
        order_status: ['confirmed', 'pending', 'in_transit'].sample,
        temperature_sensitive: %w[Strawberries Lettuce Spinach].include?(item[:name]),
        shelf_life_days: rand(3..14)
      }
    end
    
    {
      success: true,
      store_id: store_id,
      date_range: date_range,
      total_orders: orders.length,
      total_value: orders.sum { |order| order[:total_cost] }.round(2),
      orders: orders,
      last_updated: Time.now.iso8601
    }
    
  rescue => e
    {
      success: false,
      error: "Unable to retrieve orders: #{e.message}",
      store_id: store_id
    }
  end
end

def analyze_weather_produce_impact(params)
  # Extract and validate parameters
  weather_data = params[:weather_data]
  produce_orders = params[:produce_orders]
  store_location = params[:store_location]&.to_s
  
  raise ArgumentError, "Weather data is required" unless weather_data.is_a?(Hash)
  raise ArgumentError, "Produce orders are required" unless produce_orders.is_a?(Hash)
  raise ArgumentError, "Store location is required" if store_location.nil? || store_location.empty?
  
  begin
    # Analyze weather impact on different produce categories
    high_risk_items = []
    medium_risk_items = []
    recommendations = []
    
    # Check for severe weather in forecast
    severe_weather_days = weather_data[:forecast_days]&.select { |day| day[:precipitation_chance] > 80 } || []
    hot_weather_days = weather_data[:forecast_days]&.select { |day| day[:high_temp] > 85 } || []
    
    produce_orders[:orders]&.each do |order|
      risk_level = 'low'
      risk_factors = []
      
      # Temperature sensitive items
      if order[:temperature_sensitive]
        if hot_weather_days.any?
          risk_level = 'high'
          risk_factors << 'high_temperature_exposure'
        end
      end
      
      # Delivery disruption risk
      delivery_date = Date.parse(order[:delivery_date])
      if severe_weather_days.any? { |day| Date.parse(day[:date]) == delivery_date }
        risk_level = 'high'
        risk_factors << 'delivery_disruption'
      end
      
      # Short shelf life with weather delays
      if order[:shelf_life_days] <= 5 && !severe_weather_days.empty?
        risk_level = risk_level == 'high' ? 'high' : 'medium'
        risk_factors << 'shortened_shelf_life'
      end
      
      impact_analysis = {
        order_id: order[:order_id],
        item_name: order[:item_name],
        risk_level: risk_level,
        risk_factors: risk_factors,
        recommended_actions: []
      }
      
      # Generate recommendations based on risk
      case risk_level
      when 'high'
        impact_analysis[:recommended_actions] = [
          'increase_refrigeration_capacity',
          'expedite_delivery',
          'reduce_order_quantity',
          'prepare_alternative_suppliers'
        ]
        high_risk_items << impact_analysis
      when 'medium'
        impact_analysis[:recommended_actions] = [
          'monitor_closely',
          'prepare_markdown_strategy'
        ]
        medium_risk_items << impact_analysis
      end
    end
    
    # Overall recommendations
    if !severe_weather_days.empty?
      recommendations << "Severe weather expected on #{severe_weather_days.map { |d| d[:date] }.join(', ')}"
      recommendations << "Consider delaying non-essential deliveries"
      recommendations << "Increase staff for potential weather-related customer demand"
    end
    
    if !hot_weather_days.empty?
      recommendations << "High temperatures expected - increase cooling capacity"
      recommendations << "Consider promotions on temperature-sensitive items"
    end
    
    {
      success: true,
      store_location: store_location,
      analysis_date: Time.now.iso8601,
      weather_summary: {
        severe_weather_days: severe_weather_days.length,
        high_temperature_days: hot_weather_days.length,
        average_precipitation_chance: weather_data[:forecast_days]&.map { |d| d[:precipitation_chance] }&.sum&./(weather_data[:forecast_days]&.length || 1)
      },
      risk_summary: {
        high_risk_orders: high_risk_items.length,
        medium_risk_orders: medium_risk_items.length,
        total_at_risk_value: (high_risk_items + medium_risk_items).sum { |item| 
          produce_orders[:orders].find { |o| o[:order_id] == item[:order_id] }&.dig(:total_cost) || 0 
        }.round(2)
      },
      high_risk_items: high_risk_items,
      medium_risk_items: medium_risk_items,
      recommendations: recommendations
    }
    
  rescue => e
    {
      success: false,
      error: "Analysis failed: #{e.message}",
      store_location: store_location
    }
  end
end

def get_supply_chain_alerts(params)
  # Extract and validate parameters
  region = params[:region]&.to_s || 'national'
  severity = params[:severity]&.to_s || 'all'
  category = params[:category]&.to_s
  
  valid_severities = %w[all low medium high critical]
  raise ArgumentError, "Invalid severity level" unless valid_severities.include?(severity)
  
  begin
    # Mock supply chain alerts
    all_alerts = [
      {
        alert_id: 'SC-2024-001',
        title: 'Hurricane affecting Florida citrus shipments',
        category: 'fruit',
        severity: 'high',
        region: 'southeast',
        affected_suppliers: ['Sunshine Citrus Co', 'Florida Fresh Fruits'],
        affected_products: ['Oranges', 'Grapefruits', 'Lemons'],
        estimated_impact: 'Delivery delays of 2-4 days, 15-20% price increase expected',
        start_date: (Date.today - 1).to_s,
        estimated_end_date: (Date.today + 5).to_s,
        alternative_suppliers: ['California Citrus Alliance', 'Texas Grove Co'],
        status: 'active'
      },
      {
        alert_id: 'SC-2024-002',
        title: 'Trucking strike affecting Midwest vegetable distribution',
        category: 'vegetable',
        severity: 'critical',
        region: 'midwest',
        affected_suppliers: ['Midwest Produce Hub', 'Great Plains Agriculture'],
        affected_products: ['Corn', 'Soybeans', 'Potatoes', 'Carrots'],
        estimated_impact: 'Complete delivery stoppage, seek alternative suppliers immediately',
        start_date: Date.today.to_s,
        estimated_end_date: (Date.today + 7).to_s,
        alternative_suppliers: ['Western Farm Collective', 'Southern Vegetable Network'],
        status: 'active'
      },
      {
        alert_id: 'SC-2024-003',
        title: 'Avocado shortage due to drought conditions',
        category: 'fruit',
        severity: 'medium',
        region: 'national',
        affected_suppliers: ['California Avocado Co', 'Mexico Fresh Import'],
        affected_products: ['Avocados'],
        estimated_impact: '25-30% price increase, limited availability',
        start_date: (Date.today - 3).to_s,
        estimated_end_date: (Date.today + 21).to_s,
        alternative_suppliers: ['South American Import Co'],
        status: 'active'
      },
      {
        alert_id: 'SC-2024-004',
        title: 'Refrigeration equipment failure at Northeast distribution center',
        category: 'all',
        severity: 'high',
        region: 'northeast',
        affected_suppliers: ['Cool Chain Logistics', 'Fresh Direct Distribution'],
        affected_products: ['All temperature-sensitive produce'],
        estimated_impact: 'Delivery delays, potential quality issues',
        start_date: (Date.today - 2).to_s,
        estimated_end_date: (Date.today + 3).to_s,
        alternative_suppliers: ['Atlantic Cold Storage', 'Northeast Fresh Logistics'],
        status: 'resolving'
      },
      {
        alert_id: 'SC-2024-005',
        title: 'Seasonal berry harvest delayed by late frost',
        category: 'fruit',
        severity: 'low',
        region: 'pacific_northwest',
        affected_suppliers: ['Northwest Berry Farms', 'Mountain Fresh Berries'],
        affected_products: ['Strawberries', 'Blueberries', 'Raspberries'],
        estimated_impact: '1-2 week delay in seasonal availability',
        start_date: (Date.today - 5).to_s,
        estimated_end_date: (Date.today + 10).to_s,
        alternative_suppliers: ['California Berry Co', 'Import Fresh Global'],
        status: 'monitoring'
      }
    ]
    
    # Filter alerts based on parameters
    filtered_alerts = all_alerts
    
    # Filter by region unless national
    unless region == 'national'
      filtered_alerts = filtered_alerts.select { |alert| alert[:region] == region || alert[:region] == 'national' }
    end
    
    # Filter by severity unless all
    unless severity == 'all'
      filtered_alerts = filtered_alerts.select { |alert| alert[:severity] == severity }
    end
    
    # Filter by category if specified
    if category
      filtered_alerts = filtered_alerts.select { |alert| alert[:category] == category || alert[:category] == 'all' }
    end
    
    # Calculate summary statistics
    severity_counts = filtered_alerts.group_by { |alert| alert[:severity] }.transform_values(&:count)
    active_alerts = filtered_alerts.select { |alert| alert[:status] == 'active' }
    
    {
      success: true,
      region: region,
      severity_filter: severity,
      category_filter: category,
      query_time: Time.now.iso8601,
      summary: {
        total_alerts: filtered_alerts.length,
        active_alerts: active_alerts.length,
        severity_breakdown: severity_counts,
        most_affected_categories: filtered_alerts.group_by { |alert| alert[:category] }.transform_values(&:count).sort_by { |k, v| -v }.to_h
      },
      alerts: filtered_alerts,
      recommendations: active_alerts.empty? ? 
        ['No active supply chain disruptions detected'] :
        [
          'Review affected suppliers and implement contingency plans',
          'Contact alternative suppliers for high-severity alerts',
          'Adjust inventory levels for affected products',
          'Communicate potential impacts to customers proactively'
        ]
    }
    
  rescue => e
    {
      success: false,
      error: "Unable to retrieve supply chain alerts: #{e.message}",
      region: region
    }
  end
end