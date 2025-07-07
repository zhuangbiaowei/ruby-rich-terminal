#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Table Demo ===\n"

# Basic table
table = Rich::Table.new("Name", "Age", "City")
table.add_row("Alice", "25", "New York")
table.add_row("Bob", "30", "San Francisco") 
table.add_row("Charlie", "35", "London")

console.print(table)
puts

# Table with styling
styled_table = Rich::Table.new(
  "Product", "Price", "Stock",
  title: "Inventory Report",
  header_style: "bold magenta",
  border_style: "blue"
)

styled_table.add_row("Widget A", "$10.99", "150")
styled_table.add_row("Widget B", "$25.50", "75", style: "bold")  
styled_table.add_row("Widget C", "$5.25", "200")

console.print(styled_table)
puts

# Table with different box styles
heavy_table = Rich::Table.new(
  "Task", "Status", "Priority",
  box: Rich::Table::Box::HEAVY,
  title: "Project Tasks"
)

heavy_table.add_row("Design UI", "Complete", "High")
heavy_table.add_row("Write Tests", "In Progress", "Medium")
heavy_table.add_row("Deploy", "Pending", "Low")

console.print(heavy_table)
puts

puts "🎉 Table demo completed!"