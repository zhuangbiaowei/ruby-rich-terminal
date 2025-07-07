#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "../lib/rich"

console = Rich::Console.new

puts "=== Rich Ruby Tree Structure Demo ===\n"

# Example 1: File system structure
puts "1. File System Structure:"
file_tree = Rich::Tree.new("📁 project/", style: Rich::Style.new(color: "blue", bold: true))

# Add directories and files
src = file_tree.add("📁 src/", style: Rich::Style.new(color: "blue"))
src.add("📄 main.rb", style: Rich::Style.new(color: "green"))
src.add("📄 utils.rb", style: Rich::Style.new(color: "green"))

models = src.add("📁 models/", style: Rich::Style.new(color: "blue"))
models.add("📄 user.rb", style: Rich::Style.new(color: "green"))
models.add("📄 product.rb", style: Rich::Style.new(color: "green"))

lib = file_tree.add("📁 lib/", style: Rich::Style.new(color: "blue"))
lib.add("📄 config.rb", style: Rich::Style.new(color: "green"))

tests = file_tree.add("📁 test/", style: Rich::Style.new(color: "blue"))
tests.add("📄 test_helper.rb", style: Rich::Style.new(color: "yellow"))
tests.add("📄 user_test.rb", style: Rich::Style.new(color: "yellow"))

file_tree.add("📄 Gemfile", style: Rich::Style.new(color: "magenta"))
file_tree.add("📄 README.md", style: Rich::Style.new(color: "cyan"))

console.print(file_tree)
puts

# Example 2: Family tree
puts "2. Family Tree:"
family_tree = Rich::Tree.new("👨 John Smith", style: Rich::Style.new(color: "blue", bold: true))

children = family_tree.add("👨‍👩‍👧‍👦 Children", style: Rich::Style.new(color: "green", bold: true))
children.add("👦 Michael Smith", style: Rich::Style.new(color: "cyan"))
children.add("👧 Sarah Smith", style: Rich::Style.new(color: "magenta"))

son_family = children.add("👨 David Smith (married)", style: Rich::Style.new(color: "cyan"))
son_family.add("👧 Emma Smith", style: Rich::Style.new(color: "yellow"))
son_family.add("👦 Lucas Smith", style: Rich::Style.new(color: "yellow"))

console.print(family_tree)
puts

# Example 3: Organization structure
puts "3. Organization Structure:"
org_tree = Rich::Tree.new("🏢 TechCorp Inc.", style: Rich::Style.new(color: "bright_magenta", bold: true))

# Executive level
ceo = org_tree.add("👑 CEO - Alice Johnson", style: Rich::Style.new(color: "red", bold: true))

# Departments
engineering = org_tree.add("⚙️ Engineering", style: Rich::Style.new(color: "blue", bold: true))
frontend = engineering.add("🖥️ Frontend Team", style: Rich::Style.new(color: "cyan"))
frontend.add("👨‍💻 React Developer - Bob Wilson")
frontend.add("👩‍💻 Vue Developer - Carol Davis")

backend = engineering.add("🗄️ Backend Team", style: Rich::Style.new(color: "green"))
backend.add("👨‍💻 Ruby Developer - Dave Miller")
backend.add("👩‍💻 Python Developer - Eve Anderson")

devops = engineering.add("☁️ DevOps Team", style: Rich::Style.new(color: "yellow"))
devops.add("👨‍💻 AWS Engineer - Frank Taylor")

marketing = org_tree.add("📈 Marketing", style: Rich::Style.new(color: "magenta", bold: true))
marketing.add("📊 Digital Marketing - Grace Lee")
marketing.add("✍️ Content Marketing - Henry Brown")

console.print(org_tree)
puts

# Example 4: API structure
puts "4. API Endpoints Structure:"
api_tree = Rich::Tree.new("🌐 API v1", style: Rich::Style.new(color: "bright_green", bold: true))

users_api = api_tree.add("👥 /users", style: Rich::Style.new(color: "blue", bold: true))
users_api.add("GET /users", style: Rich::Style.new(color: "green"))
users_api.add("POST /users", style: Rich::Style.new(color: "yellow"))
users_api.add("GET /users/:id", style: Rich::Style.new(color: "green"))
users_api.add("PUT /users/:id", style: Rich::Style.new(color: "cyan"))
users_api.add("DELETE /users/:id", style: Rich::Style.new(color: "red"))

products_api = api_tree.add("📦 /products", style: Rich::Style.new(color: "magenta", bold: true))
products_api.add("GET /products", style: Rich::Style.new(color: "green"))
products_api.add("POST /products", style: Rich::Style.new(color: "yellow"))

categories = products_api.add("🏷️ /products/:id/categories", style: Rich::Style.new(color: "cyan"))
categories.add("GET /products/:id/categories", style: Rich::Style.new(color: "green"))
categories.add("POST /products/:id/categories", style: Rich::Style.new(color: "yellow"))

orders_api = api_tree.add("🛒 /orders", style: Rich::Style.new(color: "yellow", bold: true))
orders_api.add("GET /orders", style: Rich::Style.new(color: "green"))
orders_api.add("POST /orders", style: Rich::Style.new(color: "yellow"))

console.print(api_tree)
puts

# Example 5: Demonstration of tree manipulation
puts "5. Tree Manipulation Demo:"
demo_tree = Rich::Tree.new("🌳 Demo Tree", style: Rich::Style.new(color: "green", bold: true))

branch1 = demo_tree.add("🌿 Branch 1", style: Rich::Style.new(color: "green"))
branch1.add("🍃 Leaf 1.1")
branch1.add("🍃 Leaf 1.2")

branch2 = demo_tree.add("🌿 Branch 2", style: Rich::Style.new(color: "green"))
branch2.add("🍃 Leaf 2.1")
sub_branch = branch2.add("🌿 Sub Branch 2.2", style: Rich::Style.new(color: "yellow"))
sub_branch.add("🍃 Leaf 2.2.1")
sub_branch.add("🍃 Leaf 2.2.2")

puts "Tree with all branches expanded:"
console.print(demo_tree)

puts "\nTree statistics:"
puts "  Total nodes: #{demo_tree.count}"
puts "  Tree depth: #{demo_tree.depth}"
puts "  Has children: #{demo_tree.has_children?}"

# Find nodes
found_leaves = demo_tree.find("🍃 Leaf 1.1")
puts "  Found nodes with label '🍃 Leaf 1.1': #{found_leaves.length}"

puts "\n🎉 Tree structure demo completed!"