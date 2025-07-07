#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Markdown Rendering Demo ===\n"

# Sample markdown content
markdown_content = <<~MARKDOWN
  # Welcome to Rich Ruby

  This is a **comprehensive** markdown rendering demo using the Rich Ruby library.

  ## Features

  The Rich library supports various markdown elements:

  - **Bold text** and *italic text*
  - ~~Strikethrough text~~
  - `inline code` with syntax highlighting
  - [Links](https://github.com) with descriptions
  - Images: ![Ruby Logo](https://ruby-lang.org/logo.png "Ruby Programming Language")

  ### Code Blocks

  Here's some Ruby code with syntax highlighting:

  ```ruby
  class MarkdownDemo
    def initialize(name)
      @name = name
    end
    
    def greet
      puts "Hello from #{@name}!"
    end
  end
  
  demo = MarkdownDemo.new("Rich Ruby")
  demo.greet
  ```

  ### Lists

  #### Unordered List:
  - First item
  - Second item
    - Nested item
    - Another nested item
  - Third item

  #### Ordered List:
  1. First step
  2. Second step
  3. Third step

  ### Blockquotes

  > "The best way to predict the future is to create it."
  > - Peter Drucker

  ### Tables

  | Language | Year | Paradigm |
  |----------|------|----------|
  | Ruby     | 1995 | Object-Oriented |
  | Python   | 1991 | Multi-paradigm |
  | JavaScript | 1995 | Multi-paradigm |

  ---

  ## Advanced Features

  ### SQL Example:

  ```sql
  SELECT users.name, COUNT(orders.id) as order_count
  FROM users
  LEFT JOIN orders ON users.id = orders.user_id
  WHERE users.active = true
  GROUP BY users.id
  ORDER BY order_count DESC;
  ```

  ### Python Example:

  ```python
  def fibonacci(n):
      if n <= 1:
          return n
      return fibonacci(n-1) + fibonacci(n-2)
  
  # Generate first 10 Fibonacci numbers
  for i in range(10):
      print(f"F({i}) = {fibonacci(i)}")
  ```

  ---

  That's a comprehensive overview of Rich Ruby's markdown capabilities!
MARKDOWN

puts "Rendering markdown content:"
puts "=" * 60

markdown = Rich::Markdown.new(markdown_content)
console.print(markdown)

puts "\n🎉 Markdown rendering demo completed!"