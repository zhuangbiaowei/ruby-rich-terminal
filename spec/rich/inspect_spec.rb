# frozen_string_literal: true

require "spec_helper"

RSpec.describe Rich::Inspect do
  let(:console) { Rich::Console.new }
  let(:options) { Rich::RenderOptions.new(max_width: 80) }

  describe "#initialize" do
    it "creates an inspector for an object" do
      inspector = described_class.new("hello")
      expect(inspector.obj).to eq("hello")
    end

    it "accepts configuration options" do
      inspector = described_class.new(
        [1, 2, 3],
        max_length: 5,
        max_depth: 2,
        expand_all: true
      )
      
      expect(inspector.max_length).to eq(5)
      expect(inspector.max_depth).to eq(2)
      expect(inspector.expand_all).to eq(true)
    end
  end

  describe ".inspect" do
    it "creates an inspector instance" do
      inspector = described_class.inspect("hello")
      expect(inspector).to be_a(described_class)
      expect(inspector.obj).to eq("hello")
    end
  end

  describe "#__rich_console__" do
    it "renders strings with quotes and color" do
      inspector = described_class.new("hello world")
      segments = inspector.__rich_console__(console, options)
      
      expect(segments).to be_an(Array)
      expect(segments).not_to be_empty
      
      text = segments.map(&:text).join
      expect(text).to include('"hello world"')
    end

    it "renders numbers with color" do
      inspector = described_class.new(42)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("42")
    end

    it "renders symbols with color" do
      inspector = described_class.new(:test)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include(":test")
    end

    it "renders booleans" do
      inspector = described_class.new(true)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("true")
    end

    it "renders nil" do
      inspector = described_class.new(nil)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("nil")
    end

    it "renders arrays with formatting" do
      inspector = described_class.new([1, 2, 3])
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("[")
      expect(text).to include("]")
      expect(text).to include("1")
      expect(text).to include("2")
      expect(text).to include("3")
    end

    it "renders hashes with formatting" do
      inspector = described_class.new({ name: "Alice", age: 30 })
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("{")
      expect(text).to include("}")
      expect(text).to include("name")
      expect(text).to include("Alice")
    end

    it "handles nested structures" do
      nested = { users: [{ name: "Alice" }, { name: "Bob" }] }
      inspector = described_class.new(nested)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("users")
      expect(text).to include("Alice")
      expect(text).to include("Bob")
    end

    it "truncates long arrays" do
      long_array = (1..20).to_a
      inspector = described_class.new(long_array, max_length: 5)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("...")
      expect(text).to include("more items")
    end

    it "limits depth for nested structures" do
      deep_nested = { a: { b: { c: { d: "deep" } } } }
      inspector = described_class.new(deep_nested, max_depth: 2)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("{...}")
    end
  end

  describe "custom objects" do
    class TestClass
      def initialize(name, value)
        @name = name
        @value = value
      end
    end

    it "renders custom objects with instance variables" do
      obj = TestClass.new("test", 42)
      inspector = described_class.new(obj)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("TestClass")
      expect(text).to include("@name")
      expect(text).to include("@value")
    end
  end

  describe "string truncation" do
    it "truncates long strings" do
      long_string = "a" * 100
      inspector = described_class.new(long_string, max_string: 20)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("...")
      expect(text.length).to be < long_string.length + 10
    end
  end

  describe "range rendering" do
    it "renders inclusive ranges" do
      range = (1..10)
      inspector = described_class.new(range)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("1..10")
    end

    it "renders exclusive ranges" do
      range = (1...10)
      inspector = described_class.new(range)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("1...10")
    end
  end

  describe "regex rendering" do
    it "renders regular expressions" do
      regex = /hello\s+world/i
      inspector = described_class.new(regex)
      segments = inspector.__rich_console__(console, options)
      
      text = segments.map(&:text).join
      expect(text).to include("/hello\\s+world/")
    end
  end

  describe Rich::InspectExtensions do
    it "adds rich_inspect method to objects" do
      obj = { test: "value" }
      expect(obj).to respond_to(:rich_inspect)
      
      inspector = obj.rich_inspect
      expect(inspector).to be_a(Rich::Inspect)
      expect(inspector.obj).to eq(obj)
    end
  end

  describe "Rich convenience methods" do
    it "provides Rich.inspect method" do
      inspector = Rich.inspect([1, 2, 3])
      expect(inspector).to be_a(Rich::Inspect)
    end

    it "provides Rich.print_inspect method" do
      expect { Rich.print_inspect("test") }.not_to raise_error
    end
  end
end