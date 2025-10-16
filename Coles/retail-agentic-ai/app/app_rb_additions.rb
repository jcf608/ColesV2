#!/usr/bin/env ruby
# Additions to app.rb for question asset generation

class ProduceOptimizationApp < Sinatra::Base
  # ... existing code ...
  
  # ============================================
  # QUESTION ASSET GENERATION
  # ============================================
  
  def self.generate_question_assets(question_id = nil)
    generator = QuestionAssetGenerator.new
    
    if question_id
      generator.generate_for_question_id(question_id)
    else
      generator.generate_all
    end
  end
  
  # Add this route to handle asset generation via API
  post '/api/save-scenario' do
    content_type :json
    
    begin
      config = JSON.parse(request.body.read)
      
      # Generate question ID from scenario name
      question_id = config['scenario_name']
        .downcase
        .gsub(/[^a-z0-9\s-]/, '')
        .gsub(/\s+/, '-')
      
      # Create the question JSON file
      question_file_path = File.join(
        File.expand_path('../../ask_questions', __FILE__),
        "#{question_id}.json"
      )
      
      question_data = {
        'id' => question_id,
        'icon' => config['button_icon'],
        'label' => config['button_label'],
        'question' => config['button_question'],
        'category' => 'custom',
        'order' => 100,
        'enabled' => true
      }
      
      File.write(question_file_path, JSON.pretty_generate(question_data))
      
      # Generate all assets
      generator = QuestionAssetGenerator.new
      files_created = generate_scenario_files(generator, question_id, config)
      
      json({
        success: true,
        question_id: question_id,
        files_created: files_created
      })
      
    rescue => e
      status 500
      json({
        success: false,
        error: e.message,
        backtrace: e.backtrace[0..3]
      })
    end
  end
  
  private
  
  def self.generate_scenario_files(generator, question_id, config)
    files = []
    base_dir = File.expand_path('../..', __FILE__)
    
    # System prompt
    prompt_path = File.join(base_dir, 'prompts', 'scenarios', "#{question_id}.txt")
    File.write(prompt_path, config['system_prompt'])
    files << "prompts/scenarios/#{question_id}.txt"
    
    # Policy text
    policy_text_path = File.join(base_dir, 'policies', "#{question_id}.txt")
    File.write(policy_text_path, config['policy_text'])
    files << "policies/#{question_id}.txt"
    
    # Policy JSON
    policy_json_path = File.join(base_dir, 'policies', "#{question_id}.json")
    policy_data = JSON.parse(config['policy_json'])
    File.write(policy_json_path, JSON.pretty_generate(policy_data))
    files << "policies/#{question_id}.json"
    
    # Example dialog
    example_path = File.join(base_dir, 'examples', "#{question_id}.txt")
    File.write(example_path, config['example_dialog'])
    files << "examples/#{question_id}.txt"
    
    # Tool config
    tool_config_path = File.join(base_dir, 'config', 'tools', "#{question_id}_tools.json")
    tool_config = JSON.parse(config['tool_definitions'])
    File.write(tool_config_path, JSON.pretty_generate(tool_config))
    files << "config/tools/#{question_id}_tools.json"
    
    # Tool implementation
    tool_impl_path = File.join(base_dir, 'tools', "#{question_id}_tools.rb")
    File.write(tool_impl_path, config['tool_implementation'])
    files << "tools/#{question_id}_tools.rb"
    
    # Question JSON
    files << "ask_questions/#{question_id}.json"
    
    files
  end
end

# QuestionAssetGenerator class (can be in separate file: lib/question_asset_generator.rb)
class QuestionAssetGenerator
  BASE_DIR = File.expand_path('..', __dir__)
  QUESTIONS_DIR = File.join(BASE_DIR, 'ask_questions')
  PROMPTS_DIR = File.join(BASE_DIR, 'prompts', 'scenarios')
  POLICIES_DIR = File.join(BASE_DIR, 'policies')
  EXAMPLES_DIR = File.join(BASE_DIR, 'examples')
  TOOLS_CONFIG_DIR = File.join(BASE_DIR, 'config', 'tools')
  TOOLS_IMPL_DIR = File.join(BASE_DIR, 'tools')
  
  def initialize
    ensure_directories_exist
  end
  
  def generate_all
    puts "🔍 Scanning for questions in: #{QUESTIONS_DIR}"
    
    unless Dir.exist?(QUESTIONS_DIR)
      puts "❌ Questions directory not found: #{QUESTIONS_DIR}"
      return
    end
    
    questions = load_questions
    
    if questions.empty?
      puts "⚠️  No enabled questions found"
      return
    end
    
    puts "📋 Found #{questions.length} enabled question(s)"
    
    questions.each do |question|
      generate_assets_for_question(question)
    end
    
    puts "\n✅ Asset generation complete"
  end
  
  def generate_for_question_id(question_id)
    question_file = File.join(QUESTIONS_DIR, "#{question_id}.json")
    
    unless File.exist?(question_file)
      puts "❌ Question file not found: #{question_file}"
      return false
    end
    
    question = JSON.parse(File.read(question_file))
    
    unless question['enabled']
      puts "⚠️  Question '#{question_id}' is disabled"
      return false
    end
    
    generate_assets_for_question(question)
    true
  end
  
  private
  
  def ensure_directories_exist
    [PROMPTS_DIR, POLICIES_DIR, EXAMPLES_DIR, TOOLS_CONFIG_DIR, TOOLS_IMPL_DIR].each do |dir|
      FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
    end
  end
  
  def load_questions
    questions = []
    
    Dir.glob(File.join(QUESTIONS_DIR, '*.json')).each do |file|
      begin
        question = JSON.parse(File.read(file))
        questions << question if question['enabled']
      rescue => e
        puts "⚠️  Warning: Could not load #{File.basename(file)}: #{e.message}"
      end
    end
    
    questions.sort_by { |q| q['order'] || 999 }
  end
  
  def generate_assets_for_question(question)
    id = question['id']
    puts "\n📝 Generating assets for: #{question['label']} (#{id})"
    
    create_system_prompt(id, question)
    create_policy_files(id, question)
    create_example_dialog(id, question)
    create_tool_config(id, question)
    create_tool_implementation(id, question)
  end
  
  # ... rest of the generator methods from the standalone script ...
end
