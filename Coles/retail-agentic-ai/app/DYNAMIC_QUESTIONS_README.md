# Dynamic Ask Questions System

## Overview

The Ask page now dynamically loads question buttons from JSON configuration files. This allows new questions to be added without modifying code.

## Directory Structure

```
ask_questions/
├── items-at-risk.json
├── expiring-soon.json
├── competitor-pricing.json
└── policy-check.json
```

## Question Configuration Format

Each question is a JSON file with the following structure:

```json
{
  "id": "items-at-risk",
  "icon": "⚠️",
  "label": "Items at Risk",
  "question": "What products need attention today?",
  "category": "inventory",
  "order": 1,
  "enabled": true
}
```

### Fields

- **id**: Unique identifier (slug format, used for filename)
- **icon**: Emoji or icon to display
- **label**: Short display text for the button
- **question**: Full question text that will be sent to the agent
- **category**: Grouping category (inventory, pricing, policy, custom)
- **order**: Sort order (lower numbers appear first)
- **enabled**: Boolean to show/hide the question

## Setup

1. Run the setup script to create initial questions:
   ```bash
   ruby create_ask_questions.rb
   ```

2. This creates the `ask_questions/` directory with sample questions

## Adding New Questions

### Option 1: Manual Creation

Create a new JSON file in `ask_questions/`:

```json
{
  "id": "waste-analysis",
  "icon": "📊",
  "label": "Waste Analysis",
  "question": "Show me waste trends for the past week",
  "category": "analytics",
  "order": 5,
  "enabled": true
}
```

### Option 2: Via Scenario Wizard

When you use the `/add_agent_question` wizard, it automatically:
1. Creates the ask question JSON file
2. Updates the system prompt
3. Creates policy files
4. Generates tool implementations
5. Adds the question to the Ask page

## How It Works

### Routes (routes.rb)

New API endpoint:
```ruby
app.get '/api/ask-questions' do
  content_type :json
  questions = load_ask_questions
  json({ success: true, questions: questions })
end
```

### Helper Method (app.rb)

```ruby
def load_ask_questions
  questions = []
  questions_dir = File.expand_path('../../ask_questions', __FILE__)
  
  if Dir.exist?(questions_dir)
    Dir.glob(File.join(questions_dir, '*.json')).each do |question_file|
      begin
        question = JSON.parse(File.read(question_file))
        questions << question if question['enabled']
      rescue => e
        puts "Warning: Could not load question file #{question_file}: #{e.message}"
      end
    end
  end
  
  questions.sort_by { |q| q['order'] || 999 }
end
```

### Ask Page (ask.erb)

The Ask page loads questions dynamically on page load:

```javascript
async function loadQuestions() {
  const response = await fetch('/api/ask-questions');
  const data = await response.json();
  
  if (data.success && data.questions.length > 0) {
    data.questions.forEach(q => {
      // Create button for each question
    });
  }
}
```

### Main Page (index.erb)

Quick actions also load dynamically (limited to first 6):

```javascript
async function loadQuickActions() {
  const response = await fetch('/api/ask-questions');
  const data = await response.json();
  
  data.questions.slice(0, 6).forEach(q => {
    // Create quick action button
  });
}
```

## Question Flow

1. User clicks question on Ask page
2. Question is stored in sessionStorage
3. User is redirected to main page (/)
4. Main page checks sessionStorage
5. If pending question found, it's automatically submitted
6. Chat interface displays the conversation

## Benefits

- **No code changes needed** to add new questions
- **Easy to enable/disable** questions via the `enabled` flag
- **Flexible ordering** via the `order` field
- **Categorization** for future filtering/grouping
- **Automatic integration** with scenario wizard
- **Consistent UX** across Ask and main pages

## File Updates Made

1. **routes.rb**: Added `/api/ask-questions` endpoint
2. **app.rb**: Added `load_ask_questions()` helper method
3. **ask.erb**: Dynamic question loading interface
4. **index.erb**: Quick actions load dynamically + sessionStorage check
5. **create_ask_questions.rb**: Setup script for initial questions

## Example: Adding a New Question

Create `ask_questions/staffing-forecast.json`:

```json
{
  "id": "staffing-forecast",
  "icon": "👥",
  "label": "Staffing Needs",
  "question": "Which stores need additional staff this weekend?",
  "category": "staffing",
  "order": 10,
  "enabled": true
}
```

The question will automatically appear on the Ask page on next reload!

## Disabling a Question

Set `enabled: false` in the JSON file:

```json
{
  "id": "old-question",
  "enabled": false,
  ...
}
```

Or simply delete the JSON file.
