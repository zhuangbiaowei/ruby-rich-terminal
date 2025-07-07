#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Columns Layout Demo ===\n"

# Example 1: Simple text columns
puts "1. Simple Text in Columns:"
simple_items = [
  "Apple", "Banana", "Cherry", "Date", "Elderberry",
  "Fig", "Grape", "Honeydew", "Italian Plum", "Jackfruit",
  "Kiwi", "Lemon", "Mango", "Nectarine", "Orange"
]

simple_columns = Rich::Columns.new(simple_items)
console.print(simple_columns)
puts

# Example 2: Styled text columns
puts "2. Styled Items in Columns:"
styled_items = [
  Rich::Text.new("🔴 Red", style: Rich::Style.new(color: "red", bold: true)),
  Rich::Text.new("🟠 Orange", style: Rich::Style.new(color: "bright_yellow", bold: true)),
  Rich::Text.new("🟡 Yellow", style: Rich::Style.new(color: "yellow", bold: true)),
  Rich::Text.new("🟢 Green", style: Rich::Style.new(color: "green", bold: true)),
  Rich::Text.new("🔵 Blue", style: Rich::Style.new(color: "blue", bold: true)),
  Rich::Text.new("🟣 Purple", style: Rich::Style.new(color: "magenta", bold: true)),
  Rich::Text.new("⚫ Black", style: Rich::Style.new(color: "black", bold: true)),
  Rich::Text.new("⚪ White", style: Rich::Style.new(color: "white", bold: true))
]

styled_columns = Rich::Columns.new(styled_items, padding: [0, 2])
console.print(styled_columns)
puts

# Example 3: Text Items with Different Lengths
puts "3. Text Items with Different Lengths:"
mixed_items = [
  Rich::Text.new("Short", style: Rich::Style.new(color: "red")),
  Rich::Text.new("Medium Length Text", style: Rich::Style.new(color: "green")),
  Rich::Text.new("Very Long Text Content Here", style: Rich::Style.new(color: "blue")),
  Rich::Text.new("X", style: Rich::Style.new(color: "yellow")),
  Rich::Text.new("Another Medium", style: Rich::Style.new(color: "magenta")),
  Rich::Text.new("Short", style: Rich::Style.new(color: "cyan")),
]

mixed_columns = Rich::Columns.new(mixed_items, equal: true)
console.print(mixed_columns)
puts

# Example 4: File listing simulation
puts "4. File Listing Simulation:"
file_items = [
  "📁 Documents", "📁 Downloads", "📁 Pictures", "📁 Music",
  "📄 readme.txt", "📄 config.json", "📄 data.csv", "📄 notes.md",
  "🖼️ image1.jpg", "🖼️ image2.png", "🖼️ logo.svg", "🖼️ banner.gif",
  "⚙️ setup.exe", "⚙️ install.sh", "⚙️ config.yml", "⚙️ docker.compose"
].map do |item|
  color = case item
          when /📁/ then "blue"
          when /📄/ then "green"
          when /🖼️/ then "magenta"
          when /⚙️/ then "yellow"
          else "white"
          end
  Rich::Text.new(item, style: Rich::Style.new(color: color))
end

file_columns = Rich::Columns.new(file_items, padding: [0, 1])
console.print(file_columns)
puts

# Example 5: Programming languages with descriptions
puts "5. Programming Languages:"
language_items = [
  Rich::Text.new("Ruby\nDynamic, elegant", style: Rich::Style.new(color: "red")),
  Rich::Text.new("Python\nSimple, powerful", style: Rich::Style.new(color: "blue")),
  Rich::Text.new("JavaScript\nUbiquitous, flexible", style: Rich::Style.new(color: "yellow")),
  Rich::Text.new("Go\nFast, concurrent", style: Rich::Style.new(color: "cyan")),
  Rich::Text.new("Rust\nSafe, fast", style: Rich::Style.new(color: "bright_yellow")),
  Rich::Text.new("Swift\nModern, safe", style: Rich::Style.new(color: "bright_red"))
]

lang_columns = Rich::Columns.new(language_items, padding: [1, 2])
console.print(lang_columns)
puts

# Example 6: Equal width columns
puts "6. Equal Width Columns:"
equal_items = (1..12).map { |i| "Item #{i}" }
equal_columns = Rich::Columns.new(equal_items, equal: true, padding: [0, 1])
console.print(equal_columns)
puts

# Example 7: Status indicators
puts "7. Status Indicators:"
status_items = [
  Rich::Text.new("✅ Success", style: Rich::Style.new(color: "green")),
  Rich::Text.new("⚠️  Warning", style: Rich::Style.new(color: "yellow")),
  Rich::Text.new("❌ Error", style: Rich::Style.new(color: "red")),
  Rich::Text.new("ℹ️  Info", style: Rich::Style.new(color: "blue")),
  Rich::Text.new("🔄 Processing", style: Rich::Style.new(color: "cyan")),
  Rich::Text.new("⏸️  Paused", style: Rich::Style.new(color: "bright_black")),
  Rich::Text.new("🎯 Target", style: Rich::Style.new(color: "magenta")),
  Rich::Text.new("🔥 Hot", style: Rich::Style.new(color: "bright_red"))
]

status_columns = Rich::Columns.new(status_items, padding: [0, 3])
console.print(status_columns)

puts "\n🎉 Columns layout demo completed!"