# CARINA Operations Tools - Staff Shortfall Analysis
# Rationalized from: impact-of-staff-shortfall_tools.rb
# Category: Operations Management  
# Description: Tools for analyzing the impact of staff shortages on operations

module CARINA
  module Operations
    class StaffShortfallAnalysis
      
      def self.analyze_staff_shortfall_impact(params)
        department = params[:department]&.to_s
        shortfall_percentage = params[:shortfall_percentage]&.to_f || 0
        peak_hours = params[:peak_hours] || []
        
        return { error: "Department is required" } if department.nil? || department.empty?
        return { error: "Shortfall percentage must be between 0 and 100" } unless (0..100).include?(shortfall_percentage)
        
        begin
          # Calculate operational impact
          impact_metrics = calculate_operational_impact(department, shortfall_percentage, peak_hours)
          
          # Generate mitigation strategies
          mitigation_strategies = generate_mitigation_strategies(department, shortfall_percentage)
          
          # Calculate customer experience impact
          customer_impact = calculate_customer_impact(department, shortfall_percentage)
          
          {
            success: true,
            department: department,
            shortfall_percentage: shortfall_percentage,
            impact_assessment: {
              operational_impact: impact_metrics,
              customer_experience: customer_impact,
              financial_impact: calculate_financial_impact(department, shortfall_percentage),
              service_level_impact: calculate_service_impact(department, shortfall_percentage)
            },
            mitigation_strategies: mitigation_strategies,
            recommendations: generate_recommendations(department, shortfall_percentage, impact_metrics),
            priority_level: determine_priority_level(shortfall_percentage, impact_metrics),
            analysis_timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }
          
        rescue StandardError => e
          {
            success: false,
            error: "Failed to analyze staff shortfall impact: #{e.message}",
            timestamp: Time.now.strftime("%Y-%m-%d %H:%M:%S")
          }
        end
      end
      
      def self.get_staffing_alternatives(params)
        department = params[:department]&.to_s
        required_hours = params[:required_hours]&.to_i || 40
        skills_required = params[:skills_required] || []
        
        return { error: "Department is required" } if department.nil? || department.empty?
        
        # Generate alternative staffing options
        alternatives = [
          {
            type: "Temporary Staff",
            availability: "2-4 hours lead time",
            cost_multiplier: 1.2,
            skills_match: calculate_skills_match(skills_required, get_temp_staff_skills),
            capacity_hours: required_hours * 0.8
          },
          {
            type: "Cross-trained Staff",
            availability: "Immediate",
            cost_multiplier: 1.0,
            skills_match: calculate_skills_match(skills_required, get_cross_trained_skills(department)),
            capacity_hours: required_hours * 0.6
          },
          {
            type: "Overtime Current Staff",
            availability: "Subject to availability",
            cost_multiplier: 1.5,
            skills_match: 100,
            capacity_hours: required_hours * 0.4
          },
          {
            type: "External Contractor",
            availability: "4-8 hours lead time",
            cost_multiplier: 1.8,
            skills_match: 95,
            capacity_hours: required_hours
          }
        ]
        
        {
          success: true,
          department: department,
          required_hours: required_hours,
          skills_required: skills_required,
          alternatives: alternatives,
          recommendations: rank_alternatives(alternatives, required_hours),
          estimated_resolution_time: calculate_resolution_time(alternatives)
        }
      end
      
      def self.calculate_customer_queue_impact(params)
        department = params[:department]&.to_s
        shortfall_percentage = params[:shortfall_percentage]&.to_f || 0
        current_queue_time = params[:current_queue_time]&.to_f || 5.0
        
        # Calculate queue time increase based on staffing model
        queue_multiplier = case shortfall_percentage
        when 0..10 then 1.1
        when 11..25 then 1.3
        when 26..40 then 1.8
        when 41..60 then 2.5
        else 3.5
        end
        
        projected_queue_time = current_queue_time * queue_multiplier
        customer_satisfaction_impact = calculate_satisfaction_impact(projected_queue_time)
        
        {
          success: true,
          department: department,
          shortfall_percentage: shortfall_percentage,
          queue_analysis: {
            current_average_wait: current_queue_time,
            projected_average_wait: projected_queue_time.round(1),
            increase_percentage: ((projected_queue_time / current_queue_time - 1) * 100).round(1),
            customer_satisfaction_impact: customer_satisfaction_impact
          },
          thresholds: {
            acceptable_wait_time: 8.0,
            poor_service_threshold: 15.0,
            critical_threshold: 25.0
          },
          recommendations: generate_queue_recommendations(projected_queue_time, department)
        }
      end
      
      private
      
      def self.calculate_operational_impact(department, shortfall_percentage, peak_hours)
        base_impact = {
          productivity_reduction: shortfall_percentage * 0.8,
          service_speed_reduction: shortfall_percentage * 0.9,
          error_rate_increase: shortfall_percentage * 0.3,
          overtime_requirement: shortfall_percentage * 1.2
        }
        
        # Adjust for peak hours impact
        if peak_hours.any?
          peak_multiplier = 1.4
          base_impact.transform_values { |v| v * peak_multiplier }
        end
        
        base_impact
      end
      
      def self.calculate_customer_impact(department, shortfall_percentage)
        {
          wait_time_increase: shortfall_percentage * 1.2,
          service_quality_reduction: shortfall_percentage * 0.7,
          customer_satisfaction_impact: calculate_satisfaction_impact(shortfall_percentage),
          likelihood_of_complaints: shortfall_percentage > 20 ? "High" : shortfall_percentage > 10 ? "Medium" : "Low"
        }
      end
      
      def self.calculate_financial_impact(department, shortfall_percentage)
        base_hourly_cost = get_department_hourly_cost(department)
        
        {
          overtime_costs: (shortfall_percentage * base_hourly_cost * 0.5).round(2),
          lost_productivity_value: (shortfall_percentage * base_hourly_cost * 2).round(2),
          potential_revenue_loss: (shortfall_percentage * 150).round(2),
          temporary_staff_premium: (shortfall_percentage * base_hourly_cost * 0.2).round(2)
        }
      end
      
      def self.calculate_service_impact(department, shortfall_percentage)
        {
          service_level_reduction: "#{(shortfall_percentage * 0.8).round(1)}%",
          compliance_risk: shortfall_percentage > 30 ? "High" : shortfall_percentage > 15 ? "Medium" : "Low",
          safety_impact: shortfall_percentage > 40 ? "Increased Risk" : "Minimal Impact"
        }
      end
      
      def self.generate_mitigation_strategies(department, shortfall_percentage)
        strategies = []
        
        if shortfall_percentage < 15
          strategies << "Redistribute tasks among existing staff"
          strategies << "Defer non-critical activities"
        elsif shortfall_percentage < 30
          strategies << "Implement cross-training for immediate coverage"
          strategies << "Consider temporary staff augmentation"
          strategies << "Prioritize critical functions only"
        else
          strategies << "Activate emergency staffing protocols"
          strategies << "Engage temporary staffing agency"
          strategies << "Consider service level adjustments"
          strategies << "Implement customer communication strategy"
        end
        
        strategies
      end
      
      def self.generate_recommendations(department, shortfall_percentage, impact_metrics)
        recommendations = []
        
        if impact_metrics[:productivity_reduction] > 25
          recommendations << "Immediate action required: Activate backup staffing plan"
        end
        
        if shortfall_percentage > 20
          recommendations << "Consider adjusting service hours or offerings temporarily"
          recommendations << "Implement customer communication about potential delays"
        end
        
        recommendations << "Monitor situation hourly and adjust strategies as needed"
        recommendations << "Document lessons learned for future contingency planning"
        
        recommendations
      end
      
      def self.determine_priority_level(shortfall_percentage, impact_metrics)
        if shortfall_percentage > 30 || impact_metrics[:productivity_reduction] > 35
          "CRITICAL"
        elsif shortfall_percentage > 15 || impact_metrics[:productivity_reduction] > 20
          "HIGH" 
        elsif shortfall_percentage > 5
          "MEDIUM"
        else
          "LOW"
        end
      end
      
      def self.calculate_skills_match(required_skills, available_skills)
        return 0 if required_skills.empty? || available_skills.empty?
        
        matches = (required_skills & available_skills).length
        (matches.to_f / required_skills.length * 100).round(1)
      end
      
      def self.get_temp_staff_skills
        ["Customer Service", "Basic POS", "Cleaning", "Stocking"]
      end
      
      def self.get_cross_trained_skills(department)
        case department.downcase
        when /checkout/ then ["POS Systems", "Customer Service", "Basic Troubleshooting"]
        when /produce/ then ["Product Knowledge", "Display Setup", "Inventory Management"]
        when /deli/ then ["Food Safety", "Customer Service", "Product Preparation"]
        else ["Customer Service", "Basic Operations"]
        end
      end
      
      def self.rank_alternatives(alternatives, required_hours)
        alternatives.sort_by do |alt|
          # Score based on cost, availability, and capacity match
          cost_score = 1 / alt[:cost_multiplier]
          capacity_score = alt[:capacity_hours] / required_hours.to_f
          availability_score = alt[:availability].include?("Immediate") ? 1 : 0.5
          
          -(cost_score * 0.3 + capacity_score * 0.4 + availability_score * 0.3)
        end
      end
      
      def self.calculate_resolution_time(alternatives)
        best_alternative = alternatives.min_by { |alt| alt[:cost_multiplier] }
        case best_alternative[:availability]
        when /Immediate/ then "0-1 hours"
        when /2-4 hours/ then "2-4 hours"
        when /4-8 hours/ then "4-8 hours"
        else "8+ hours"
        end
      end
      
      def self.calculate_satisfaction_impact(wait_time_or_shortfall)
        case wait_time_or_shortfall
        when 0..10 then "Minimal Impact"
        when 11..20 then "Noticeable Impact"
        when 21..35 then "Significant Impact"
        else "Severe Impact"
        end
      end
      
      def self.get_department_hourly_cost(department)
        costs = {
          'checkout' => 25.0,
          'produce' => 28.0,
          'deli' => 32.0,
          'bakery' => 30.0,
          'customer_service' => 27.0
        }
        costs[department.downcase] || 26.0
      end
      
      def self.generate_queue_recommendations(projected_queue_time, department)
        recommendations = []
        
        if projected_queue_time > 15
          recommendations << "Open additional checkout lanes immediately"
          recommendations << "Deploy mobile POS systems if available"
          recommendations << "Implement express lane protocols"
        elsif projected_queue_time > 8
          recommendations << "Consider opening additional service points"
          recommendations << "Deploy staff to assist with queue management"
        end
        
        recommendations << "Provide regular customer updates about wait times"
        recommendations << "Consider priority service for elderly/disabled customers"
        
        recommendations
      end
      
    end
  end
end