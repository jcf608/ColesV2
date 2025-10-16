# CARINA Retail Tools - Competitor Pricing Analysis
# Generated: 2025-10-17 07:20:10 +1100
# Category: retail
# Description: This scenario handles requests to analyze local competitor pricing for specific product categories to inform markdown and pricing decisions. The agent retrieves current market prices from nearby stores to ensure competitive positioning while maintaining margin requirements.

module CARINA
  module Retail
    class CompetitorPricing
      
      # Original implementation refactored into class methods
              # Ruby code
        def self.get_competitor_pricing(params)
          category = params['category']
          location = params['store_location']
          radius = params['radius_miles'] || 3
          
          # Mock competitor data based on category
          competitors = {
            'organic_berries' => [
              { store: 'Whole Foods', distance: 1.2, price: 4.99, units: 'per 6oz container' },
              { store: 'Kroger', distance: 2.1, price: 3.79, units: 'per 6oz container' },
              { store: 'Safeway', distance: 2.8, price: 4.29, units: 'per 6oz container' }
            ],
            'leafy_greens' => [
              { store: 'Whole Foods', distance: 1.2, price: 2.99, units: 'per bunch' },
              { store: 'Kroger', distance: 2.1, price: 1.99, units: 'per bunch' },
              { store: 'Trader Joes', distance: 1.8, price: 2.49, units: 'per bunch' }
            ],
            'citrus_fruits' => [
              { store: 'Whole Foods', distance: 1.2, price: 1.89, units: 'per lb' },
              { store: 'Kroger', distance: 2.1, price: 1.49, units: 'per lb' },
              { store: 'Safeway', distance: 2.8, price: 1.69, units: 'per lb' }
            ]
          }
          
          data = competitors[category] || []
          filtered_data = data.select { |comp| comp[:distance] <= radius }
          
          {
            category: category,
            location: location,
            radius_searched: radius,
            competitors_found: filtered_data.length,
            pricing_data: filtered_data,
            average_price: filtered_data.empty? ? 0 : (filtered_data.sum { |c| c[:price] } / filtered_data.length).round(2),
            price_range: {
              min: filtered_data.empty? ? 0 : filtered_data.min_by { |c| c[:price] }[:price],
              max: filtered_data.empty? ? 0 : filtered_data.max_by { |c| c[:price] }[:price]
            },
            last_updated: Time.now.strftime('%Y-%m-%d %H:%M:%S')
          }
        end
        
        def self.analyze_price_positioning(params)
          product_id = params['product_id']
          current_price = params['current_price']
          competitor_data = params['competitor_data']
          margin_threshold = params['margin_threshold'] || 20
          
          avg_competitor_price = competitor_data['average_price'] || 0
          price_range = competitor_data['price_range'] || {}
          
          price_difference = current_price - avg_competitor_price
          percentage_difference = avg_competitor_price > 0 ? ((price_difference / avg_competitor_price) * 100).round(1) : 0
          
          positioning = if percentage_difference > 15
            'premium'
          elsif percentage_difference > 5
            'above_market'
          elsif percentage_difference > -5
            'competitive'
          elsif percentage_difference > -15
            'below_market'
          else
            'discount'
          end
          
          recommendations = []
          if positioning == 'premium' && percentage_difference > 25
            recommendations << 'Consider price reduction to maintain competitiveness'
          elsif positioning == 'discount' && percentage_difference < -20
            recommendations << 'Opportunity to increase price while remaining competitive'
          end
          
          {
            product_id: product_id,
            our_price: current_price,
            market_average: avg_competitor_price,
            price_difference: price_difference.round(2),
            percentage_vs_market: percentage_difference,
            positioning: positioning,
            competitive_range: price_range,
            recommendations: recommendations,
            analysis_timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S')
          }
        end
        
        def self.get_market_price_trends(params)
          category = params['category']
          location = params['store_location']
          days_back = params['days_back'] || 30
          include_seasonality = params['include_seasonality'].nil? ? true : params['include_seasonality']
          
          # Mock historical trend data
          base_prices = {
            'organic_berries' => 4.20,
            'leafy_greens' => 2.40,
            'citrus_fruits' => 1.60
          }
          
          base_price = base_prices[category] || 2.00
          
          # Generate mock trend data
          trend_data = []
          (0...days_back).each do |days_ago|
            date = (Date.today - days_ago).strftime('%Y-%m-%d')
            # Add some realistic price variation
            variation = (rand(-0.3..0.3) + Math.sin(days_ago * 0.1) * 0.1)
            price = (base_price + variation).round(2)
            trend_data << { date: date, average_price: price }
          end
          
          trend_data.reverse!
          
          recent_avg = trend_data.last(7).sum { |d| d[:average_price] } / 7
          older_avg = trend_data.first(7).sum { |d| d[:average_price] } / 7
          trend_direction = recent_avg > older_avg ? 'increasing' : 'decreasing'
          trend_strength = ((recent_avg - older_avg).abs / older_avg * 100).round(1)
          
          seasonality_factor = if include_seasonality
            month = Date.today.month
            case category
            when 'organic_berries'
              [4,5,6,7,8].include?(month) ? 'peak_season' : 'off_season'
            when 'citrus_fruits'
              [11,12,1,2,3].include?(month) ? 'peak_season' : 'off_season'
            else
              'neutral'
            end
          else
            nil
          end
          
          {
            category: category,
            location: location,
            period_analyzed: days_back,
            trend_direction: trend_direction,
            trend_strength_percent: trend_strength,
            current_market_average: recent_avg.round(2),
            period_start_average: older_avg.round(2),
            seasonality_factor: seasonality_factor,
            historical_data: trend_data,
            analysis_date: Date.today.strftime('%Y-%m-%d')
          }
        end
        
        def self.calculate_competitive_markdown(params)
          product_id = params['product_id']
          current_price = params['current_price']
          cost_basis = params['cost_basis']
          competitor_avg = params['competitor_avg_price']
          days_until_expiry = params['days_until_expiry']
          inventory_units = params['inventory_units']
          
          # Calculate urgency multiplier based on expiry
          urgency_multiplier = case days_until_expiry
          when 0..1
            0.4  # 60% markdown
          when 2..3
            0.25 # 25% markdown
          when 4..5
            0.15 # 15% markdown
          else
            0.05 # 5% markdown
          end
          
          # Calculate competitive position
          competitive_target = competitor_avg * 0.95  # Price 5% below market
          
          # Calculate minimum acceptable price (cost + 10% minimum margin)
          min_price = cost_basis * 1.1
          
          # Determine optimal markdown price
          markdown_price = [competitive_target, current_price * (1 - urgency_multiplier)].min
          markdown_price = [markdown_price, min_price].max  # Don't go below minimum
          
          markdown_percentage = ((current_price - markdown_price) / current_price * 100).round(1)
          projected_margin = ((markdown_price - cost_basis) / markdown_price * 100).round(1)
          
          # Calculate financial impact
          revenue_loss_per_unit = current_price - markdown_price
          total_revenue_impact = revenue_loss_per_unit * inventory_units
          
          # Determine recommendation
          recommendation = if days_until_expiry <= 2
            'immediate_markdown_required'
          elsif markdown_price <= min_price
            'minimum_price_reached'
          elsif markdown_percentage < 5
            'minimal_markdown_suggested'
          else
            'standard_markdown_recommended'
          end
          
          {
            product_id: product_id,
            current_price: current_price,
            recommended_markdown_price: markdown_price.round(2),
            markdown_percentage: markdown_percentage,
            competitor_benchmark: competitor_avg,
            projected_margin_percent: projected_margin,
            financial_impact: {
              revenue_loss_per_unit: revenue_loss_per_unit.round(2),
              total_inventory_impact: total_revenue_impact.round(2),
              units_affected: inventory_units
            },
            urgency_factors: {
              days_until_expiry: days_until_expiry,
              urgency_level: days_until_expiry <= 2 ? 'high' : days_until_expiry <= 5 ? 'medium' : 'low'
            },
            recommendation: recommendation,
            calculation_timestamp: Time.now.strftime('%Y-%m-%d %H:%M:%S')
          }
        end
      
    end
  end
end
