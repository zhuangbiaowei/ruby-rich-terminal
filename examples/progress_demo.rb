#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Progress Bar Demo ===\n"

# Simple progress bar without auto-refresh
puts "1. Simple progress bar:"
progress = Rich::Progress::Progress.new(
  Rich::Progress::TextColumn.new("{task.description}"),
  Rich::Progress::BarColumn.new(bar_width: 30),  
  Rich::Progress::PercentageColumn.new,
  console: console,
  auto_refresh: false
)

task_id = progress.add_task("Processing", total: 100.0, start: false)

# Manual progress updates
20.times do |i|
  progress.advance(task_id, 5.0)
  
  segments = progress.__rich_console__(console, Rich::RenderOptions.new(max_width: console.width))
  console.write_segments(segments)
  puts
  sleep(0.1)
end

puts

# Different bar styles  
puts "2. Different progress columns:"

# Text and percentage only
simple_progress = Rich::Progress::Progress.new(
  Rich::Progress::TextColumn.new("Task: {task.description}"),
  Rich::Progress::PercentageColumn.new,
  console: console,
  auto_refresh: false
)

task2 = simple_progress.add_task("Simple Task", total: 50.0, start: false)
25.times do |i|
  simple_progress.advance(task2, 2.0)
  if (i + 1) % 5 == 0  # Show every 5th update
    segments = simple_progress.__rich_console__(console, Rich::RenderOptions.new(max_width: console.width))
    console.write_segments(segments)  
    puts
  end
  sleep(0.05)
end

puts "\n🎉 Progress demo completed!"