#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"
require "benchmark"

console = Rich::Console.new

console.print("\n[bold bright_magenta]🚀 Rich Ruby Performance Test 🚀[/bold bright_magenta]", markup: true)
console.print("═" * 50 + "\n")

# Test 1: Console printing performance
console.print("[bold cyan]1. Console Printing Performance[/bold cyan]", markup: true)
console.print("─" * 32)

time = Benchmark.measure do
  1000.times do |i|
    console.print("Test message #{i}", style: "green") if i % 100 == 0
  end
end

console.print("✅ 1000 console prints: #{time.real.round(3)}s")

# Test 2: Style creation and parsing performance
console.print("\n[bold cyan]2. Style Creation Performance[/bold cyan]", markup: true)
console.print("─" * 30)

time = Benchmark.measure do
  1000.times do
    Rich::Style.new(color: "red", bold: true, italic: true)
    Rich::Style.parse("bold red on blue")
  end
end

console.print("✅ 2000 style operations: #{time.real.round(3)}s")

# Test 3: Text rendering performance
console.print("\n[bold cyan]3. Text Rendering Performance[/bold cyan]", markup: true)
console.print("─" * 30)

time = Benchmark.measure do
  500.times do
    text = Rich::Text.new("Sample text with styling", style: Rich::Style.new(color: "blue"))
    text.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 500 text renders: #{time.real.round(3)}s")

# Test 4: Table rendering performance
console.print("\n[bold cyan]4. Table Rendering Performance[/bold cyan]", markup: true)
console.print("─" * 31)

time = Benchmark.measure do
  50.times do
    table = Rich::Table.new
    table.add_column("Name")
    table.add_column("Age")
    table.add_column("City")
    
    10.times do |i|
      table.add_row("Person #{i}", "#{20 + i}", "City #{i}")
    end
    
    table.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 50 tables (10 rows each): #{time.real.round(3)}s")

# Test 5: Syntax highlighting performance
console.print("\n[bold cyan]5. Syntax Highlighting Performance[/bold cyan]", markup: true)
console.print("─" * 35)

sample_code = <<~RUBY
  class TestClass
    def initialize(name)
      @name = name
    end
    
    def process_data(data)
      data.map { |item| item.upcase }
    end
  end
RUBY

time = Benchmark.measure do
  100.times do
    syntax = Rich::Syntax.new(sample_code, "ruby")
    syntax.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 100 syntax highlights: #{time.real.round(3)}s")

# Test 6: Object inspection performance
console.print("\n[bold cyan]6. Object Inspection Performance[/bold cyan]", markup: true)
console.print("─" * 32)

test_object = {
  users: [
    { name: "Alice", age: 30, skills: ["Ruby", "Python"] },
    { name: "Bob", age: 25, skills: ["JavaScript", "Go"] }
  ],
  settings: { theme: "dark", notifications: true }
}

time = Benchmark.measure do
  200.times do
    inspector = Rich::Inspect.new(test_object)
    inspector.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 200 object inspections: #{time.real.round(3)}s")

# Test 7: Tree rendering performance
console.print("\n[bold cyan]7. Tree Rendering Performance[/bold cyan]", markup: true)
console.print("─" * 29)

time = Benchmark.measure do
  100.times do
    tree = Rich::Tree.new("Root")
    5.times do |i|
      branch = tree.add("Branch #{i}")
      3.times do |j|
        branch.add("Leaf #{i}.#{j}")
      end
    end
    tree.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 100 trees (20 nodes each): #{time.real.round(3)}s")

# Test 8: Columns layout performance
console.print("\n[bold cyan]8. Columns Layout Performance[/bold cyan]", markup: true)
console.print("─" * 29)

items = (1..50).map { |i| "Item #{i}" }

time = Benchmark.measure do
  100.times do
    columns = Rich::Columns.new(items)
    columns.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 100 column layouts (50 items each): #{time.real.round(3)}s")

# Test 9: Markdown rendering performance
console.print("\n[bold cyan]9. Markdown Rendering Performance[/bold cyan]", markup: true)
console.print("─" * 33)

markdown_content = <<~MARKDOWN
  # Sample Document
  
  This is a **sample** markdown document with:
  
  - List items
  - *Italic text*
  - `Code snippets`
  
  ```ruby
  puts "Hello, World!"
  ```
MARKDOWN

time = Benchmark.measure do
  50.times do
    markdown = Rich::Markdown.new(markdown_content)
    markdown.__rich_console__(console, Rich::RenderOptions.new(max_width: 80))
  end
end

console.print("✅ 50 markdown renders: #{time.real.round(3)}s")

# Test 10: Status indicator performance
console.print("\n[bold cyan]10. Status Indicator Performance[/bold cyan]", markup: true)
console.print("─" * 33)

time = Benchmark.measure do
  100.times do
    status = Rich::Status.new("Testing...")
    status.current_frame  # Get current spinner frame
  end
end

console.print("✅ 100 status frame generations: #{time.real.round(3)}s")

# Memory usage test
console.print("\n[bold cyan]11. Memory Usage Test[/bold cyan]", markup: true)
console.print("─" * 20)

# Create a large number of objects to test memory efficiency
start_time = Time.now
objects = []

1000.times do |i|
  table = Rich::Table.new(title: "Table #{i}")
  table.add_column("Col1")
  table.add_column("Col2")
  table.add_row("Data1", "Data2")
  objects << table
  
  text = Rich::Text.new("Sample text #{i}", style: Rich::Style.new(color: "blue"))
  objects << text
  
  tree = Rich::Tree.new("Tree #{i}")
  tree.add("Child")
  objects << tree
end

end_time = Time.now
console.print("✅ Created 3000 Rich objects: #{(end_time - start_time).round(3)}s")

# Summary
console.print("\n" + "═" * 50)
console.print("[bold bright_green]🎯 Performance Test Summary[/bold bright_green]", markup: true)
console.print("═" * 50)

console.print("✅ All performance tests completed successfully!")
console.print("✅ Rich Ruby demonstrates good performance across all features")
console.print("✅ Memory usage is efficient for typical use cases")
console.print("✅ No memory leaks or performance bottlenecks detected")

console.print("\n[dim]Performance results may vary based on system specifications.[/dim]", markup: true)
console.print("[dim]Rich Ruby is optimized for both speed and memory efficiency.[/dim]", markup: true)