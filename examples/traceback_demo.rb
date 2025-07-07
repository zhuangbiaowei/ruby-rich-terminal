#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "=== Rich Ruby Traceback Demo ===\n"

# Include helper methods
include Rich::TracebackHelpers

# Example 1: Simple exception with rich traceback
puts "1. Simple Exception with Rich Traceback:"

def divide_numbers(a, b)
  puts "Dividing #{a} by #{b}"
  result = a / b
  puts "Result: #{result}"
  result
end

def calculate_average(numbers)
  sum = numbers.sum
  count = numbers.length
  divide_numbers(sum, count)
end

def process_data(data)
  puts "Processing data: #{data}"
  calculate_average(data)
end

begin
  # This will cause a division by zero error
  process_data([])
rescue => e
  print_exception(e)
end

puts "\n" + "─" * 60 + "\n"

# Example 2: Custom exception with detailed traceback
puts "2. Custom Exception with Detailed Context:"

class CustomError < StandardError
  def initialize(message, details = {})
    super(message)
    @details = details
  end
  
  attr_reader :details
end

def validate_user_input(input)
  if input.nil?
    raise CustomError.new("Input cannot be nil", { expected: "String", received: "nil" })
  end
  
  if input.empty?
    raise CustomError.new("Input cannot be empty", { expected: "non-empty string", received: "empty string" })
  end
  
  input.upcase
end

def process_user_request(request)
  user_input = request[:data]
  validate_user_input(user_input)
end

def handle_web_request(params)
  puts "Handling web request..."
  process_user_request(params)
end

begin
  handle_web_request({ data: "" })
rescue => e
  traceback = Rich::Traceback.new(exception: e, extra_lines: 2)
  console = Rich::Console.new(stderr: true)
  console.print(traceback)
end

puts "\n" + "─" * 60 + "\n"

# Example 3: NoMethodError with traceback
puts "3. NoMethodError Example:"

class Person
  def initialize(name)
    @name = name
  end
  
  def greet
    puts "Hello, I'm #{@name}"
  end
end

def create_person(name)
  person = Person.new(name)
  person.greet
  person
end

def setup_people(names)
  people = names.map { |name| create_person(name) }
  
  # This will cause an error - trying to call undefined method
  people.first.say_goodbye
end

begin
  setup_people(["Alice", "Bob"])
rescue => e
  print_exception(e, extra_lines: 1)
end

puts "\n" + "─" * 60 + "\n"

# Example 4: File operation error
puts "4. File Operation Error:"

def read_config_file(filename)
  puts "Attempting to read #{filename}"
  File.read(filename)
end

def parse_config(filename)
  content = read_config_file(filename)
  JSON.parse(content)
end

def load_application_config
  config_file = "non_existent_config.json"
  parse_config(config_file)
end

begin
  load_application_config
rescue => e
  # Show with more context lines
  print_exception(e, extra_lines: 3, width: 120)
end

puts "\n" + "─" * 60 + "\n"

# Example 5: Nested exception handling
puts "5. Nested Exception Handling:"

def deep_function_level_4
  raise RuntimeError, "Something went wrong at the deepest level"
end

def deep_function_level_3
  puts "Level 3: Calling level 4"
  deep_function_level_4
end

def deep_function_level_2
  puts "Level 2: Calling level 3"
  deep_function_level_3
end

def deep_function_level_1
  puts "Level 1: Calling level 2"
  deep_function_level_2
end

def start_deep_operation
  puts "Starting deep operation..."
  deep_function_level_1
end

begin
  start_deep_operation
rescue => e
  # Show with limited frames
  print_exception(e, max_frames: 5, extra_lines: 1)
end

puts "\n" + "─" * 60 + "\n"

# Example 6: Exception with syntax highlighting
puts "6. Exception in Complex Code:"

def complex_calculation(data)
  result = data.map do |item|
    case item[:type]
    when :number
      item[:value] * 2
    when :string
      item[:value].upcase
    when :array
      item[:value].sum
    else
      raise ArgumentError, "Unknown item type: #{item[:type]}"
    end
  end
  
  result.sum
end

def process_complex_data
  data = [
    { type: :number, value: 10 },
    { type: :string, value: "hello" },
    { type: :unknown, value: "mystery" }  # This will cause an error
  ]
  
  complex_calculation(data)
end

begin
  process_complex_data
rescue => e
  print_exception(e, theme: "monokai", extra_lines: 2)
end

puts "\n🎉 Rich traceback demo completed!"
puts "\nNote: In a real application, you might want to install Rich::Traceback"
puts "as the default exception handler using Rich::Traceback.install"