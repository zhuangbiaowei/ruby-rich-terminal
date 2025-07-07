# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"

module Rich
  # Rich text class with styling support
  # Equivalent to Python's rich.text.Text
  class Text
    include Renderable
    
    attr_reader :plain, :style, :justify, :overflow, :no_wrap, :end_str, :tab_size, :spans

    def initialize(
      text = "",
      style: nil,
      justify: nil,
      overflow: "fold",
      no_wrap: false,
      end_str: "",
      tab_size: 8
    )
      @plain = text.to_s
      @style = Style.parse(style)
      @justify = justify
      @overflow = overflow
      @no_wrap = no_wrap
      @end_str = end_str
      @tab_size = tab_size
      @spans = []  # Array of [start, end, style] tuples
    end

    def length
      @plain.length
    end

    def empty?
      @plain.empty?
    end

    # Add styled span to text
    def stylize(style, start = 0, end_pos = nil)
      end_pos ||= @plain.length
      return self if start >= end_pos

      style_obj = style.is_a?(Style) ? style : Style.parse(style)
      return self unless style_obj
      
      @spans << [start, end_pos, style_obj]
      @spans.sort_by! { |span| [span[0], -span[1]] }  # Sort by start, then by end descending
      self
    end

    # Append text with optional style
    def append(text, style = nil)
      start_pos = @plain.length
      @plain += text.to_s
      if style
        style_obj = style.is_a?(Style) ? style : Style.parse(style)
        stylize(style_obj, start_pos) if style_obj
      end
      self
    end

    # Copy text object
    def copy
      new_text = Text.new(@plain, style: @style, justify: @justify, overflow: @overflow, 
                         no_wrap: @no_wrap, end_str: @end_str, tab_size: @tab_size)
      new_text.instance_variable_set(:@spans, @spans.dup)
      new_text
    end

    # Split text at given index
    def split(separator = "\n", include_separator = false)
      if separator == "\n"
        lines = @plain.split("\n", -1)
        line_texts = []
        offset = 0

        lines.each_with_index do |line, index|
          line_end = offset + line.length
          line_text = Text.new(line, style: @style, justify: @justify, overflow: @overflow,
                              no_wrap: @no_wrap, end_str: @end_str, tab_size: @tab_size)
          
          # Apply spans that overlap with this line
          @spans.each do |start_pos, end_pos, span_style|
            line_start = [start_pos - offset, 0].max
            line_end_pos = [end_pos - offset, line.length].min
            
            if line_start < line_end_pos && line_start < line.length && line_end_pos > 0
              line_text.stylize(span_style, line_start, line_end_pos)
            end
          end

          line_texts << line_text
          offset = line_end + 1  # +1 for the newline character
        end

        line_texts
      else
        # General split implementation
        parts = @plain.split(separator)
        parts.map { |part| Text.new(part, style: @style) }
      end
    end

    # Pad text to given width
    def pad(width, character = " ", style = nil)
      current_width = @plain.length
      return self if current_width >= width

      padding_needed = width - current_width
      padding = character * padding_needed
      
      if style
        append(padding, style)
      else
        @plain += padding
      end
      
      self
    end

    # Pad left
    def pad_left(width, character = " ")
      current_width = @plain.length
      return self if current_width >= width

      padding_needed = width - current_width
      padding = character * padding_needed
      
      @plain = padding + @plain
      
      # Adjust span positions
      @spans.map! { |start_pos, end_pos, style| [start_pos + padding_needed, end_pos + padding_needed, style] }
      
      self
    end

    # Truncate text to given width
    def truncate(width, suffix = "…", overflow: "ellipsis")
      return self if @plain.length <= width

      case overflow
      when "ellipsis"
        if width <= suffix.length
          @plain = suffix[0...width]
        else
          @plain = @plain[0...(width - suffix.length)] + suffix
        end
        
        # Remove spans that are now out of bounds
        @spans.select! { |start_pos, end_pos, _| start_pos < @plain.length }
        @spans.map! { |start_pos, end_pos, style| [start_pos, [@plain.length, end_pos].min, style] }
      when "crop"
        @plain = @plain[0...width]
        @spans.select! { |start_pos, end_pos, _| start_pos < width }
        @spans.map! { |start_pos, end_pos, style| [start_pos, [width, end_pos].min, style] }
      end

      self
    end

    # Expand tabs
    def expand_tabs(tab_size = nil)
      tab_size ||= @tab_size
      if @plain.include?("\t")
        @plain = @plain.gsub("\t", " " * tab_size)
      end
      self
    end

    # Remove markup from text
    def self.from_markup(markup_text, style: nil, emoji: true)
      # This would integrate with the Markup parser
      # For now, return plain text
      text = Text.new(markup_text, style: style)
      # TODO: Parse markup and apply styles
      text
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      text = @plain.dup
      
      # Expand tabs
      text = text.gsub("\t", " " * @tab_size) if text.include?("\t")
      
      # Handle word wrapping if needed
      segments = if options.no_wrap || @no_wrap
        create_segments(text)
      else
        wrap_text(text, options.max_width)
      end

      # Apply end character if specified
      segments << Segment.new(@end_str) unless @end_str.empty?
      
      segments
    end

    def to_s
      @plain
    end

    def inspect
      "#<Text:#{object_id} #{@plain.inspect} spans=#{@spans.length}>"
    end

    private

    # Create segments with style spans applied
    def create_segments(text)
      return [Segment.new(text, @style)] if @spans.empty?

      segments = []
      position = 0
      
      # Sort spans by start position
      sorted_spans = @spans.sort_by { |start_pos, end_pos, _| [start_pos, -end_pos] }
      
      # Create segments, applying overlapping styles
      while position < text.length
        # Find all spans that include current position
        active_spans = sorted_spans.select { |start_pos, end_pos, _| start_pos <= position && position < end_pos }
        
        # Find next boundary (start or end of any span)
        next_boundary = text.length
        sorted_spans.each do |start_pos, end_pos, _|
          next_boundary = [next_boundary, start_pos].min if start_pos > position
          next_boundary = [next_boundary, end_pos].min if end_pos > position
        end
        
        # Create segment for this range
        segment_text = text[position...next_boundary]
        
        # Combine all active styles
        combined_style = @style
        active_spans.each do |_, _, span_style|
          combined_style = combined_style ? Style.combine(combined_style, span_style) : span_style
        end
        
        segments << Segment.new(segment_text, combined_style) unless segment_text.empty?
        position = next_boundary
      end
      
      segments
    end

    # Simple word wrapping implementation
    def wrap_text(text, max_width)
      return create_segments(text) if max_width <= 0

      lines = text.split("\n")
      all_segments = []

      lines.each_with_index do |line, line_index|
        if line.length <= max_width
          all_segments.concat(create_segments_for_range(line, 0, line.length, line_index))
        else
          # Wrap line
          position = 0
          while position < line.length
            end_pos = [position + max_width, line.length].min
            
            # Try to break at word boundary
            if end_pos < line.length && line[end_pos] != " "
              space_pos = line.rindex(" ", end_pos)
              end_pos = space_pos if space_pos && space_pos > position
            end
            
            segment_text = line[position...end_pos].rstrip
            all_segments.concat(create_segments_for_range(segment_text, position, end_pos, line_index))
            all_segments << Segment.new("\n") if end_pos < line.length
            
            position = end_pos
            position += 1 while position < line.length && line[position] == " "  # Skip spaces
          end
        end
        
        all_segments << Segment.new("\n") if line_index < lines.length - 1
      end

      all_segments
    end

    def create_segments_for_range(text, start_offset, end_offset, line_index)
      # This is a simplified version - would need more complex logic for multi-line spans
      create_segments(text)
    end
  end
end