#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "🌟 Rich Ruby - Simple Demo 🌟\n"

console = Rich::Console.new

# Rich Text and Styling
console.print("\n[bold bright_cyan]Rich Text and Styling:[/bold bright_cyan]", markup: true)
console.print("Colors: [red]Red[/red] [green]Green[/green] [blue]Blue[/blue]", markup: true)
console.print("Styles: [bold]Bold[/bold] [italic]Italic[/italic] [underline]Underline[/underline]", markup: true)

# Tables
console.print("\n[bold bright_cyan]Beautiful Tables:[/bold bright_cyan]", markup: true)
table = Rich::Table.new(title: "Sample Data")
table.add_column("Name", style: Rich::Style.new(color: "green"))
table.add_column("Age", justify: "center")
table.add_column("Status")

table.add_row("Alice", "30", "✅ Active")
table.add_row("Bob", "25", "⏸️ Paused")

console.print(table)

# Syntax Highlighting
console.print("\n[bold bright_cyan]Syntax Highlighting:[/bold bright_cyan]", markup: true)
code = 'puts "Hello, World!"'
syntax = Rich::Syntax.new(code, "ruby")
console.print(syntax)

# Tree Display
console.print("\n[bold bright_cyan]Tree Display:[/bold bright_cyan]", markup: true)
tree = Rich::Tree.new("📁 Project")
tree.add("📄 main.rb", style: Rich::Style.new(color: "green"))
tree.add("📄 utils.rb", style: Rich::Style.new(color: "green"))
console.print(tree)

# Columns
console.print("\n[bold bright_cyan]Multi-Column Layout:[/bold bright_cyan]", markup: true)
items = ["Apple", "Banana", "Cherry", "Date", "Fig", "Grape"]
columns = Rich::Columns.new(items)
console.print(columns)

# Object Inspection
console.print("\n[bold bright_cyan]Object Inspection:[/bold bright_cyan]", markup: true)
data = { name: "Alice", skills: ["Ruby", "Python"], active: true }
Rich.print_inspect(data)

# Status Indicator
console.print("\n[bold bright_cyan]Status Indicator:[/bold bright_cyan]", markup: true)
puts "Demonstrating animated spinner..."
Rich::Status.show("Processing...", spinner: "dots") do
  sleep(2)
end
puts "✅ Complete!"

console.print("\n🎉 [bold green]Rich Ruby Demo Complete![/bold green] 🎉", markup: true)