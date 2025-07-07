# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"
require_relative "syntax"
require_relative "panel"

module Rich
  # Enhanced traceback display with syntax highlighting and formatting
  # Equivalent to Python's rich.traceback.Traceback
  class Traceback
    include Renderable

    attr_reader :exception, :show_locals, :width, :extra_lines, :theme, :word_wrap, :indent_guides

    def initialize(
      exception: nil,
      show_locals: false,
      width: 100,
      extra_lines: 3,
      theme: "monokai",
      word_wrap: false,
      indent_guides: true,
      suppress: [],
      max_frames: nil,
      locals_max_length: 10,
      locals_max_string: 80
    )
      @exception = exception
      @show_locals = show_locals
      @width = width
      @extra_lines = extra_lines
      @theme = theme
      @word_wrap = word_wrap
      @indent_guides = indent_guides
      @suppress = Array(suppress)
      @max_frames = max_frames
      @locals_max_length = locals_max_length
      @locals_max_string = locals_max_string
    end

    # Create from current exception
    def self.from_exception(exception = $!, **options)
      new(exception: exception, **options)
    end

    # Install as default exception handler
    def self.install(**options)
      original_handler = Thread.current[:__rich_traceback_original_handler__]
      
      Thread.current[:__rich_traceback_original_handler__] = proc do |exception|
        console = Rich::Console.new(stderr: true)
        traceback = new(exception: exception, **options)
        console.print(traceback)
        
        # Call original handler if it exists
        original_handler&.call(exception)
      end
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      return [Segment.new("No exception to display")] unless @exception

      segments = []
      
      # Header
      segments.concat(render_title)
      segments << Segment.line
      
      # Stack frames
      frames = extract_frames
      frames = frames.last(@max_frames) if @max_frames
      
      frames.reverse.each_with_index do |frame, index|
        segments.concat(render_frame(frame, index, frames.length))
        segments << Segment.line unless index == frames.length - 1
      end
      
      # Exception details
      segments << Segment.line
      segments.concat(render_exception_details)
      
      segments
    end

    private

    def render_title
      title_style = Style.new(color: "bright_red", bold: true)
      [
        Segment.new("╭─ ", Style.new(color: "red")),
        Segment.new("Traceback ", title_style),
        Segment.new("(most recent call last)", Style.new(color: "bright_black", dim: true)),
        Segment.new(" ─╮", Style.new(color: "red"))
      ]
    end

    def extract_frames
      return [] unless @exception&.backtrace_locations

      @exception.backtrace_locations.map do |location|
        {
          path: location.path,
          lineno: location.lineno,
          method: location.label,
          code: extract_code_context(location.path, location.lineno)
        }
      end
    end

    def extract_code_context(file_path, line_number)
      return nil unless File.exist?(file_path) && File.readable?(file_path)

      begin
        lines = File.readlines(file_path)
        total_lines = lines.length
        
        start_line = [1, line_number - @extra_lines].max
        end_line = [total_lines, line_number + @extra_lines].min
        
        context_lines = []
        (start_line..end_line).each do |n|
          line_content = lines[n - 1]&.chomp || ""
          context_lines << {
            number: n,
            content: line_content,
            is_error: n == line_number
          }
        end
        
        context_lines
      rescue => e
        nil
      end
    end

    def render_frame(frame, index, total_frames)
      segments = []
      
      # Frame header
      segments.concat(render_frame_header(frame, index, total_frames))
      segments << Segment.line
      
      # Code context
      if frame[:code]
        segments.concat(render_code_context(frame))
      else
        # No source available
        no_source_style = Style.new(color: "bright_black", dim: true)
        segments << Segment.new("    ", nil)
        segments << Segment.new("# Source code not available", no_source_style)
        segments << Segment.line
      end
      
      # Local variables (if enabled)
      if @show_locals
        segments.concat(render_locals(frame))
      end
      
      segments
    end

    def render_frame_header(frame, index, total_frames)
      file_style = Style.new(color: "bright_blue")
      line_style = Style.new(color: "bright_yellow")
      method_style = Style.new(color: "bright_green")
      
      file_name = File.basename(frame[:path])
      
      [
        Segment.new("│ ", Style.new(color: "red")),
        Segment.new("#{file_name}:", file_style),
        Segment.new("#{frame[:lineno]}", line_style),
        Segment.new(" in ", Style.new(color: "bright_black", dim: true)),
        Segment.new("`#{frame[:method]}'", method_style)
      ]
    end

    def render_code_context(frame)
      segments = []
      
      frame[:code].each do |line_info|
        line_number = line_info[:number]
        content = line_info[:content]
        is_error_line = line_info[:is_error]
        
        # Line number gutter
        gutter_style = if is_error_line
                        Style.new(color: "bright_red", bold: true)
                      else
                        Style.new(color: "bright_black", dim: true)
                      end
        
        segments << Segment.new("│ ", Style.new(color: "red"))
        segments << Segment.new(sprintf("%4d", line_number), gutter_style)
        segments << Segment.new(" │ ", gutter_style)
        
        # Syntax highlight the code
        if content.strip.empty?
          segments << Segment.new(content)
        else
          begin
            # Try to syntax highlight as Ruby
            syntax = Rich::Syntax.new(content, "ruby", theme: @theme)
            syntax_segments = syntax.__rich_console__(nil, {})
            
            # Filter out newlines from syntax segments
            code_segments = syntax_segments.reject { |seg| seg.text == "\n" }
            
            if is_error_line
              # Highlight error line background
              error_bg_style = Style.new(bgcolor: "red", color: "white")
              code_segments = code_segments.map do |seg|
                combined_style = seg.style ? 
                  Style.combine(seg.style, error_bg_style) : 
                  error_bg_style
                seg.copy_with(style: combined_style)
              end
            end
            
            segments.concat(code_segments)
          rescue
            # Fallback to plain text
            content_style = is_error_line ? 
              Style.new(bgcolor: "red", color: "white") : 
              nil
            segments << Segment.new(content, content_style)
          end
        end
        
        segments << Segment.line
      end
      
      segments
    end

    def render_locals(frame)
      # Placeholder for local variable display
      # In a full implementation, this would extract local variables
      # from the stack frame (Ruby doesn't provide easy access to this)
      segments = []
      
      locals_style = Style.new(color: "cyan", dim: true)
      segments << Segment.new("│ ", Style.new(color: "red"))
      segments << Segment.new("    locals: ", locals_style)
      segments << Segment.new("(local variables not available in Ruby)", Style.new(color: "bright_black", dim: true))
      segments << Segment.line
      
      segments
    end

    def render_exception_details
      segments = []
      
      # Exception class and message
      class_style = Style.new(color: "bright_red", bold: true)
      message_style = Style.new(color: "red")
      
      segments << Segment.new("╰─ ", Style.new(color: "red"))
      segments << Segment.new(@exception.class.name, class_style)
      segments << Segment.new(": ", Style.new(color: "red"))
      segments << Segment.new(@exception.message, message_style)
      segments << Segment.new(" ─╯", Style.new(color: "red"))
      
      segments
    end
  end

  # Convenience methods for capturing and displaying exceptions
  module TracebackHelpers
    # Capture and display an exception with Rich formatting
    def rich_traceback(**options)
      yield
    rescue => e
      console = Rich::Console.new(stderr: true)
      traceback = Rich::Traceback.new(exception: e, **options)
      console.print(traceback)
      raise e
    end

    # Display current exception with Rich formatting
    def print_exception(exception = $!, **options)
      console = Rich::Console.new(stderr: true)
      traceback = Rich::Traceback.new(exception: exception, **options)
      console.print(traceback)
    end
  end
end