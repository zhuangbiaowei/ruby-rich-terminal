# frozen_string_literal: true

require "tty-screen"
require "tty-color"
require "cgi"
require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "markup"
require_relative "text"

module Rich
  # Main console class for rendering rich content
  # Equivalent to Python's rich.console.Console
  class Console
    attr_reader :file, :width, :height, :color_system, :force_terminal, :force_jupyter, :force_interactive
    attr_accessor :quiet, :stderr

    def initialize(
      color_system: "auto",
      force_terminal: nil,
      force_jupyter: nil,
      force_interactive: nil,
      file: $stdout,
      quiet: false,
      stderr: false,
      style: nil,
      width: nil,
      height: nil,
      tab_size: 8,
      record: false
    )
      @file = stderr ? $stderr : file
      @color_system = color_system
      @force_terminal = force_terminal
      @force_jupyter = force_jupyter
      @force_interactive = force_interactive
      @quiet = quiet
      @stderr = stderr
      @tab_size = tab_size
      @record = record
      
      # Determine terminal capabilities
      @width = width || (is_terminal? ? TTY::Screen.width : 80)
      @height = height || (is_terminal? ? TTY::Screen.height : 25)
      
      # Color support detection
      @color_system = detect_color_system if @color_system == "auto"
      
      # Style and markup support
      @default_style = style
      @markup_processor = Markup.new
      
      # Recording for testing
      @recorded_segments = [] if @record
    end

    # Main print method
    def print(*objects, sep: " ", end_str: "\n", style: nil, justify: nil, overflow: "fold", 
              no_wrap: false, emoji: true, markup: false, highlight: false, width: nil, crop: true, 
              soft_wrap: false, new_line_start: false)
      return if @quiet

      # Convert objects to renderables
      renderables = objects.map { |obj| make_renderable(obj, markup: markup) }
      
      # Join with separator if multiple objects
      if renderables.length > 1
        combined = renderables.map(&:to_s).join(sep.to_s)
        renderables = [make_renderable(combined, markup: markup)]
      end

      # Apply console-level style
      applied_style = @default_style ? Style.combine(@default_style, Style.parse(style)) : Style.parse(style)

      # Render each object
      renderables.each do |renderable|
        options = RenderOptions.new(
          max_width: width || @width,
          justify: justify,
          overflow: overflow,
          no_wrap: no_wrap,
          highlight: highlight,
          markup: markup
        )

        segments = render(renderable, options)
        segments = Segment.apply_style(segments, applied_style) if applied_style

        write_segments(segments)
      end

      # Write end string
      write(end_str) unless end_str.empty?
    end

    # Render method - converts renderable to segments
    def render(renderable, options = nil)
      options ||= RenderOptions.new(max_width: @width)
      
      if renderable.respond_to?(:__rich_console__)
        segments = renderable.__rich_console__(self, options)
      else
        # Convert to text and render
        text_obj = make_renderable(renderable)
        segments = text_obj.__rich_console__(self, options)
      end

      # Record segments if recording enabled
      @recorded_segments.concat(segments) if @record

      segments
    end

    # Convert object to renderable
    def make_renderable(obj, markup: false)
      case obj
      when String
        if markup
          @markup_processor.parse(obj)
        else
          Text.new(obj)
        end
      when Renderable, ->(_) { _.respond_to?(:__rich_console__) }
        obj
      else
        Text.new(obj.to_s)
      end
    end

    # Write segments to output
    def write_segments(segments)
      return if segments.empty?

      # Convert segments to text with ANSI codes
      text = segments.map do |segment|
        if segment.control?
          segment.text  # Control codes pass through
        elsif segment.style
          segment.style.render(segment.text)
        else
          segment.text
        end
      end.join

      write(text)
    end

    # Low-level write method
    def write(text)
      @file.write(text) unless @quiet
      @file.flush if @file.respond_to?(:flush)
    end

    # Enhanced log method with timestamp and caller info
    def log(*objects, **kwargs)
      timestamp = Time.now.strftime("[%H:%M:%S]")
      caller_info = caller_locations(1, 1).first
      location = "#{File.basename(caller_info.path)}:#{caller_info.lineno}"
      
      # Add timestamp and location prefix
      log_style = Style.parse("dim cyan")
      prefix_segments = [
        Segment.new("#{timestamp} ", log_style),
        Segment.new("#{location} ", log_style)
      ]

      # Render the log content
      options = RenderOptions.new(max_width: @width - 20)  # Leave space for prefix
      content_segments = objects.map { |obj| render(make_renderable(obj), options) }.flatten

      # Combine and output
      all_segments = prefix_segments + content_segments + [Segment.new("\n")]
      write_segments(all_segments)
    end

    # Status context manager equivalent
    def status(status_text, spinner: "dots")
      if block_given?
        status_obj = Status.new(status_text, console: self, spinner: spinner)
        status_obj.start
        begin
          yield
        ensure
          status_obj.stop
        end
      else
        Status.new(status_text, console: self, spinner: spinner)
      end
    end

    # Terminal capability detection
    def is_terminal?
      return @force_terminal unless @force_terminal.nil?
      @file.respond_to?(:tty?) && @file.tty?
    end

    def supports_color?
      return false unless is_terminal?
      TTY::Color.color?
    end

    def cell_length(text)
      # Simple implementation - could be enhanced for Unicode width calculation
      # Remove ANSI escape sequences for length calculation
      clean_text = text.gsub(/\e\[[0-9;]*m/, '')
      clean_text.length
    end

    # Export console content to various formats
    def export_text(clear: true, styles: false)
      return "" unless @record && @recorded_segments

      text = @recorded_segments.map do |segment|
        if styles && segment.style && !segment.control?
          segment.style.render(segment.text)
        else
          segment.text
        end
      end.join

      @recorded_segments.clear if clear
      text
    end

    def export_html(clear: true, inline_styles: false, code_format: nil)
      # HTML export implementation would go here
      # For now, return simple HTML
      text = export_text(clear: false, styles: false)
      @recorded_segments.clear if clear
      
      "<pre>#{CGI.escapeHTML(text)}</pre>"
    end

    # Capture output context manager
    def capture
      old_record = @record
      old_segments = @recorded_segments.dup if @recorded_segments
      
      @record = true
      @recorded_segments = []
      
      yield if block_given?
      
      captured = @recorded_segments.dup
      
      # Restore state
      @record = old_record
      @recorded_segments = old_segments
      
      captured
    end

    # Pager functionality
    def pager(content = nil, styles: false, links: false)
      if content
        # Simple pager implementation
        text = if content.respond_to?(:__rich_console__)
          segments = render(content)
          segments.map(&:text).join
        else
          content.to_s
        end
        
        # For now, just print to stdout (could be enhanced with actual paging)
        puts text
      end
    end

    # Get console size
    def size
      [@width, @height]
    end

    # Alternative screen context
    def screen
      if block_given?
        write("\e[?1049h")  # Enter alternate screen
        begin
          yield
        ensure
          write("\e[?1049l")  # Exit alternate screen
        end
      end
    end

    private

    def detect_color_system
      return "standard" unless is_terminal?
      
      if TTY::Color.support?
        case ENV.fetch("COLORTERM", "").downcase
        when "truecolor", "24bit"
          "truecolor"
        else
          TTY::Color.mode == 256 ? "256" : "standard"
        end
      else
        "standard"
      end
    end
  end
end