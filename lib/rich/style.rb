# frozen_string_literal: true

require "tty-color"

module Rich
  # Style class for text formatting
  # Equivalent to Python's rich.style.Style
  class Style
    attr_reader :color, :bgcolor, :bold, :dim, :italic, :underline, :strikethrough, :reverse, :blink, :link

    def initialize(
      color: nil,
      bgcolor: nil,
      bold: nil,
      dim: nil,
      italic: nil,
      underline: nil,
      strikethrough: nil,
      reverse: nil,
      blink: nil,
      link: nil
    )
      @color = color
      @bgcolor = bgcolor
      @bold = bold
      @dim = dim
      @italic = italic
      @underline = underline
      @strikethrough = strikethrough
      @reverse = reverse
      @blink = blink
      @link = link
    end

    def ==(other)
      other.is_a?(Style) &&
        color == other.color &&
        bgcolor == other.bgcolor &&
        bold == other.bold &&
        dim == other.dim &&
        italic == other.italic &&
        underline == other.underline &&
        strikethrough == other.strikethrough &&
        reverse == other.reverse &&
        blink == other.blink &&
        link == other.link
    end

    def hash
      [color, bgcolor, bold, dim, italic, underline, strikethrough, reverse, blink, link].hash
    end

    # Create new style with updated attributes
    def copy(**kwargs)
      Style.new(
        color: kwargs.fetch(:color, @color),
        bgcolor: kwargs.fetch(:bgcolor, @bgcolor),
        bold: kwargs.fetch(:bold, @bold),
        dim: kwargs.fetch(:dim, @dim),
        italic: kwargs.fetch(:italic, @italic),
        underline: kwargs.fetch(:underline, @underline),
        strikethrough: kwargs.fetch(:strikethrough, @strikethrough),
        reverse: kwargs.fetch(:reverse, @reverse),
        blink: kwargs.fetch(:blink, @blink),
        link: kwargs.fetch(:link, @link)
      )
    end

    # Combine two styles, with other taking precedence
    def self.combine(style1, style2)
      return style2 unless style1
      return style1 unless style2

      Style.new(
        color: style2.color || style1.color,
        bgcolor: style2.bgcolor || style1.bgcolor,
        bold: style2.bold.nil? ? style1.bold : style2.bold,
        dim: style2.dim.nil? ? style1.dim : style2.dim,
        italic: style2.italic.nil? ? style1.italic : style2.italic,
        underline: style2.underline.nil? ? style1.underline : style2.underline,
        strikethrough: style2.strikethrough.nil? ? style1.strikethrough : style2.strikethrough,
        reverse: style2.reverse.nil? ? style1.reverse : style2.reverse,
        blink: style2.blink.nil? ? style1.blink : style2.blink,
        link: style2.link || style1.link
      )
    end

    # Parse style from string (e.g., "bold red on blue")
    def self.parse(style_string)
      return nil if style_string.nil?
      return style_string if style_string.is_a?(Style)
      return nil if style_string.to_s.empty?

      parts = style_string.strip.split(/\s+/)
      style_attrs = {}

      i = 0
      while i < parts.length
        part = parts[i].downcase

        case part
        when "bold"
          style_attrs[:bold] = true
        when "dim"
          style_attrs[:dim] = true
        when "italic"
          style_attrs[:italic] = true
        when "underline"
          style_attrs[:underline] = true
        when "strikethrough"
          style_attrs[:strikethrough] = true
        when "reverse"
          style_attrs[:reverse] = true
        when "blink"
          style_attrs[:blink] = true
        when "on"
          # Background color follows "on"
          i += 1
          if i < parts.length
            style_attrs[:bgcolor] = parse_color(parts[i])
          end
        else
          # Assume it's a color
          style_attrs[:color] = parse_color(part)
        end

        i += 1
      end

      new(**style_attrs)
    end

    # Convert to ANSI escape codes
    def render(text = "")
      return text if null?

      codes = []

      # Foreground color
      if @color
        color_code = color_to_ansi(@color, background: false)
        codes << color_code if color_code
      end

      # Background color
      if @bgcolor
        bgcolor_code = color_to_ansi(@bgcolor, background: true)
        codes << bgcolor_code if bgcolor_code
      end

      # Text attributes
      codes << "1" if @bold
      codes << "2" if @dim
      codes << "3" if @italic
      codes << "4" if @underline
      codes << "9" if @strikethrough
      codes << "7" if @reverse
      codes << "5" if @blink

      if codes.any?
        "\e[#{codes.join(';')}m#{text}\e[0m"
      else
        text
      end
    end

    # Check if style has no attributes set
    def null?
      [@color, @bgcolor, @bold, @dim, @italic, @underline, @strikethrough, @reverse, @blink].all?(&:nil?)
    end

    private

    def self.parse_color(color_name)
      # Map common color names
      color_map = {
        "black" => 0,
        "red" => 1,
        "green" => 2,
        "yellow" => 3,
        "blue" => 4,
        "magenta" => 5,
        "cyan" => 6,
        "white" => 7,
        "bright_black" => 8,
        "bright_red" => 9,
        "bright_green" => 10,
        "bright_yellow" => 11,
        "bright_blue" => 12,
        "bright_magenta" => 13,
        "bright_cyan" => 14,
        "bright_white" => 15
      }

      color_map[color_name.downcase] || color_name
    end

    def color_to_ansi(color, background: false)
      base = background ? 40 : 30

      case color
      when Integer
        if color < 8
          (base + color).to_s
        elsif color < 16
          "#{base + 60};#{color - 8}"
        else
          background ? "48;5;#{color}" : "38;5;#{color}"
        end
      when String
        # Handle hex colors or named colors
        if color.match?(/^#[0-9a-fA-F]{6}$/)
          # Convert hex to RGB
          r = color[1..2].to_i(16)
          g = color[3..4].to_i(16)
          b = color[5..6].to_i(16)
          background ? "48;2;#{r};#{g};#{b}" : "38;2;#{r};#{g};#{b}"
        else
          color_num = self.class.parse_color(color)
          color_to_ansi(color_num, background: background) if color_num.is_a?(Integer)
        end
      end
    end

    def to_s
      parts = []
      parts << "color=#{@color}" if @color
      parts << "bgcolor=#{@bgcolor}" if @bgcolor
      parts << "bold" if @bold
      parts << "dim" if @dim
      parts << "italic" if @italic
      parts << "underline" if @underline
      parts << "strikethrough" if @strikethrough
      parts << "reverse" if @reverse
      parts << "blink" if @blink
      parts << "link=#{@link}" if @link

      parts.empty? ? "none" : parts.join(" ")
    end

    def inspect
      "#<Style:#{object_id} #{self}>"
    end
  end
end