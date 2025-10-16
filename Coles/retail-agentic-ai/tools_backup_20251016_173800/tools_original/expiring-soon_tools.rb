# Tool implementations for: Expiring Soon
# Generated: 2025-10-16 14:50:22 +1100

# Get products that are expiring within a specified timeframe
def get_expiring_products(params)
  begin
    # Extract and validate parameters
    days_ahead = params[:days_ahead] || 7
    store_id = params[:store_id]
    category = params[:category] # optional filter
    
    # Validate required parameters
    raise ArgumentError, "store_id is required" if store_id.nil? || store_id.empty?
    raise ArgumentError, "days_ahead must be a positive number" if days_ahead.to_i <= 0
    
    # Mock data - products expiring soon
    expiring_products = [
      {
        product_id: "PRD-001",
        name: "Organic Whole Milk",
        sku: "MILK-ORG-001",
        category: "dairy",
        expiry_date: (Date.today + 2).strftime("%Y-%m-%d"),
        current_stock: 12,
        original_price: 4.99,
        location: "Cooler Section A-3",
        supplier: "Green Valley Dairy",
        days_until_expiry: 2
      },
      {
        product_id: "PRD-045",
        name: "Fresh Strawberries",
        sku: "BERRY-STR-045",
        category: "produce",
        expiry_date: (Date.today + 1).strftime("%Y-%m-%d"),
        current_stock: 8,
        original_price: 3.49,
        location: "Produce Section B-1",
        supplier: "Sunshine Farms",
        days_until_expiry: 1
      },
      {
        product_id: "PRD-078",
        name: "Sourdough Bread",
        sku: "BREAD-SOUR-078",
        category: "bakery",
        expiry_date: (Date.today + 3).strftime("%Y-%m-%d"),
        current_stock: 15,
        original_price: 2.99,
        location: "Bakery Section C-2",
        supplier: "Artisan Bakery Co",
        days_until_expiry: 3
      },
      {
        product_id: "PRD-134",
        name: "Greek Yogurt 32oz",
        sku: "YOG-GRK-134",
        category: "dairy",
        expiry_date: (Date.today + 4).strftime("%Y-%m-%d"),
        current_stock: 24,
        original_price: 5.99,
        location: "Cooler Section A-5",
        supplier: "Mediterranean Foods",
        days_until_expiry: 4
      },
      {
        product_id: "PRD-189",
        name: "Baby Spinach",
        sku: "SPIN-BBY-189",
        category: "produce",
        expiry_date: (Date.today + 2).strftime("%Y-%m-%d"),
        current_stock: 6,
        original_price: 2.79,
        location: "Produce Section B-4",
        supplier: "Fresh Greens Inc",
        days_until_expiry: 2
      }
    ]
    
    # Filter by category if specified
    if category
      expiring_products = expiring_products.select { |product| product[:category] == category.downcase }
    end
    
    # Filter by days ahead
    expiring_products = expiring_products.select { |product| product[:days_until_expiry] <= days_ahead.to_i }
    
    # Calculate total value at risk
    total_value_at_risk = expiring_products.sum { |product| product[:current_stock] * product[:original_price] }
    
    {
      status: "success",
      store_id: store_id,
      days_ahead: days_ahead.to_i,
      category_filter: category,
      total_products: expiring_products.length,
      total_value_at_risk: total_value_at_risk.round(2),
      products: expiring_products,
      generated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
  rescue ArgumentError => e
    {
      status: "error",
      error_type: "validation_error",
      message: e.message
    }
  rescue => e
    {
      status: "error",
      error_type: "system_error",
      message: "Failed to retrieve expiring products: #{e.message}"
    }
  end
end

# Get detailed expiry information for a specific product
def get_product_expiry_details(params)
  begin
    # Extract and validate parameters
    product_id = params[:product_id]
    sku = params[:sku]
    
    # Validate that at least one identifier is provided
    raise ArgumentError, "Either product_id or sku must be provided" if product_id.nil? && sku.nil?
    
    # Mock detailed product expiry data
    product_details = {
      product_id: product_id || "PRD-045",
      name: "Fresh Strawberries",
      sku: sku || "BERRY-STR-045",
      category: "produce",
      current_expiry_date: (Date.today + 1).strftime("%Y-%m-%d"),
      days_until_expiry: 1,
      current_stock: 8,
      original_price: 3.49,
      location: "Produce Section B-1",
      supplier: "Sunshine Farms",
      batch_info: {
        batch_number: "SF-2024-0315",
        received_date: (Date.today - 3).strftime("%Y-%m-%d"),
        expected_shelf_life: 4
      },
      expiry_history: [
        {
          date: (Date.today - 10).strftime("%Y-%m-%d"),
          action: "received",
          quantity: 20,
          expiry_date: (Date.today + 1).strftime("%Y-%m-%d")
        },
        {
          date: (Date.today - 8).strftime("%Y-%m-%d"),
          action: "sold",
          quantity: 7,
          remaining: 13
        },
        {
          date: (Date.today - 5).strftime("%Y-%m-%d"),
          action: "damaged",
          quantity: 5,
          reason: "overripe",
          remaining: 8
        }
      ],
      disposal_recommendations: [
        {
          option: "markdown_sale",
          recommended_price: 1.99,
          potential_revenue: 15.92,
          urgency: "high"
        },
        {
          option: "staff_purchase",
          discount_percent: 50,
          potential_revenue: 13.96,
          urgency: "medium"
        },
        {
          option: "donation",
          partner: "Local Food Bank",
          tax_benefit: 27.92,
          urgency: "low"
        }
      ],
      storage_conditions: {
        temperature: "35-40°F",
        humidity: "90-95%",
        current_temp: 38,
        current_humidity: 92,
        conditions_optimal: true
      }
    }
    
    {
      status: "success",
      product: product_details,
      generated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
  rescue ArgumentError => e
    {
      status: "error",
      error_type: "validation_error",
      message: e.message
    }
  rescue => e
    {
      status: "error",
      error_type: "system_error",
      message: "Failed to retrieve product expiry details: #{e.message}"
    }
  end
end

# Get inventory alerts related to product expiration
def get_inventory_alerts(params)
  begin
    # Extract and validate parameters
    store_id = params[:store_id]
    alert_type = params[:alert_type] || "all" # expiring, expired, critical
    priority = params[:priority] # high, medium, low - optional filter
    
    # Validate required parameters
    raise ArgumentError, "store_id is required" if store_id.nil? || store_id.empty?
    
    # Mock inventory alerts data
    alerts = [
      {
        alert_id: "ALR-001",
        type: "expiring",
        priority: "high",
        product_id: "PRD-045",
        product_name: "Fresh Strawberries",
        sku: "BERRY-STR-045",
        message: "8 units expiring tomorrow - immediate action required",
        days_until_expiry: 1,
        current_stock: 8,
        estimated_loss: 27.92,
        created_at: Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        suggested_actions: ["Apply 40% markdown", "Move to prominent display", "Notify staff"]
      },
      {
        alert_id: "ALR-002",
        type: "critical",
        priority: "high",
        product_id: "PRD-201",
        product_name: "Pre-made Sushi Rolls",
        sku: "SUSHI-MIX-201",
        message: "6 units expire today - dispose or donate immediately",
        days_until_expiry: 0,
        current_stock: 6,
        estimated_loss: 71.94,
        created_at: (Time.now - 3600).strftime("%Y-%m-%d %H:%M:%S"),
        suggested_actions: ["Remove from shelves", "Contact donation partner", "Document disposal"]
      },
      {
        alert_id: "ALR-003",
        type: "expiring",
        priority: "medium",
        product_id: "PRD-001",
        product_name: "Organic Whole Milk",
        sku: "MILK-ORG-001",
        message: "12 units expiring in 2 days",
        days_until_expiry: 2,
        current_stock: 12,
        estimated_loss: 59.88,
        created_at: (Time.now - 1800).strftime("%Y-%m-%d %H:%M:%S"),
        suggested_actions: ["Apply 25% markdown", "Feature in weekly specials", "Staff notification"]
      },
      {
        alert_id: "ALR-004",
        type: "pattern",
        priority: "medium",
        product_id: "PRD-156",
        product_name: "Artisan Cheese Wheel",
        sku: "CHSE-ART-156",
        message: "Consistent waste pattern detected - review ordering",
        days_until_expiry: 5,
        current_stock: 3,
        estimated_loss: 89.97,
        created_at: (Time.now - 900).strftime("%Y-%m-%d %H:%M:%S"),
        suggested_actions: ["Reduce order quantity", "Analyze sales data", "Consider alternative suppliers"]
      },
      {
        alert_id: "ALR-005",
        type: "temperature",
        priority: "high",
        product_id: "PRD-089",
        product_name: "Fresh Salmon Fillets",
        sku: "FISH-SAL-089",
        message: "Temperature variance detected - may affect shelf life",
        days_until_expiry: 1,
        current_stock: 4,
        estimated_loss: 63.96,
        created_at: (Time.now - 600).strftime("%Y-%m-%d %H:%M:%S"),
        suggested_actions: ["Check refrigeration unit", "Inspect product quality", "Expedite sales"]
      }
    ]
    
    # Filter by alert type if not 'all'
    if alert_type != "all"
      alerts = alerts.select { |alert| alert[:type] == alert_type }
    end
    
    # Filter by priority if specified
    if priority
      alerts = alerts.select { |alert| alert[:priority] == priority }
    end
    
    # Sort by priority (high first) and creation time (newest first)
    priority_order = { "high" => 1, "medium" => 2, "low" => 3 }
    alerts = alerts.sort_by { |alert| [priority_order[alert[:priority]], -Time.parse(alert[:created_at]).to_i] }
    
    # Calculate summary statistics
    total_estimated_loss = alerts.sum { |alert| alert[:estimated_loss] }
    high_priority_count = alerts.count { |alert| alert[:priority] == "high" }
    
    {
      status: "success",
      store_id: store_id,
      alert_type_filter: alert_type,
      priority_filter: priority,
      total_alerts: alerts.length,
      high_priority_alerts: high_priority_count,
      total_estimated_loss: total_estimated_loss.round(2),
      alerts: alerts,
      summary: {
        expiring_products: alerts.count { |alert| alert[:type] == "expiring" },
        critical_alerts: alerts.count { |alert| alert[:type] == "critical" },
        pattern_alerts: alerts.count { |alert| alert[:type] == "pattern" },
        temperature_alerts: alerts.count { |alert| alert[:type] == "temperature" }
      },
      generated_at: Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }
    
  rescue ArgumentError => e
    {
      status: "error",
      error_type: "validation_error",
      message: e.message
    }
  rescue => e
    {
      status: "error",
      error_type: "system_error",
      message: "Failed to retrieve inventory alerts: #{e.message}"
    }
  end
end