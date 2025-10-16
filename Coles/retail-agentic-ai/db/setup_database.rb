#!/usr/bin/env ruby
# db/setup_database.rb

require 'sqlite3'

DB_PATH = File.join(__dir__, 'carina.db')

puts "Setting up Carina database..."

db = SQLite3::Database.new(DB_PATH)

schema = File.read(File.join(__dir__, 'schema.sql'))

db.execute_batch(schema)

puts "✓ Database created at #{DB_PATH}"
puts "✓ Tables created: actions, alerts, conversations, audit_log"

# Seed some sample data
db.execute(<<~SQL)
  INSERT INTO actions (id, title, description, priority, status, type, store_id)
  VALUES (
    'ACT001',
    '35% Markdown on Organic Strawberries',
    '24 units expiring tomorrow, slow sales velocity',
    'high',
    'pending',
    'price_change',
    'PAR001'
  )
SQL

db.execute(<<~SQL)
  INSERT INTO alerts (id, title, description, priority, status, source)
  VALUES (
    'ALT001',
    'Critical Priority Task Blocker',
    'Q4 Planning Review is blocked due to resource constraints',
    'critical',
    'active',
    'Task Monitor'
  )
SQL

puts "✓ Sample data seeded"
puts ""
puts "Database ready!"

db.close
