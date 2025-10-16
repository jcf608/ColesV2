# services/mode_router.rb
# Routes queries to appropriate mode based on intent analysis

require 'json'

class ModeRouter
  QUESTION_WORDS = %w[what why how when where which who whose whom]
  ACTION_WORDS = %w[do change update execute approve fix create delete add remove]
  ALERT_WORDS = %w[alert notification issue critical problem blocker]

  def self.route(message)
    message_lower = message.downcase
    
    # Check for explicit mode requests
    return :alert if message_lower.include?('alert') || message_lower.include?('notification')
    return :act if contains_action_intent?(message_lower)
    return :ask if contains_question_intent?(message_lower)
    
    # Default to ask mode
    :ask
  end

  def self.contains_question_intent?(message)
    QUESTION_WORDS.any? { |word| message.start_with?(word) }
  end

  def self.contains_action_intent?(message)
    ACTION_WORDS.any? { |word| message.include?(word) }
  end
end
