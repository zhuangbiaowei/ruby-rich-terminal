# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"
require_relative "syntax"

module Rich
  # Rich object inspection with syntax highlighting and formatting
  # Equivalent to Python's rich.pretty.Pretty
  class Inspect
    include Renderable

    attr_reader :obj, :max_length, :max_string, :max_depth, :expand_all, :indent_guides, :show_class

    def initialize(
      obj,
      max_length: 10,
      max_string: 80,
      max_depth: 3,
      expand_all: false,
      indent_guides: true,
      show_class: true,
      syntax_highlighting: true
    )
      @obj = obj
      @max_length = max_length
      @max_string = max_string
      @max_depth = max_depth
      @expand_all = expand_all
      @indent_guides = indent_guides
      @show_class = show_class
      @syntax_highlighting = syntax_highlighting
    end

    # Create from any object
    def self.inspect(obj, **options)
      new(obj, **options)
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      render_object(@obj, 0)
    end

    private

    def render_object(obj, depth, key: nil)
      segments = []

      # Add key if provided (for hash entries)
      if key
        segments.concat(render_key(key))
        segments << Segment.new(": ")
      end

      case obj
      when String
        segments.concat(render_string(obj))
      when Symbol
        segments.concat(render_symbol(obj))
      when Numeric
        segments.concat(render_number(obj))
      when TrueClass, FalseClass
        segments.concat(render_boolean(obj))
      when NilClass
        segments.concat(render_nil)
      when Array
        segments.concat(render_array(obj, depth))
      when Hash
        segments.concat(render_hash(obj, depth))
      when Range
        segments.concat(render_range(obj))
      when Regexp
        segments.concat(render_regexp(obj))
      when Class, Module
        segments.concat(render_class(obj))
      when Method, UnboundMethod, Proc
        segments.concat(render_callable(obj))
      else
        segments.concat(render_custom_object(obj, depth))
      end

      segments
    end

    def render_string(str)
      string_style = Style.new(color: "green")
      
      if str.length > @max_string
        truncated = str[0, @max_string] + "..."
        [Segment.new("\"#{truncated}\"", string_style)]
      else
        [Segment.new("\"#{str}\"", string_style)]
      end
    end

    def render_symbol(sym)
      symbol_style = Style.new(color: "magenta")
      [Segment.new(":#{sym}", symbol_style)]
    end

    def render_number(num)
      number_style = Style.new(color: "cyan")
      [Segment.new(num.to_s, number_style)]
    end

    def render_boolean(bool)
      boolean_style = Style.new(color: "yellow", bold: true)
      [Segment.new(bool.to_s, boolean_style)]
    end

    def render_nil
      nil_style = Style.new(color: "bright_black", dim: true)
      [Segment.new("nil", nil_style)]
    end

    def render_key(key)
      case key
      when String
        key_style = Style.new(color: "blue")
        [Segment.new("\"#{key}\"", key_style)]
      when Symbol
        key_style = Style.new(color: "blue")
        [Segment.new(key.to_s, key_style)]
      else
        render_object(key, 0)
      end
    end

    def render_array(arr, depth)
      segments = []
      bracket_style = Style.new(color: "bright_white", bold: true)
      
      if arr.empty?
        segments << Segment.new("[]", bracket_style)
        return segments
      end

      if depth >= @max_depth && !@expand_all
        segments << Segment.new("[...]", Style.new(color: "bright_black", dim: true))
        return segments
      end

      # Class info if enabled
      if @show_class && arr.class != Array
        segments.concat(render_class_info(arr.class))
        segments << Segment.new(" ")
      end

      segments << Segment.new("[", bracket_style)

      if should_expand_array?(arr, depth)
        segments << Segment.line
        
        arr.first(@max_length).each_with_index do |item, index|
          # Indentation
          segments << Segment.new("  " * (depth + 1))
          
          # Render item
          segments.concat(render_object(item, depth + 1))
          
          # Comma
          segments << Segment.new(",") if index < arr.length - 1
          segments << Segment.line
        end
        
        # Show truncation if needed
        if arr.length > @max_length
          segments << Segment.new("  " * (depth + 1))
          segments << Segment.new("... #{arr.length - @max_length} more items", Style.new(color: "bright_black", dim: true))
          segments << Segment.line
        end
        
        segments << Segment.new("  " * depth)
      else
        # Inline rendering
        arr.first(@max_length).each_with_index do |item, index|
          segments.concat(render_object(item, depth + 1))
          segments << Segment.new(", ") if index < arr.length - 1
        end
        
        if arr.length > @max_length
          segments << Segment.new(", ...", Style.new(color: "bright_black", dim: true))
        end
      end

      segments << Segment.new("]", bracket_style)
      segments
    end

    def render_hash(hash, depth)
      segments = []
      brace_style = Style.new(color: "bright_white", bold: true)
      
      if hash.empty?
        segments << Segment.new("{}", brace_style)
        return segments
      end

      if depth >= @max_depth && !@expand_all
        segments << Segment.new("{...}", Style.new(color: "bright_black", dim: true))
        return segments
      end

      # Class info if enabled
      if @show_class && hash.class != Hash
        segments.concat(render_class_info(hash.class))
        segments << Segment.new(" ")
      end

      segments << Segment.new("{", brace_style)

      if should_expand_hash?(hash, depth)
        segments << Segment.line
        
        hash.first(@max_length).each_with_index do |(key, value), index|
          # Indentation
          segments << Segment.new("  " * (depth + 1))
          
          # Render key-value pair
          segments.concat(render_object(value, depth + 1, key: key))
          
          # Comma
          segments << Segment.new(",") if index < hash.length - 1
          segments << Segment.line
        end
        
        # Show truncation if needed
        if hash.length > @max_length
          segments << Segment.new("  " * (depth + 1))
          segments << Segment.new("... #{hash.length - @max_length} more items", Style.new(color: "bright_black", dim: true))
          segments << Segment.line
        end
        
        segments << Segment.new("  " * depth)
      else
        # Inline rendering
        hash.first(@max_length).each_with_index do |(key, value), index|
          segments.concat(render_key(key))
          segments << Segment.new(": ")
          segments.concat(render_object(value, depth + 1))
          segments << Segment.new(", ") if index < hash.length - 1
        end
        
        if hash.length > @max_length
          segments << Segment.new(", ...", Style.new(color: "bright_black", dim: true))
        end
      end

      segments << Segment.new("}", brace_style)
      segments
    end

    def render_range(range)
      range_style = Style.new(color: "yellow")
      operator = range.exclude_end? ? "..." : ".."
      [Segment.new("#{range.begin}#{operator}#{range.end}", range_style)]
    end

    def render_regexp(regexp)
      regexp_style = Style.new(color: "red")
      [Segment.new("/#{regexp.source}/#{regexp.options}", regexp_style)]
    end

    def render_class(cls)
      class_style = Style.new(color: "bright_blue", bold: true)
      [Segment.new(cls.name || cls.to_s, class_style)]
    end

    def render_callable(callable)
      callable_style = Style.new(color: "bright_green")
      case callable
      when Method
        [Segment.new("#<Method: #{callable.owner}##{callable.name}>", callable_style)]
      when UnboundMethod
        [Segment.new("#<UnboundMethod: #{callable.owner}##{callable.name}>", callable_style)]
      when Proc
        [Segment.new("#<Proc:#{callable.object_id}>", callable_style)]
      end
    end

    def render_class_info(cls)
      class_style = Style.new(color: "bright_black", dim: true)
      [Segment.new("<#{cls.name}>", class_style)]
    end

    def render_custom_object(obj, depth)
      segments = []
      object_style = Style.new(color: "bright_cyan")
      
      # Show class name
      segments << Segment.new("#<#{obj.class.name}:#{sprintf("0x%016x", obj.object_id)}", object_style)
      
      if depth < @max_depth || @expand_all
        # Try to show instance variables
        instance_vars = obj.instance_variables
        
        if instance_vars.any?
          segments << Segment.new(" ")
          
          if should_expand_object?(obj, depth)
            segments << Segment.line
            
            instance_vars.first(@max_length).each_with_index do |var, index|
              value = obj.instance_variable_get(var)
              
              # Indentation
              segments << Segment.new("  " * (depth + 1))
              
              # Variable name
              var_style = Style.new(color: "cyan")
              segments << Segment.new(var.to_s, var_style)
              segments << Segment.new(": ")
              
              # Variable value
              segments.concat(render_object(value, depth + 1))
              
              segments << Segment.new(",") if index < instance_vars.length - 1
              segments << Segment.line
            end
            
            if instance_vars.length > @max_length
              segments << Segment.new("  " * (depth + 1))
              segments << Segment.new("... #{instance_vars.length - @max_length} more variables", Style.new(color: "bright_black", dim: true))
              segments << Segment.line
            end
            
            segments << Segment.new("  " * depth)
          else
            # Inline variables
            instance_vars.first(3).each_with_index do |var, index|
              value = obj.instance_variable_get(var)
              
              var_style = Style.new(color: "cyan")
              segments << Segment.new(var.to_s, var_style)
              segments << Segment.new("=")
              segments.concat(render_object(value, depth + 1))
              segments << Segment.new(", ") if index < [instance_vars.length - 1, 2].min
            end
            
            if instance_vars.length > 3
              segments << Segment.new(", ...", Style.new(color: "bright_black", dim: true))
            end
          end
        end
      end
      
      segments << Segment.new(">", object_style)
      segments
    end

    def should_expand_array?(arr, depth)
      return false if depth > @max_depth && !@expand_all
      arr.length > 3 || arr.any? { |item| complex_object?(item) }
    end

    def should_expand_hash?(hash, depth)
      return false if depth > @max_depth && !@expand_all
      hash.length > 2 || hash.any? { |k, v| complex_object?(k) || complex_object?(v) }
    end

    def should_expand_object?(obj, depth)
      return false if depth > @max_depth && !@expand_all
      obj.instance_variables.length > 2
    end

    def complex_object?(obj)
      case obj
      when String, Symbol, Numeric, TrueClass, FalseClass, NilClass, Range, Regexp
        false
      when Array
        obj.length > 3
      when Hash
        obj.length > 2
      else
        true
      end
    end
  end

  # Add inspect method to all objects
  module InspectExtensions
    def rich_inspect(**options)
      Rich::Inspect.new(self, **options)
    end
  end

  # Convenience methods
  def self.inspect(obj, **options)
    Rich::Inspect.new(obj, **options)
  end

  def self.print_inspect(obj, **options)
    console = Rich::Console.new
    inspector = Rich::Inspect.new(obj, **options)
    console.print(inspector)
  end
end

# Extend Object class
class Object
  include Rich::InspectExtensions
end