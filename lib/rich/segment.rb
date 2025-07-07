# frozen_string_literal: true

require_relative "style"

module Rich
  # A piece of text with associated style information
  # Equivalent to Python's rich.segment.Segment
  class Segment
    attr_reader :text, :style, :control

    def initialize(text, style = nil, control = nil)
      @text = text.to_s
      @style = style
      @control = control
    end

    def ==(other)
      other.is_a?(Segment) &&
        text == other.text &&
        style == other.style &&
        control == other.control
    end

    def copy_with(text: nil, style: nil, control: nil)
      Segment.new(
        text || @text,
        style || @style,
        control || @control
      )
    end

    # Check if segment contains control codes
    def control?
      !@control.nil?
    end

    # Get cell length of the segment text
    def cell_length
      return 0 if control?
      # Simple implementation - could be enhanced with Unicode width calculation
      @text.length
    end

    # Split segment at given offset
    def split(offset)
      if offset >= @text.length
        [self, Segment.new("", @style, @control)]
      else
        [
          Segment.new(@text[0...offset], @style, @control),
          Segment.new(@text[offset..-1], @style, @control)
        ]
      end
    end

    # Class methods for creating common segments
    def self.line
      new("\n")
    end

    def self.apply_style(segments, style = nil)
      return segments unless style

      segments.map do |segment|
        if segment.control?
          segment
        else
          combined_style = segment.style ? Style.combine(segment.style, style) : style
          segment.copy_with(style: combined_style)
        end
      end
    end

    # Simplify segments by combining adjacent segments with same style
    def self.simplify(segments)
      return [] if segments.empty?

      simplified = []
      current_segment = segments.first

      segments[1..-1].each do |segment|
        if !current_segment.control? && 
           !segment.control? && 
           current_segment.style == segment.style
          # Combine text
          current_segment = Segment.new(
            current_segment.text + segment.text,
            current_segment.style
          )
        else
          simplified << current_segment
          current_segment = segment
        end
      end

      simplified << current_segment
      simplified
    end

    # Split segments into lines
    def self.split_lines(segments)
      lines = []
      current_line = []

      segments.each do |segment|
        if segment.text.include?("\n")
          parts = segment.text.split("\n", -1)
          
          # Add first part to current line
          current_line << segment.copy_with(text: parts.first) if parts.first
          lines << current_line
          
          # Add middle parts as complete lines
          parts[1...-1].each do |part|
            lines << [segment.copy_with(text: part)]
          end
          
          # Start new line with last part
          current_line = []
          if parts.last && !parts.last.empty?
            current_line << segment.copy_with(text: parts.last)
          end
        else
          current_line << segment
        end
      end

      lines << current_line if current_line.any?
      lines
    end

    # Get length of segments in cells
    def self.get_line_length(segments)
      segments.sum(&:cell_length)
    end

    # Pad line to given width
    def self.pad_line(segments, width, style = nil, pad_character = " ")
      line_length = get_line_length(segments)
      if line_length < width
        padding = pad_character * (width - line_length)
        segments + [Segment.new(padding, style)]
      else
        segments
      end
    end

    def to_s
      @text
    end

    def inspect
      "#<Segment:#{object_id} text=#{@text.inspect} style=#{@style} control=#{@control}>"
    end
  end
end