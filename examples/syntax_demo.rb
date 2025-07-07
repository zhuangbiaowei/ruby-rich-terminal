#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Syntax Highlighting Demo ===\n"

# Ruby code example
ruby_code = <<~RUBY
  class Person
    attr_reader :name, :age
    
    def initialize(name, age)
      @name = name
      @age = age
    end
    
    def greet
      puts "Hello, I'm #{@name} and I'm #{@age} years old!"
    end
    
    def self.create_adult(name)
      new(name, 18)
    end
  end
  
  # Create instances
  person = Person.new("Alice", 25)
  adult = Person.create_adult("Bob")
  
  person.greet
  adult.greet
RUBY

puts "1. Ruby code with line numbers:"
ruby_syntax = Rich::Syntax.new(ruby_code, "ruby", line_numbers: true)
console.print(ruby_syntax)
puts

# Python code example
python_code = <<~PYTHON
  def fibonacci(n):
      """Generate Fibonacci sequence up to n terms."""
      if n <= 0:
          return []
      elif n == 1:
          return [0]
      elif n == 2:
          return [0, 1]
      
      sequence = [0, 1]
      for i in range(2, n):
          next_num = sequence[i-1] + sequence[i-2]
          sequence.append(next_num)
      
      return sequence
  
  # Example usage
  numbers = fibonacci(10)
  print(f"First 10 Fibonacci numbers: {numbers}")
PYTHON

puts "2. Python code:"
python_syntax = Rich::Syntax.new(python_code, "python")
console.print(python_syntax)
puts

# JavaScript code example
js_code = <<~JAVASCRIPT
  class Calculator {
    constructor() {
      this.history = [];
    }
    
    add(a, b) {
      const result = a + b;
      this.history.push(`${a} + ${b} = ${result}`);
      return result;
    }
    
    multiply(a, b) {
      const result = a * b;
      this.history.push(`${a} * ${b} = ${result}`);
      return result;
    }
    
    getHistory() {
      return this.history;
    }
  }
  
  // Usage
  const calc = new Calculator();
  console.log(calc.add(5, 3));
  console.log(calc.multiply(4, 7));
  console.log(calc.getHistory());
JAVASCRIPT

puts "3. JavaScript code with highlighting:"
js_syntax = Rich::Syntax.new(js_code, "javascript", highlight_lines: [1, 5, 12])
console.print(js_syntax)
puts

# SQL code example
sql_code = <<~SQL
  SELECT 
    u.name,
    u.email,
    COUNT(o.id) as order_count,
    SUM(o.total_amount) as total_spent
  FROM users u
  LEFT JOIN orders o ON u.id = o.user_id
  WHERE u.created_at >= '2024-01-01'
  GROUP BY u.id, u.name, u.email
  HAVING COUNT(o.id) > 0
  ORDER BY total_spent DESC
  LIMIT 10;
SQL

puts "4. SQL code:"
sql_syntax = Rich::Syntax.new(sql_code, "sql", line_numbers: true)
console.print(sql_syntax)

puts "\n🎉 Syntax highlighting demo completed!"