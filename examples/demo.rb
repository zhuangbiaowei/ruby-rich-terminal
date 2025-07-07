#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "🌟 Welcome to Rich Ruby - Beautiful Terminal Output 🌟\n"

console = Rich::Console.new

# Header
console.print("\n" + "=" * 60)
console.print("           [bold bright_magenta]RICH RUBY SHOWCASE[/bold bright_magenta]", markup: true)
console.print("=" * 60 + "\n")

# 1. Basic Rich Text and Styling
console.print("[bold bright_cyan]1. Rich Text and Styling[/bold bright_cyan]", markup: true)
console.print("─" * 30)

console.print("Colors: [red]Red[/red] [green]Green[/green] [blue]Blue[/blue] [yellow]Yellow[/yellow]", markup: true)
console.print("Styles: [bold]Bold[/bold] [italic]Italic[/italic] [underline]Underline[/underline] [strikethrough]Strike[/strikethrough]", markup: true)
console.print("Combined: [bold red on yellow]Bold Red on Yellow[/bold red on yellow]", markup: true)

# 2. Tables
console.print("\n[bold bright_cyan]2. Beautiful Tables[/bold bright_cyan]", markup: true)
console.print("─" * 20)

table = Rich::Table.new(title: "📊 Sample Data")
table.add_column("ID", justify: "center", style: Rich::Style.new(color: "cyan"))
table.add_column("Name", style: Rich::Style.new(color: "green"))
table.add_column("Department", justify: "center")
table.add_column("Status", justify: "center")

table.add_row("001", "Alice Johnson", "Engineering", "✅ Active")
table.add_row("002", "Bob Smith", "Design", "⏸️ On Leave")
table.add_row("003", "Carol Davis", "Marketing", "✅ Active")
table.add_row("004", "David Wilson", "Sales", "❌ Inactive")

console.print(table)

# 3. Progress Bars
console.print("\n[bold bright_cyan]3. Progress Indicators[/bold bright_cyan]", markup: true)
console.print("─" * 23)

puts "Simulating file downloads..."

# Quick progress demo
progress = Rich::Progress::Progress.new
download_task = progress.add_task("📁 Downloading files...", total: 100)
upload_task = progress.add_task("☁️  Uploading to cloud...", total: 80)

progress.with_progress do
  # Simulate downloads
  (0..100).step(5) do |i|
    progress.update(download_task, completed: i)
    sleep(0.05)
  end

  # Simulate uploads
  (0..80).step(4) do |i|
    progress.update(upload_task, completed: i)
    sleep(0.03)
  end
end
puts "✅ All transfers completed!\n"

# 4. Syntax Highlighting
console.print("[bold bright_cyan]4. Syntax Highlighting[/bold bright_cyan]", markup: true)
console.print("─" * 24)

ruby_code = <<~RUBY
  class RichDemo
    def initialize(name)
      @name = name
    end
    
    def greet
      puts "Hello from \#{@name}!"
    end
  end
  
  demo = RichDemo.new("Rich Ruby")
  demo.greet
RUBY

syntax = Rich::Syntax.new(ruby_code, "ruby", line_numbers: true)
console.print(syntax)

# 5. Tree Structure
console.print("\n[bold bright_cyan]5. Tree Display[/bold bright_cyan]", markup: true)
console.print("─" * 17)

tree = Rich::Tree.new("📁 My Project", style: Rich::Style.new(color: "blue", bold: true))

src = tree.add("📁 src", style: Rich::Style.new(color: "blue"))
src.add("📄 main.rb", style: Rich::Style.new(color: "green"))
src.add("📄 config.rb", style: Rich::Style.new(color: "green"))

lib = tree.add("📁 lib", style: Rich::Style.new(color: "blue"))
lib.add("📄 rich.rb", style: Rich::Style.new(color: "green"))
lib.add("📄 utils.rb", style: Rich::Style.new(color: "green"))

tests = tree.add("📁 spec", style: Rich::Style.new(color: "blue"))
tests.add("📄 spec_helper.rb", style: Rich::Style.new(color: "yellow"))
tests.add("📄 rich_spec.rb", style: Rich::Style.new(color: "yellow"))

tree.add("📄 Gemfile", style: Rich::Style.new(color: "magenta"))
tree.add("📄 README.md", style: Rich::Style.new(color: "cyan"))

console.print(tree)

# 6. Columns Layout
console.print("\n[bold bright_cyan]6. Multi-Column Layout[/bold bright_cyan]", markup: true)
console.print("─" * 23)

fruits = [
  "🍎 Apple", "🍌 Banana", "🍒 Cherry", "🥝 Kiwi",
  "🍇 Grapes", "🍊 Orange", "🍓 Strawberry", "🥭 Mango",
  "🍑 Peach", "🍍 Pineapple", "🥥 Coconut", "🍈 Melon"
]

columns = Rich::Columns.new(fruits, padding: [0, 2])
console.print(columns)

# 7. Status Indicators
console.print("\n[bold bright_cyan]7. Animated Status[/bold bright_cyan]", markup: true)
console.print("─" * 19)

puts "Performing operations with animated spinners..."

operations = [
  { name: "🔍 Analyzing data", spinner: "dots", duration: 1.5 },
  { name: "⚙️ Processing results", spinner: "star", duration: 1 },
  { name: "💾 Saving to database", spinner: "bounce", duration: 1.2 }
]

operations.each do |op|
  Rich::Status.show(op[:name], spinner: op[:spinner]) do
    sleep(op[:duration])
  end
  puts "✅ #{op[:name].gsub(/[🔍⚙️💾]\s*/, '')} completed"
end

# 8. Object Inspection
console.print("\n[bold bright_cyan]8. Object Inspection[/bold bright_cyan]", markup: true)
console.print("─" * 21)

sample_data = {
  user: {
    name: "Alice",
    age: 30,
    skills: ["Ruby", "JavaScript", "Python"],
    active: true
  },
  preferences: {
    theme: "dark",
    notifications: true,
    languages: ["en", "es", "fr"]
  },
  metadata: {
    created_at: Time.now,
    last_login: nil,
    login_count: 42
  }
}

console.print("Sample Ruby object with rich formatting:")
Rich.print_inspect(sample_data)

# 9. Markdown Rendering
console.print("\n[bold bright_cyan]9. Markdown Rendering[/bold bright_cyan]", markup: true)
console.print("─" * 21)

markdown_sample = <<~MARKDOWN
  ## Features Overview
  
  Rich Ruby provides **many** features:
  
  - Beautiful *colored* output
  - Tables with various styling
  - Progress bars and status indicators
  - `Syntax highlighting` for code
  - Tree structures for hierarchical data
  
  ### Code Example
  
  ```ruby
  console = Rich::Console.new
  console.print("Hello, World!", style: "bold red")
  ```
  
  ---
  
  > Rich makes terminal output beautiful and functional!
MARKDOWN

markdown = Rich::Markdown.new(markdown_sample)
console.print(markdown)

# 10. Exception Handling
console.print("\n[bold bright_cyan]10. Enhanced Exceptions[/bold bright_cyan]", markup: true)
console.print("─" * 24)

puts "Demonstrating rich exception display:"

begin
  def problematic_method
    raise StandardError, "This is a sample error for demonstration"
  end
  
  def caller_method
    problematic_method
  end
  
  caller_method
rescue => e
  Rich.print_exception(e, extra_lines: 2)
end

# Footer
console.print("\n" + "=" * 60)
console.print("           [bold bright_green]🎉 Rich Ruby Demo Complete! 🎉[/bold bright_green]", markup: true)
console.print("=" * 60)

console.print("\n[dim]Rich Ruby makes terminal output beautiful and functional.[/dim]", markup: true)
console.print("[dim]Visit the examples/ directory for more detailed demonstrations.[/dim]", markup: true)
console.print("[dim]Happy coding! ✨[/dim]", markup: true)