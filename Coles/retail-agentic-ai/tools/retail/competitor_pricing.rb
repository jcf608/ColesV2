# CARINA Retail Tools - Competitor Pricing Analysis
# Rationalized from: competitor-pricing_tools.rb
# Category: Retail Operations
# Description: Tools for monitoring and analyzing competitor pricing data

module CARINA
  module Retail
    class CompetitorPricing
      
      def self.get_competitor_pricing(params)
        # Extract and validate parameters
        product = params[:product]&.to_s&.strip
        competitors = params[:competitors] || []
        location = params[:location]&.to_s&.strip
        
        # Validate required parameters
        return { error: "Product name is required" } if product.nil? || product.empty?
        return { error: "Location is required" } if location.nil? || location.empty?
        
        # Default competitors if none provided
        competitors = ["Walmart", "Target", "Kroger", "Safeway", "Whole Foods"] if competitors.empty?
        
        begin
          # Mock competitor pricing data
          pricing_data = competitors.map do |competitor|
            base_price = case product.downcase
            when /milk/ then 3.49
            when /bread/ then 2.29
            when /eggs/ then 2.89
            when /banana/ then 0.68
            when /chicken/ then 5.99
            when /apple/ then 1.99
            else 4.99
            end
            
            # Add variation by competitor
            multiplier = case competitor.downcase
            when /walmart/ then 0.85
            when /target/ then 0.95
            when /kroger/ then 0.90
            when /safeway/ then 1.05
            when /whole foods/ then 1.25
            else 1.0
            end
            
            price = (base_price * multiplier).round(2)
            
            {
              competitor: competitor,
              price: price,
              unit: determine_unit(product),
              promotion: rand < 0.3 ? generate_promotion(price) : nil,
              stock_status: ["In Stock", "Limited Stock", "Out of Stock"].sample,
              last_updated: Time.now - rand(1..72) * 3600 # Random time within last 3 days
            }
          end
          
          # Calculate market statistics
          prices = pricing_data.map { |item| item[:price] }
          average_price = (prices.sum / prices.length.to_f).round(2)
          min_price = prices.min
          max_price = prices.max
          
          {
            success: true,
            product: product,
            location: location,
            market_analysis: {
              average_price: average_price,
              min_price: min_price,
              max_price: max_price,
              price_range: (max_price - min_price).round(2),
              market_position: determine_market_position(average_price, min_price, max_price)
            },
            competitor_data: pricing_data,
            recommendations: generate_pricing_recommendations(pricing_data, average_price),
            last_scan: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
            data_freshness: "Real-time simulation"
          }
          
        rescue StandardError => e
          {
            success: false,
            error: "Failed to retrieve competitor pricing: #{e.message}",
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      end
      
      def self.analyze_price_trends(params)
        product = params[:product]&.to_s&.strip
        period_days = params[:period_days]&.to_i || 30
        
        return { error: "Product name is required" } if product.nil? || product.empty?
        
        # Generate mock trend data
        trends = []
        (0...period_days).each do |days_ago|
          date = Date.today - days_ago
          base_price = case product.downcase
          when /milk/ then 3.49
          when /bread/ then 2.29
          else 4.99
          end
          
          # Add seasonal variation
          seasonal_factor = 1 + 0.1 * Math.sin(2 * Math::PI * days_ago / 365)
          # Add random daily variation
          daily_variation = 1 + (rand(-5..5) / 100.0)
          
          price = (base_price * seasonal_factor * daily_variation).round(2)
          
          trends << {
            date: date.strftime("%Y-%m-%d"),
            average_market_price: price,
            price_change: days_ago == 0 ? 0 : (price - trends.last[:average_market_price]).round(2)
          }
        end
        
        {
          success: true,
          product: product,
          period_days: period_days,
          trends: trends.reverse,
          summary: {
            current_price: trends.first[:average_market_price],
            period_start_price: trends.last[:average_market_price],
            total_change: (trends.first[:average_market_price] - trends.last[:average_market_price]).round(2),
            volatility: calculate_price_volatility(trends)
          }
        }
      end
      
      private
      
      def self.determine_unit(product)
        case product.downcase
        when /milk/ then "per gallon"
        when /bread/ then "per loaf"
        when /eggs/ then "per dozen"
        when /banana/, /apple/ then "per lb"
        when /chicken/ then "per lb"
        else "per item"
        end
      end
      
      def self.generate_promotion(price)
        discount_percent = [10, 15, 20, 25].sample
        discounted_price = (price * (1 - discount_percent / 100.0)).round(2)
        
        {
          type: ["BOGO", "Percentage Off", "Dollar Off", "Member Special"].sample,
          discount_percent: discount_percent,
          sale_price: discounted_price,
          valid_until: (Date.today + rand(1..14)).strftime("%Y-%m-%d")
        }
      end
      
      def self.determine_market_position(avg_price, min_price, max_price)
        range = max_price - min_price
        if avg_price <= min_price + (range * 0.33)
          "Low-End Market"
        elsif avg_price >= max_price - (range * 0.33)
          "Premium Market"
        else
          "Mid-Market"
        end
      end
      
      def self.generate_pricing_recommendations(pricing_data, avg_price)
        lowest_competitor = pricing_data.min_by { |item| item[:price] }
        highest_competitor = pricing_data.max_by { |item| item[:price] }
        
        recommendations = []
        
        if lowest_competitor[:price] < avg_price * 0.9
          recommendations << "Consider price matching with #{lowest_competitor[:competitor]} at $#{lowest_competitor[:price]}"
        end
        
        if pricing_data.count { |item| item[:promotion] } >= 2
          recommendations << "Multiple competitors running promotions - consider promotional response"
        end
        
        recommendations << "Monitor #{highest_competitor[:competitor]} for premium positioning opportunities"
        
        recommendations
      end
      
      def self.calculate_price_volatility(trends)
        prices = trends.map { |t| t[:average_market_price] }
        mean = prices.sum / prices.length.to_f
        variance = prices.sum { |p| (p - mean) ** 2 } / prices.length.to_f
        Math.sqrt(variance).round(3)
      end
      
    end
  end
end