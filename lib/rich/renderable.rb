# frozen_string_literal: true

module Rich
  # Protocol module for objects that can be rendered by Rich
  # Equivalent to Python's rich.abc.RenderableType
  module Renderable
    # Render method that must be implemented by renderable objects
    # @param console [Console] The console to render to
    # @param options [RenderOptions] Rendering options
    # @return [Array<Segment>] Array of segments to render
    def __rich_console__(console, options)
      raise NotImplementedError, "#{self.class} must implement __rich_console__"
    end

    # Optional method to get measurement for the renderable
    # @param console [Console] The console to measure for
    # @param options [RenderOptions] Rendering options  
    # @return [Measurement] The measurement
    def __rich_measure__(console, options)
      nil
    end
  end

  # Options passed to renderable objects during rendering
  class RenderOptions
    attr_accessor :max_width, :min_width, :justify, :overflow, :no_wrap, :highlight, :markup

    def initialize(
      max_width: nil,
      min_width: 1,
      justify: nil,
      overflow: "fold",
      no_wrap: false,
      highlight: false,
      markup: false
    )
      @max_width = max_width
      @min_width = min_width
      @justify = justify
      @overflow = overflow
      @no_wrap = no_wrap
      @highlight = highlight
      @markup = markup
    end

    def update(**kwargs)
      kwargs.each { |k, v| instance_variable_set("@#{k}", v) }
      self
    end
  end

  # Measurement of renderable content
  class Measurement
    attr_reader :minimum, :maximum

    def initialize(minimum, maximum)
      @minimum = minimum
      @maximum = maximum
    end

    def self.get(console, renderable, max_width)
      if renderable.respond_to?(:__rich_measure__)
        measurement = renderable.__rich_measure__(console, RenderOptions.new(max_width: max_width))
        return measurement if measurement
      end

      # Default measurement - render and measure
      segments = console.render(renderable, RenderOptions.new(max_width: max_width))
      lines = []
      current_line = []
      
      segments.each do |segment|
        if segment.text.include?("\n")
          parts = segment.text.split("\n", -1)
          current_line << parts.first if parts.first
          lines << current_line.join if current_line.any?
          
          parts[1...-1].each { |part| lines << part }
          
          current_line = []
          current_line << parts.last if parts.last && !parts.last.empty?
        else
          current_line << segment.text
        end
      end
      
      lines << current_line.join if current_line.any?
      
      if lines.empty?
        new(0, 0)
      else
        widths = lines.map { |line| console.cell_length(line) }
        new(widths.min, widths.max)
      end
    end
  end
end