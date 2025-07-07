#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

puts "=== Rich Ruby Inspect Demo ===\n"

console = Rich::Console.new

# Example 1: Basic data types
puts "1. Basic Data Types:"

basic_types = [
  42,
  3.14159,
  "Hello, World!",
  :symbol,
  true,
  false,
  nil,
  (1..10),
  (1...10),
  /hello\s+world/i
]

basic_types.each do |obj|
  puts "#{obj.class}: "
  inspector = Rich::Inspect.new(obj)
  console.print(inspector)
  puts
end

puts "─" * 60

# Example 2: Collections
puts "2. Collections:"

# Simple array
simple_array = [1, 2, 3, 4, 5]
puts "Simple Array:"
Rich.print_inspect(simple_array)

# Nested array
nested_array = [1, [2, 3], [4, [5, 6]], 7]
puts "\nNested Array:"
Rich.print_inspect(nested_array)

# Long array
long_array = (1..20).to_a
puts "\nLong Array (truncated):"
Rich.print_inspect(long_array)

# Simple hash
simple_hash = { name: "Alice", age: 30, city: "New York" }
puts "\nSimple Hash:"
Rich.print_inspect(simple_hash)

# Nested hash
nested_hash = {
  user: {
    name: "Bob",
    profile: {
      age: 25,
      preferences: ["ruby", "javascript", "python"]
    }
  },
  settings: {
    theme: "dark",
    notifications: true
  }
}
puts "\nNested Hash:"
Rich.print_inspect(nested_hash)

puts "\n" + "─" * 60

# Example 3: Custom objects
puts "3. Custom Objects:"

class Person
  def initialize(name, age, hobbies = [])
    @name = name
    @age = age
    @hobbies = hobbies
  end
  
  attr_reader :name, :age, :hobbies
end

class Company
  def initialize(name)
    @name = name
    @employees = []
    @founded = Time.now.year
  end
  
  def add_employee(person)
    @employees << person
  end
  
  attr_reader :name, :employees, :founded
end

# Create some objects
alice = Person.new("Alice", 30, ["reading", "hiking", "coding"])
bob = Person.new("Bob", 25, ["music", "gaming"])

company = Company.new("TechCorp")
company.add_employee(alice)
company.add_employee(bob)

puts "Person object:"
Rich.print_inspect(alice)

puts "\nCompany object with employees:"
Rich.print_inspect(company)

puts "\n" + "─" * 60

# Example 4: Different expansion settings
puts "4. Different Expansion Settings:"

complex_data = {
  users: [
    { id: 1, name: "Alice", tags: ["admin", "developer"] },
    { id: 2, name: "Bob", tags: ["user", "tester"] },
    { id: 3, name: "Charlie", tags: ["manager", "analyst"] }
  ],
  settings: {
    theme: "dark",
    language: "en",
    features: {
      notifications: true,
      advanced_mode: false,
      experimental: ["feature_a", "feature_b"]
    }
  }
}

puts "Default expansion:"
Rich.print_inspect(complex_data)

puts "\nMax depth 1:"
Rich.print_inspect(complex_data, max_depth: 1)

puts "\nMax length 2:"
Rich.print_inspect(complex_data, max_length: 2)

puts "\nExpand all:"
Rich.print_inspect(complex_data, expand_all: true)

puts "\n" + "─" * 60

# Example 5: Special Ruby objects
puts "5. Special Ruby Objects:"

# Class objects
puts "Class object:"
Rich.print_inspect(String)

# Method objects
puts "\nMethod object:"
method_obj = "hello".method(:upcase)
Rich.print_inspect(method_obj)

# Proc objects
puts "\nProc object:"
my_proc = proc { |x| x * 2 }
Rich.print_inspect(my_proc)

# Module
puts "\nModule:"
Rich.print_inspect(Enumerable)

puts "\n" + "─" * 60

# Example 6: Using the rich_inspect extension
puts "6. Using Object#rich_inspect Extension:"

data = {
  numbers: [1, 2, 3, 4, 5],
  person: Person.new("David", 28, ["photography", "travel"]),
  metadata: {
    created_at: Time.now,
    version: "1.0.0",
    tags: [:important, :processed, :verified]
  }
}

puts "Using rich_inspect method:"
console.print(data.rich_inspect)

puts "\nWith custom options:"
console.print(data.rich_inspect(max_depth: 2, show_class: false))

puts "\n" + "─" * 60

# Example 7: Circular references handling
puts "7. Deep nesting and complex structures:"

class Node
  attr_accessor :value, :children
  
  def initialize(value)
    @value = value
    @children = []
  end
  
  def add_child(child)
    @children << child
  end
end

# Create a tree structure
root = Node.new("root")
child1 = Node.new("child1")
child2 = Node.new("child2")
grandchild = Node.new("grandchild")

root.add_child(child1)
root.add_child(child2)
child1.add_child(grandchild)

puts "Tree structure:"
Rich.print_inspect(root)

puts "\nWith max_depth 2:"
Rich.print_inspect(root, max_depth: 2)

puts "\n" + "─" * 60

# Example 8: String truncation
puts "8. String Truncation:"

long_string = "This is a very long string that should be truncated because it exceeds the maximum string length limit that we set for display purposes in the Rich inspect functionality."

puts "Long string (default max_string):"
Rich.print_inspect(long_string)

puts "\nLong string (max_string: 30):"
Rich.print_inspect(long_string, max_string: 30)

puts "\nLong string (max_string: 100):"
Rich.print_inspect(long_string, max_string: 100)

puts "\n🎉 Rich inspect demo completed!"
puts "\nThe Rich inspect functionality provides beautiful, structured"
puts "visualization of Ruby objects with syntax highlighting and"
puts "intelligent formatting based on object complexity."