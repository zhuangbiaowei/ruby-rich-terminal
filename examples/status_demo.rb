#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "=== Rich Ruby Status Indicator Demo ===\n"

# Include helper methods
include Rich::StatusHelpers

# Example 1: Basic status with default spinner
puts "1. Basic Status Indicator:"
status = Rich::Status.new("Loading...")
status.start
sleep(3)
status.stop
puts "Done!\n"

# Example 2: Different spinners
puts "2. Different Spinner Types:"

spinners_to_demo = ["dots", "line", "star", "bounce", "circle", "arrow"]

spinners_to_demo.each do |spinner_name|
  puts "Testing #{spinner_name} spinner:"
  status = Rich::Status.new("Working with #{spinner_name}", spinner: spinner_name)
  status.start
  sleep(2)
  status.stop
  puts "✓ Complete"
end

puts

# Example 3: Using block syntax
puts "3. Using Block Syntax:"

Rich::Status.show("Processing data...", spinner: "dots2") do |status|
  sleep(1)
  status.update("Connecting to database...")
  sleep(1)
  status.update("Fetching records...")
  sleep(1)
  status.update("Processing results...")
  sleep(1)
end

puts "✓ Data processing complete!\n"

# Example 4: Custom styled status
puts "4. Custom Styled Status:"

custom_style = Rich::Style.new(color: "green", bold: true)
Rich::Status.show("Custom styled status", 
                  spinner: "star", 
                  style: custom_style) do |status|
  sleep(2)
end

puts "✓ Custom styling complete!\n"

# Example 5: Multiple operations simulation
puts "5. Simulating Complex Operations:"

operations = [
  { name: "Initializing system", duration: 1.5, spinner: "dots" },
  { name: "Loading configuration", duration: 1, spinner: "line" },
  { name: "Connecting to services", duration: 2, spinner: "bounce" },
  { name: "Validating data", duration: 1.5, spinner: "circle" },
  { name: "Optimizing performance", duration: 2, spinner: "star" },
  { name: "Finalizing setup", duration: 1, spinner: "arrow" }
]

operations.each_with_index do |op, index|
  Rich::Status.show("#{op[:name]}...", spinner: op[:spinner]) do |status|
    sleep(op[:duration])
  end
  puts "✓ #{op[:name]} complete (#{index + 1}/#{operations.length})"
end

puts "\n🎉 All operations completed successfully!\n"

# Example 6: Status with helper methods
puts "6. Using Helper Methods:"

with_status("Helper method example", spinner: "hamburger") do |status|
  sleep(1)
  status.update("Updated message")
  sleep(1)
end

puts "✓ Helper method demo complete!\n"

# Example 7: Error handling
puts "7. Error Handling Demo:"

begin
  Rich::Status.show("Operation that might fail", spinner: "noise") do |status|
    sleep(1)
    status.update("Something went wrong...")
    sleep(0.5)
    raise StandardError, "Simulated error"
  end
rescue => e
  puts "✗ Operation failed: #{e.message}"
end

puts

# Example 8: Speed variations
puts "8. Speed Variations:"

puts "Normal speed:"
Rich::Status.show("Normal speed", spinner: "dots", speed: 1.0) do
  sleep(2)
end

puts "✓ Normal speed complete"

puts "Fast speed:"
Rich::Status.show("Fast speed", spinner: "dots", speed: 2.0) do
  sleep(2)
end

puts "✓ Fast speed complete"

puts "Slow speed:"
Rich::Status.show("Slow speed", spinner: "dots", speed: 0.5) do
  sleep(2)
end

puts "✓ Slow speed complete\n"

# Example 9: Available spinners info
puts "9. Available Spinners:"
puts "Total spinners available: #{Rich::Status.available_spinners.length}"
puts "Some examples: #{Rich::Status.available_spinners.first(10).join(', ')}"

# Show a few spinner details
puts "\nSpinner details:"
["dots", "star", "circle"].each do |spinner|
  info = Rich::Status.spinner_info(spinner)
  puts "  #{spinner}: #{info[:frames].length} frames, #{info[:interval]}s interval"
end

puts

# Example 10: Long running operation with updates
puts "10. Long Running Operation with Updates:"

Rich::Status.show("Starting long operation...", spinner: "bouncingBall") do |status|
  steps = [
    "Preparing workspace",
    "Downloading dependencies", 
    "Compiling source code",
    "Running tests",
    "Building package",
    "Deploying to server"
  ]
  
  steps.each_with_index do |step, index|
    status.update("#{step} (#{index + 1}/#{steps.length})")
    sleep(1)
  end
  
  status.update("Cleaning up...")
  sleep(0.5)
end

puts "✓ Long operation completed successfully!"

puts "\n🎉 Status indicator demo completed!"
puts "\nNote: Status indicators work best in terminal environments."
puts "The animations might not display properly in some IDEs or logs."