# Rich Ruby

Rich Ruby is a Ruby library for creating **rich text** and **beautiful formatting** in the terminal, inspired by Python's Rich library. Rich makes it easy to add color, style, tables, progress bars, syntax highlighting, tracebacks, and more to your Ruby applications.

## Features

✨ **Rich Text Rendering** - Color, style, and formatting with markup support  
📊 **Tables** - Flexible table rendering with various styling options  
📈 **Progress Bars** - Beautiful progress indicators with customizable display  
🎨 **Syntax Highlighting** - Code highlighting using Rouge gem  
📝 **Markdown Rendering** - Convert markdown to beautiful terminal output  
🌳 **Tree Display** - Hierarchical data visualization with guide lines  
📋 **Columns Layout** - Multi-column text arrangement  
📊 **Logging** - Enhanced logging with Rich formatting  
🔍 **Traceback** - Beautiful exception display with code context  
⏳ **Status Indicators** - Animated spinners and status updates  
🔍 **Object Inspection** - Rich visualization of Ruby objects  

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rich'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install rich
```

## Quick Start

```ruby
require 'rich'

console = Rich::Console.new

# Print with color and style
console.print("Hello, World!", style: "bold red")

# Rich markup
console.print("[bold blue]Rich[/bold blue] makes terminal output [italic green]beautiful[/italic green]!")

# Tables
table = Rich::Table.new(title: "User Data")
table.add_column("Name", style: "cyan")
table.add_column("Age", justify: "center")
table.add_column("City", style: "green")

table.add_row("Alice", "30", "New York")
table.add_row("Bob", "25", "San Francisco")
table.add_row("Charlie", "35", "Chicago")

console.print(table)

# Progress bars
progress = Rich::Progress.new
task_id = progress.add_task("Processing...", total: 100)

progress.start
(0..100).each do |i|
  progress.update(task_id, completed: i)
  sleep(0.01)
end
progress.stop
```

## Detailed Usage

### Rich Console

The console is the main interface for Rich output:

```ruby
require 'rich'

# Create a console
console = Rich::Console.new

# Print with styling
console.print("Hello", style: "bold red")
console.print("World", style: "italic blue")

# Print with markup
console.print("[bold red]Error:[/bold red] Something went wrong!")
```

### Text and Styling

Create rich text with colors and formatting:

```ruby
# Create styled text
text = Rich::Text.new("Hello World", style: Rich::Style.new(color: "red", bold: true))
console.print(text)

# Style parsing
style = Rich::Style.parse("bold blue on yellow")
text = Rich::Text.new("Styled text", style: style)

# Markup text
markup_text = Rich::Text.from_markup("[bold]Bold[/bold] and [italic red]italic red[/italic red]")
```

### Tables

Create beautiful tables with various styling options:

```ruby
# Basic table
table = Rich::Table.new(title: "Sample Data")
table.add_column("ID", justify: "center", style: "cyan")
table.add_column("Name", style: "green")
table.add_column("Status", justify: "center")

table.add_row("1", "Alice", "✅ Active")
table.add_row("2", "Bob", "⏸️ Paused")
table.add_row("3", "Charlie", "❌ Inactive")

console.print(table)

# Table with custom border style
table = Rich::Table.new(border_style: "rounded")
# ... add columns and rows
```

### Progress Bars

Show progress with beautiful bars and statistics:

```ruby
# Simple progress tracking
progress = Rich::Progress.new
task_id = progress.add_task("Downloading...", total: 1000)

progress.start
(0..1000).each do |i|
  progress.advance(task_id, 1)
  sleep(0.001)
end
progress.stop

# Track an enumerable
items = (1..100).to_a
progress.track(items, description: "Processing items") do |item|
  # Process each item
  sleep(0.01)
end
```

### Syntax Highlighting

Highlight code with beautiful colors:

```ruby
# Highlight Ruby code
code = <<~RUBY
  class Person
    def initialize(name)
      @name = name
    end
    
    def greet
      puts "Hello, I'm \#{@name}!"
    end
  end
RUBY

syntax = Rich::Syntax.new(code, "ruby", line_numbers: true)
console.print(syntax)

# Highlight from file
syntax = Rich::Syntax.from_path("app.rb", line_numbers: true)
```

### Markdown Rendering

Convert markdown to rich terminal output:

```ruby
markdown_content = <<~MARKDOWN
  # My Project
  
  This is a **sample** markdown with:
  
  - Bullet points
  - *Italic text*
  - `inline code`
  
  ```ruby
  puts "Hello, World!"
  ```
MARKDOWN

markdown = Rich::Markdown.new(markdown_content)
console.print(markdown)
```

### Tree Display

Show hierarchical data with guide lines:

```ruby
tree = Rich::Tree.new("📁 Project")

src = tree.add("📁 src", style: Rich::Style.new(color: "blue"))
src.add("📄 main.rb", style: Rich::Style.new(color: "green"))
src.add("📄 utils.rb", style: Rich::Style.new(color: "green"))

lib = tree.add("📁 lib", style: Rich::Style.new(color: "blue"))
lib.add("📄 rich.rb", style: Rich::Style.new(color: "green"))

console.print(tree)
```

### Columns Layout

Arrange content in multiple columns:

```ruby
items = ["Apple", "Banana", "Cherry", "Date", "Elderberry", "Fig"]
columns = Rich::Columns.new(items, padding: [0, 2])
console.print(columns)
```

### Status Indicators

Show animated status with spinners:

```ruby
# Block syntax
Rich::Status.show("Loading...", spinner: "dots") do |status|
  sleep(2)
  status.update("Almost done...")
  sleep(1)
end

# Manual control
status = Rich::Status.new("Processing...", spinner: "star")
status.start
sleep(3)
status.stop
```

### Logging

Enhanced logging with Rich formatting:

```ruby
logger = Rich::Logger.new

logger.info("Application started")
logger.warn("This is a warning")
logger.error("An error occurred")

# Styled logging
logger.styled(:info, "Success!", style: Rich::Style.new(color: "green", bold: true))

# Panel-style logging
logger.info_panel("System Status", "All systems operational")
logger.error_panel("Error", "Database connection failed")
```

### Exception Tracebacks

Beautiful exception display with code context:

```ruby
begin
  # Some code that raises an exception
  raise StandardError, "Something went wrong"
rescue => e
  # Display rich traceback
  Rich.print_exception(e, extra_lines: 3)
end

# Or use the helper module
include Rich::TracebackHelpers

rich_traceback do
  # Code that might raise an exception
end
```

### Object Inspection

Rich visualization of Ruby objects:

```ruby
data = {
  name: "Alice",
  age: 30,
  hobbies: ["reading", "hiking", "coding"],
  address: {
    street: "123 Main St",
    city: "New York"
  }
}

# Use Rich inspect
Rich.print_inspect(data)

# Or use the extension method
console.print(data.rich_inspect)

# Custom options
Rich.print_inspect(data, max_depth: 2, expand_all: true)
```

## Configuration Options

Rich Ruby provides many configuration options:

### Console Options
```ruby
console = Rich::Console.new(
  width: 120,           # Terminal width
  height: 40,           # Terminal height
  color_system: "auto", # Color system detection
  force_terminal: true, # Force terminal mode
  stderr: false         # Use stderr instead of stdout
)
```

### Style Options
```ruby
style = Rich::Style.new(
  color: "red",         # Text color
  bgcolor: "yellow",    # Background color
  bold: true,           # Bold text
  italic: true,         # Italic text
  underline: true,      # Underlined text
  strikethrough: true,  # Strikethrough text
  dim: true,            # Dim text
  reverse: true,        # Reverse colors
  blink: true           # Blinking text
)
```

## Advanced Usage

### Custom Renderables

Create your own renderable objects:

```ruby
class CustomBox
  include Rich::Renderable
  
  def initialize(text)
    @text = text
  end
  
  def __rich_console__(console, options)
    segments = []
    width = @text.length + 4
    
    # Top border
    segments << Rich::Segment.new("┌" + "─" * (width - 2) + "┐")
    segments << Rich::Segment.line
    
    # Content
    segments << Rich::Segment.new("│ #{@text} │")
    segments << Rich::Segment.line
    
    # Bottom border
    segments << Rich::Segment.new("└" + "─" * (width - 2) + "┘")
    
    segments
  end
end

box = CustomBox.new("Hello World")
console.print(box)
```

### Measuring Content

Measure the dimensions of renderables:

```ruby
text = Rich::Text.new("Hello World")
measurement = Rich::Measurement.get(console, text, 80)
puts "Min width: #{measurement.minimum}, Max width: #{measurement.maximum}"
```

## Color Support

Rich Ruby supports various color systems:

- **3/4 bit colors**: Basic 8/16 colors
- **8 bit colors**: 256 color palette
- **24 bit colors**: True color (16 million colors)

Colors can be specified as:
- Color names: `"red"`, `"blue"`, `"green"`
- Hex values: `"#ff0000"`, `"#00ff00"`
- RGB tuples: `[255, 0, 0]`

## Performance

Rich Ruby is designed to be fast and efficient:

- Lazy rendering - content is only rendered when needed
- Efficient segment system - minimal memory allocation
- Caching - repeated renders are optimized
- Thread-safe - safe to use in multi-threaded applications

## Examples

Check out the `examples/` directory for comprehensive examples of all features:

- `examples/demo.rb` - Basic Rich functionality
- `examples/table_demo.rb` - Table examples
- `examples/progress_demo.rb` - Progress bar examples
- `examples/syntax_demo.rb` - Syntax highlighting examples
- `examples/markdown_demo.rb` - Markdown rendering examples
- `examples/tree_demo.rb` - Tree display examples
- `examples/columns_demo.rb` - Column layout examples
- `examples/logging_demo.rb` - Logging examples
- `examples/traceback_demo.rb` - Exception handling examples
- `examples/status_demo.rb` - Status indicator examples
- `examples/inspect_demo.rb` - Object inspection examples

## Contributing

Bug reports and pull requests are welcome on GitHub. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgements

Rich Ruby is inspired by [Will McGugan's](https://github.com/willmcgugan) excellent [Rich library for Python](https://github.com/Textualize/rich). Many design decisions and features are adapted from the original Rich library.