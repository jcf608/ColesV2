#!/usr/bin/env ruby
# Version: 3.0.0
puts "Version: 3.0.0"

# This script creates the ask_questions directory structure and sample questions

require 'fileutils'
require 'json'

# Create directory structure
base_dir = File.expand_path('../../ask_questions', __FILE__)
FileUtils.mkdir_p(base_dir)

# Sample question configurations
questions = [
  {
    id: 'items-at-risk',
    icon: '⚠️',
    label: 'Items at Risk',
    question: 'What products need attention today?',
    category: 'inventory',
    order: 1,
    enabled: true
  },
  {
    id: 'expiring-soon',
    icon: '📅',
    label: 'Expiring Soon',
    question: 'Show me products expiring in 2 days',
    category: 'inventory',
    order: 2,
    enabled: true
  },
  {
    id: 'competitor-pricing',
    icon: '💰',
    label: 'Competitor Pricing',
    question: 'What are competitor prices for berries?',
    category: 'pricing',
    order: 3,
    enabled: true
  },
  {
    id: 'policy-check',
    icon: '✅',
    label: 'Policy Check',
    question: 'Check pricing policy for 30% markdown',
    category: 'policy',
    order: 4,
    enabled: true
  }
]

# Write individual question files
questions.each do |q|
  filename = File.join(base_dir, "#{q[:id]}.json")
  File.write(filename, JSON.pretty_generate(q))
  puts "Created: #{filename}"
end

puts "\nCreated #{questions.length} question configuration files in #{base_dir}"
