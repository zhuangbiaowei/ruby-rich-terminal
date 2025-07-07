# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"
require_relative "rule"
require_relative "syntax"

module Rich
  # Markdown rendering with terminal formatting
  # Simple markdown parser that converts markdown to Rich segments
  class Markdown
    include Renderable

    attr_reader :markup, :code_theme

    def initialize(markup, code_theme: "monokai")
      @markup = markup.to_s
      @code_theme = code_theme
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      segments = []
      lines = @markup.lines.map(&:rstrip)
      
      i = 0
      while i < lines.length
        line = lines[i]
        
        # Skip empty lines but add spacing
        if line.strip.empty?
          segments << Segment.line
          i += 1
          next
        end
        
        # Headers
        if line.match(/^(#+)\s+(.+)$/)
          level = $1.length
          text = $2
          style = header_style(level)
          
          segments << Segment.line if segments.any?
          
          if level <= 2
            rule_style = Style.new(color: style.color)
            segments << Segment.new("─" * 40, rule_style)
            segments << Segment.line
          end
          
          segments << Segment.new("#" * level + " ", style)
          segments << Segment.new(text, style)
          segments << Segment.line
          
          if level <= 2
            segments << Segment.new("─" * 40, Style.new(color: style.color))
            segments << Segment.line
          end
          
        # Code blocks
        elsif line.match(/^```(\w*)/)
          language = $1
          i += 1
          code_lines = []
          
          while i < lines.length && !lines[i].match(/^```/)
            code_lines << lines[i]
            i += 1
          end
          
          code_content = code_lines.join("\n")
          
          segments << Segment.line if segments.any?
          
          if language && !language.empty?
            syntax = Rich::Syntax.new(code_content, language, theme: @code_theme)
            syntax_segments = syntax.__rich_console__(nil, {})
            segments.concat(syntax_segments)
          else
            code_style = Style.new(color: "bright_black", bgcolor: "black")
            code_lines.each do |code_line|
              segments << Segment.new("  ", nil)
              segments << Segment.new(code_line, code_style)
              segments << Segment.line
            end
          end
          
          segments << Segment.line
          
        # Blockquotes
        elsif line.match(/^>\s*(.+)$/)
          quote_text = $1
          quote_style = Style.new(color: "bright_black", italic: true)
          
          segments << Segment.line if segments.any?
          segments << Segment.new("│ ", Style.new(color: "yellow"))
          parse_inline(quote_text, segments)
          segments << Segment.line
          
        # Unordered lists
        elsif line.match(/^[\s]*[-*+]\s+(.+)$/)
          item_text = $1
          indent_level = (line.length - line.lstrip.length) / 2
          indent = "  " * indent_level
          
          marker_style = Style.new(color: "cyan", bold: true)
          segments << Segment.new(indent, nil)
          segments << Segment.new("• ", marker_style)
          parse_inline(item_text, segments)
          segments << Segment.line
          
        # Ordered lists
        elsif line.match(/^[\s]*\d+\.\s+(.+)$/)
          item_text = $1
          indent_level = (line.length - line.lstrip.length) / 3
          indent = "  " * indent_level
          number = line.strip.match(/^(\d+)\./)&.captures&.first || "1"
          
          marker_style = Style.new(color: "cyan", bold: true)
          segments << Segment.new(indent, nil)
          segments << Segment.new("#{number}. ", marker_style)
          parse_inline(item_text, segments)
          segments << Segment.line
          
        # Horizontal rules
        elsif line.match(/^[-*_]{3,}$/)
          segments << Segment.line if segments.any?
          rule_style = Style.new(color: "bright_black")
          segments << Segment.new("━" * 50, rule_style)
          segments << Segment.line
          segments << Segment.line
          
        # Regular paragraphs
        else
          segments << Segment.line if segments.any?
          parse_inline(line, segments)
          segments << Segment.line
        end
        
        i += 1
      end
      
      # Remove trailing empty segments
      while segments.last&.text == "\n"
        segments.pop
      end
      
      segments
    end

    private

    def header_style(level)
      case level
      when 1
        Style.new(color: "bright_magenta", bold: true)
      when 2
        Style.new(color: "bright_cyan", bold: true)
      when 3
        Style.new(color: "bright_yellow", bold: true)
      else
        Style.new(color: "bright_white", bold: true)
      end
    end

    def parse_inline(text, segments)
      # Simple inline parsing for common markdown elements
      remaining = text
      
      while remaining.length > 0
        # Bold text **text**
        if match = remaining.match(/^(.*?)\*\*([^*]+)\*\*(.*)/)
          before, bold_text, after = match.captures
          segments << Segment.new(before, nil) if before.length > 0
          segments << Segment.new(bold_text, Style.new(bold: true))
          remaining = after
          
        # Italic text *text*
        elsif match = remaining.match(/^(.*?)\*([^*]+)\*(.*)/)
          before, italic_text, after = match.captures
          segments << Segment.new(before, nil) if before.length > 0
          segments << Segment.new(italic_text, Style.new(italic: true))
          remaining = after
          
        # Inline code `code`
        elsif match = remaining.match(/^(.*?)`([^`]+)`(.*)/)
          before, code_text, after = match.captures
          segments << Segment.new(before, nil) if before.length > 0
          segments << Segment.new("`#{code_text}`", Style.new(color: "magenta", bgcolor: "black"))
          remaining = after
          
        # Links [text](url)
        elsif match = remaining.match(/^(.*?)\[([^\]]+)\]\(([^)]+)\)(.*)/)
          before, link_text, url, after = match.captures
          segments << Segment.new(before, nil) if before.length > 0
          segments << Segment.new(link_text, Style.new(color: "blue", underline: true))
          segments << Segment.new(" [#{url}]", Style.new(color: "bright_black"))
          remaining = after
          
        # Strikethrough ~~text~~
        elsif match = remaining.match(/^(.*?)~~([^~]+)~~(.*)/)
          before, strike_text, after = match.captures
          segments << Segment.new(before, nil) if before.length > 0
          segments << Segment.new(strike_text, Style.new(strikethrough: true))
          remaining = after
          
        # No more markdown, add the rest as plain text
        else
          segments << Segment.new(remaining, nil) if remaining.length > 0
          break
        end
      end
    end
  end
end