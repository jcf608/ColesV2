# CARINA External Tools - Weather Analysis
# Rationalized from: weather-impact-analysis_tools.rb
# Category: External Services
# Description: Tools for weather data analysis and retail impact assessment

module CARINA
  module External
    class WeatherAnalysis
      
      def self.get_weather_forecast(params)
        store_id = params[:store_id]
        days_ahead = params[:days_ahead]&.to_i || 1
        include_historical = params[:include_historical] || false
        
        {
          store_id: store_id,
          location: determine_store_location(store_id),
          forecast_date: (Date.today + days_ahead).to_s,
          temperature_high: rand(15..35),
          temperature_low: rand(5..20),
          conditions: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Rain', 'Heavy Rain', 'Snow'].sample,
          precipitation_mm: rand(0..25),
          precipitation_probability: rand(0..100),
          wind_speed_kmh: rand(5..40),
          confidence_level: rand(70..95),
          source: 'Bureau of Meteorology',
          historical_same_date: include_historical ? generate_historical_data : nil
        }
      end
      
      def self.analyze_weather_impact(params)
        weather_data = params[:weather_data] || {}
        product_category = params[:product_category]&.to_s
        
        # Calculate impact based on weather conditions
        impact_factors = calculate_weather_impact(weather_data, product_category)
        
        {
          success: true,
          product_category: product_category,
          weather_conditions: weather_data,
          impact_analysis: {
            sales_impact_percentage: impact_factors[:sales_impact],
            demand_forecast_adjustment: impact_factors[:demand_adjustment],
            recommended_stock_adjustment: impact_factors[:stock_adjustment],
            customer_traffic_impact: impact_factors[:traffic_impact]
          },
          recommendations: generate_weather_recommendations(impact_factors, product_category),
          confidence_score: rand(75..95)
        }
      end
      
      def self.update_delivery_schedule(params)
        supplier_id = params[:supplier_id]
        delivery_date = params[:delivery_date]
        adjustment_pct = params[:adjustment_pct]&.to_f || 0
        
        original_quantity = 100 # Mock base quantity
        adjusted_quantity = (original_quantity * (1 + adjustment_pct / 100.0)).round
        
        {
          success: true,
          supplier_id: supplier_id,
          delivery_date: delivery_date,
          original_quantity: original_quantity,
          adjusted_quantity: adjusted_quantity,
          adjustment_percentage: adjustment_pct,
          reason: determine_adjustment_reason(adjustment_pct),
          updated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
          confirmation_required: adjustment_pct.abs > 20
        }
      end
      
      private
      
      def self.determine_store_location(store_id)
        locations = {
          'STORE_001' => 'Sydney, NSW',
          'STORE_002' => 'Melbourne, VIC', 
          'STORE_003' => 'Brisbane, QLD',
          'STORE_004' => 'Perth, WA',
          'STORE_005' => 'Adelaide, SA'
        }
        locations[store_id] || 'Sydney, NSW'
      end
      
      def self.generate_historical_data
        {
          temperature_high: rand(15..30),
          conditions: ['Sunny', 'Partly Cloudy', 'Rain'].sample,
          sales_impact_pct: rand(-15..15),
          customer_count: rand(200..500)
        }
      end
      
      def self.calculate_weather_impact(weather_data, product_category)
        conditions = weather_data[:conditions]&.downcase || ''
        temp_high = weather_data[:temperature_high] || 25
        precipitation = weather_data[:precipitation_mm] || 0
        
        base_impact = case product_category&.downcase
        when /ice cream/, /cold drinks/
          temp_high > 25 ? 20 : -10  # Hot weather increases cold product sales
        when /soup/, /hot drinks/
          temp_high < 15 ? 15 : -5   # Cold weather increases hot product sales
        when /umbrellas/, /rain gear/
          precipitation > 5 ? 50 : -20  # Rain increases rain gear sales
        when /fresh produce/
          conditions.include?('rain') ? -10 : 5  # People avoid shopping in rain
        else
          0  # Neutral impact for other categories
        end
        
        # Adjust based on weather severity
        severity_multiplier = case
        when precipitation > 15 then 1.5
        when temp_high > 35 || temp_high < 5 then 1.3
        else 1.0
        end
        
        final_impact = (base_impact * severity_multiplier).round(1)
        
        {
          sales_impact: final_impact,
          demand_adjustment: final_impact * 0.8,
          stock_adjustment: final_impact > 10 ? final_impact * 0.6 : 0,
          traffic_impact: precipitation > 10 ? -15 : 0
        }
      end
      
      def self.generate_weather_recommendations(impact_factors, product_category)
        recommendations = []
        
        if impact_factors[:sales_impact] > 15
          recommendations << "Consider increasing stock levels by #{impact_factors[:stock_adjustment].round}%"
          recommendations << "Prepare promotional campaigns for #{product_category}"
        elsif impact_factors[:sales_impact] < -10
          recommendations << "Consider reducing delivery quantities to prevent overstocking"
        end
        
        if impact_factors[:traffic_impact] < -10
          recommendations << "Consider extended hours or delivery options during weather events"
          recommendations << "Increase online/mobile ordering promotions"
        end
        
        recommendations << "Monitor weather updates for forecast changes"
        
        recommendations
      end
      
      def self.determine_adjustment_reason(adjustment_pct)
        case
        when adjustment_pct > 10 then "Increased demand expected due to favorable weather"
        when adjustment_pct < -10 then "Reduced demand expected due to adverse weather" 
        when adjustment_pct > 0 then "Minor increase for weather-related demand"
        when adjustment_pct < 0 then "Minor decrease due to weather conditions"
        else "No weather-based adjustment needed"
        end
      end
      
    end
  end
end