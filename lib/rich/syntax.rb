# frozen_string_literal: true

require "rouge"
require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"

module Rich
  # Syntax highlighting for code using Rouge
  # Equivalent to Python's rich.syntax.Syntax
  class Syntax
    include Renderable

    # Simple token style mapping that works with Rouge
    TOKEN_STYLES = {
      Rouge::Token::Tokens::Text => nil,
      Rouge::Token::Tokens::Error => Style.new(color: "red", bold: true),
      Rouge::Token::Tokens::Keyword => Style.new(color: "blue", bold: true),
      Rouge::Token::Tokens::Name => nil,
      Rouge::Token::Tokens::Name::Builtin => Style.new(color: "green"),
      Rouge::Token::Tokens::Name::Class => Style.new(color: "cyan", bold: true),
      Rouge::Token::Tokens::Name::Function => Style.new(color: "yellow", bold: true),
      Rouge::Token::Tokens::Literal::String::Double => Style.new(color: "green"),
      Rouge::Token::Tokens::Literal::Number => Style.new(color: "magenta"),
      Rouge::Token::Tokens::Operator => Style.new(color: "red"),
      Rouge::Token::Tokens::Comment => Style.new(color: "bright_black", dim: true),
      Rouge::Token::Tokens::Punctuation => nil
    }.freeze

    attr_reader :code, :lexer, :theme, :line_numbers, :line_range, :highlight_lines
    attr_reader :code_width, :tab_size, :word_wrap, :background_color, :dedent

    def initialize(
      code,
      lexer = nil,
      theme: "monokai",
      line_numbers: false,
      line_range: nil,
      highlight_lines: nil,
      code_width: nil,
      tab_size: 4,
      word_wrap: false,
      background_color: nil,
      dedent: false,
      padding: [0, 1]
    )
      @code = code.to_s
      @lexer_name = lexer
      @theme = theme
      @line_numbers = line_numbers
      @line_range = line_range
      @highlight_lines = highlight_lines ? Set.new(highlight_lines) : Set.new
      @code_width = code_width
      @tab_size = tab_size
      @word_wrap = word_wrap
      @background_color = background_color
      @dedent = dedent
      @padding = padding.is_a?(Array) ? padding : [0, padding]
      
      @lexer = find_lexer(@lexer_name)
      @processed_code = process_code(@code)
    end

    # Create Syntax from file
    def self.from_path(
      path,
      encoding: "utf-8",
      lexer: nil,
      theme: "monokai",
      line_numbers: false,
      line_range: nil,
      highlight_lines: nil,
      code_width: nil,
      tab_size: 4,
      word_wrap: false,
      background_color: nil,
      dedent: false
    )
      code = File.read(path, encoding: encoding)
      lexer ||= guess_lexer_for_filename(path)
      
      new(
        code,
        lexer,
        theme: theme,
        line_numbers: line_numbers,
        line_range: line_range,
        highlight_lines: highlight_lines,
        code_width: code_width,
        tab_size: tab_size,
        word_wrap: word_wrap,
        background_color: background_color,
        dedent: dedent
      )
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      segments = []
      
      # Get code lines to render
      lines = get_code_lines
      start_line = @line_range ? @line_range.first : 1
      
      lines.each_with_index do |line, index|
        line_number = start_line + index
        line_segments = []
        
        # Add line number if enabled
        if @line_numbers
          line_num_width = lines.length.to_s.length
          line_num_text = line_number.to_s.rjust(line_num_width)
          line_num_style = Style.new(color: "bright_black", dim: true)
          
          line_segments << Segment.new(" " * @padding[1]) if @padding[1] > 0
          line_segments << Segment.new(line_num_text, line_num_style)
          line_segments << Segment.new(" │ ", line_num_style)
        else
          line_segments << Segment.new(" " * @padding[1]) if @padding[1] > 0
        end
        
        # Highlight line background if in highlight_lines
        line_style = nil
        if @highlight_lines.include?(line_number)
          line_style = Style.new(bgcolor: "yellow", color: "black")
        end
        
        # Tokenize and style the line
        code_segments = highlight_line(line)
        
        # Apply line highlighting
        if line_style
          code_segments = code_segments.map do |segment|
            combined_style = segment.style ? Style.combine(segment.style, line_style) : line_style
            segment.copy_with(style: combined_style)
          end
        end
        
        line_segments.concat(code_segments)
        line_segments << Segment.new(" " * @padding[1]) if @padding[1] > 0
        
        # Add line to segments
        segments.concat(line_segments)
        segments << Segment.line if index < lines.length - 1
      end
      
      segments
    end

    private

    def find_lexer(lexer_name)
      return Rouge::Lexers::PlainText.new unless lexer_name
      
      if lexer_name.is_a?(String)
        # Try to find lexer by name, alias or filename
        lexer_class = Rouge::Lexer.find(lexer_name) || Rouge::Lexer.guess(filename: lexer_name)
        lexer_class&.new || Rouge::Lexers::PlainText.new
      else
        lexer_name
      end
    end

    def self.guess_lexer_for_filename(filename)
      extension = File.extname(filename).downcase
      
      case extension
      when ".rb", ".rake", ".gemspec"
        "ruby"
      when ".py"
        "python"
      when ".js", ".mjs"
        "javascript"
      when ".ts"
        "typescript"
      when ".java"
        "java"
      when ".c", ".h"
        "c"
      when ".cpp", ".cc", ".cxx", ".hpp"
        "cpp"
      when ".go"
        "go"
      when ".rs"
        "rust"
      when ".php"
        "php"
      when ".sh", ".bash"
        "bash"
      when ".sql"
        "sql"
      when ".html", ".htm"
        "html"
      when ".css"
        "css"
      when ".xml"
        "xml"
      when ".json"
        "json"
      when ".yaml", ".yml"
        "yaml"
      when ".md"
        "markdown"
      else
        Rouge::Lexer.guess(filename: filename)&.tag || "text"
      end
    end

    def process_code(code)
      processed = code.dup
      
      # Remove common indentation if dedent is enabled
      if @dedent
        lines = processed.lines
        return processed if lines.empty?
        
        # Find minimum indentation
        min_indent = lines.reject(&:strip.empty?).map { |line| line[/^ */].length }.min || 0
        if min_indent > 0
          processed = lines.map { |line| line.strip.empty? ? line : line[min_indent..-1] }.join
        end
      end
      
      # Expand tabs
      processed = processed.gsub(/\t/, " " * @tab_size)
      
      processed
    end

    def get_code_lines
      lines = @processed_code.lines.map(&:chomp)
      
      if @line_range
        start_idx = [@line_range.first - 1, 0].max
        end_idx = [@line_range.last - 1, lines.length - 1].min
        lines[start_idx..end_idx] || []
      else
        lines
      end
    end

    def highlight_line(line)
      return [Segment.new(line)] if line.strip.empty?
      
      segments = []
      tokens = @lexer.lex(line)
      
      tokens.each do |token_type, value|
        style = get_token_style(token_type)
        segments << Segment.new(value, style)
      end
      
      # Fallback for plain text
      segments = [Segment.new(line)] if segments.empty?
      
      segments
    end

    def get_token_style(token_type)
      # Look up style for exact token type
      style = TOKEN_STYLES[token_type]
      return style if style
      
      # Try parent token types by walking up the hierarchy
      current = token_type
      while current && current.respond_to?(:parent) && current != Rouge::Token
        current = current.parent
        style = TOKEN_STYLES[current]
        return style if style
      end
      
      nil
    end
  end
end