# frozen_string_literal: true

require_relative "style"
require_relative "text"

module Rich
  # Markup parser for Rich console markup
  # Equivalent to Python's rich.markup.MarkupError and render functionality
  class MarkupError < StandardError; end

  class Markup
    # Tag patterns for parsing markup
    TAG_PATTERN = /\[(\/?)([\w\s\-_#\.,=:]+)\]/
    
    def initialize
      @tag_stack = []
    end

    # Parse markup text and return Text object with styles applied
    def parse(markup_text)
      text = Text.new
      position = 0
      @tag_stack = []

      # Find all markup tags
      markup_text.scan(TAG_PATTERN).each do |match|
        tag_match = markup_text.match(TAG_PATTERN, position)
        next unless tag_match

        # Add text before tag
        if tag_match.begin(0) > position
          plain_text = markup_text[position...tag_match.begin(0)]
          text.append(unescape_markup(plain_text))
        end

        is_closing = !match[0].empty?
        tag_name = match[1].strip

        if is_closing
          handle_closing_tag(text, tag_name)
        else
          handle_opening_tag(text, tag_name)
        end

        position = tag_match.end(0)
      end

      # Add remaining text
      if position < markup_text.length
        remaining_text = markup_text[position..-1]
        text.append(unescape_markup(remaining_text))
      end

      # Close any remaining open tags
      while @tag_stack.any?
        close_current_tag(text)
      end

      text
    end

    # Render markup to styled text
    def self.render(markup_text, style: nil, emoji: true)
      parser = new
      text = parser.parse(markup_text)
      text.instance_variable_set(:@style, Style.combine(text.style, Style.parse(style))) if style
      text
    end

    # Escape markup characters
    def self.escape(text)
      text.to_s.gsub(/[\[\]]/, '\\\\\\&')
    end

    # Remove markup tags from text
    def self.strip_markup(markup_text)
      markup_text.gsub(TAG_PATTERN, '')
    end

    private

    def handle_opening_tag(text, tag_name)
      start_position = text.length
      style = parse_tag_style(tag_name)
      
      @tag_stack.push({
        name: tag_name,
        style: style,
        start: start_position
      })
    end

    def handle_closing_tag(text, tag_name)
      # Find matching opening tag
      tag_index = @tag_stack.rindex { |tag| tag[:name] == tag_name }
      
      if tag_index.nil?
        raise MarkupError, "Closing tag '#{tag_name}' with no matching opening tag"
      end

      # Apply style to text range
      tag_info = @tag_stack[tag_index]
      end_position = text.length
      
      if tag_info[:style] && end_position > tag_info[:start]
        text.stylize(tag_info[:style], tag_info[:start], end_position)
      end

      # Remove the tag from stack
      @tag_stack.delete_at(tag_index)
    end

    def close_current_tag(text)
      return if @tag_stack.empty?
      
      tag_info = @tag_stack.pop
      end_position = text.length
      
      if tag_info[:style] && end_position > tag_info[:start]
        text.stylize(tag_info[:style], tag_info[:start], end_position)
      end
    end

    def parse_tag_style(tag_name)
      return nil if tag_name.empty?

      # Handle common style shortcuts
      case tag_name.downcase
      when "b", "bold"
        Style.new(bold: true)
      when "i", "italic"
        Style.new(italic: true)
      when "u", "underline"
        Style.new(underline: true)
      when "s", "strike", "strikethrough"
        Style.new(strikethrough: true)
      when "dim"
        Style.new(dim: true)
      when "reverse"
        Style.new(reverse: true)
      when "blink"
        Style.new(blink: true)
      else
        # Parse as style string (e.g., "bold red", "red on blue")
        Style.parse(tag_name)
      end
    end

    def unescape_markup(text)
      text.gsub(/\\([\[\]])/, '\\1')
    end
  end

  # Module methods for easy access
  module_function

  def markup_render(markup_text, **kwargs)
    Markup.render(markup_text, **kwargs)
  end

  def markup_escape(text)
    Markup.escape(text)
  end

  def markup_strip(markup_text)
    Markup.strip_markup(markup_text)
  end
end