# frozen_string_literal: true

require "logger"
require "time"
require_relative "console"
require_relative "text"
require_relative "style"
require_relative "panel"

module Rich
  # Rich logging system with enhanced formatting
  # Integrates with Ruby's standard Logger but provides Rich formatting
  class RichHandler
    attr_reader :console, :show_time, :show_level, :show_path, :markup, :rich_tracebacks

    def initialize(
      console: nil,
      show_time: true,
      show_level: true,
      show_path: true,
      markup: false,
      rich_tracebacks: false,
      tracebacks_width: nil,
      tracebacks_extra_lines: 3,
      tracebacks_theme: nil,
      tracebacks_word_wrap: false,
      tracebacks_show_locals: false,
      tracebacks_suppress: [],
      locals_max_length: 10,
      locals_max_string: 80
    )
      @console = console || Rich::Console.new
      @show_time = show_time
      @show_level = show_level
      @show_path = show_path
      @markup = markup
      @rich_tracebacks = rich_tracebacks
    end

    # Format a log record for Rich output
    def format(record)
      segments = []
      
      # Add timestamp
      if @show_time
        time_style = Style.new(color: "bright_black", dim: true)
        time_text = record[:time].strftime("%H:%M:%S")
        segments << Text.new("[#{time_text}]", style: time_style)
        segments << Text.new(" ")
      end
      
      # Add log level with color
      if @show_level
        level_style = level_to_style(record[:level])
        level_text = record[:level].to_s.upcase.rjust(8)
        segments << Text.new("[#{level_text}]", style: level_style)
        segments << Text.new(" ")
      end
      
      # Add source path
      if @show_path && record[:path]
        path_style = Style.new(color: "bright_black", dim: true)
        segments << Text.new("#{record[:path]}:", style: path_style)
        segments << Text.new(" ")
      end
      
      # Add the message
      message_style = message_style_for_level(record[:level])
      if @markup
        # TODO: Parse markup in message
        segments << Text.new(record[:message], style: message_style)
      else
        segments << Text.new(record[:message], style: message_style)
      end
      
      segments
    end

    private

    def level_to_style(level)
      case level.to_sym
      when :debug
        Style.new(color: "bright_black", dim: true)
      when :info
        Style.new(color: "blue")
      when :warn
        Style.new(color: "yellow", bold: true)
      when :error
        Style.new(color: "red", bold: true)
      when :fatal
        Style.new(color: "bright_red", bold: true)
      else
        Style.new(color: "white")
      end
    end

    def message_style_for_level(level)
      case level.to_sym
      when :debug
        Style.new(color: "bright_black")
      when :info
        nil # Default color
      when :warn
        Style.new(color: "yellow")
      when :error
        Style.new(color: "red")
      when :fatal
        Style.new(color: "bright_red", bold: true)
      else
        nil
      end
    end
  end

  # Rich Logger class that extends Ruby's Logger
  class Logger < ::Logger
    attr_reader :rich_handler

    def initialize(logdev = $stdout, shift_age: 0, shift_size: 1048576, **rich_options)
      # Initialize standard logger with a custom formatter
      super(logdev, shift_age, shift_size)
      
      @rich_handler = RichHandler.new(**rich_options)
      
      # Set custom formatter
      self.formatter = proc do |severity, datetime, progname, msg|
        record = {
          level: severity.downcase.to_sym,
          time: datetime,
          path: extract_caller_info,
          message: msg.to_s
        }
        
        segments = @rich_handler.format(record)
        
        # Render segments to string
        output = segments.map do |segment|
          if segment.respond_to?(:__rich_console__)
            rendered = segment.__rich_console__(@rich_handler.console, RenderOptions.new(max_width: 80))
            rendered.map { |seg| seg.style ? seg.style.render(seg.text) : seg.text }.join
          else
            segment.to_s
          end
        end.join
        
        output + "\n"
      end
    end

    # Enhanced logging methods with Rich formatting
    def info_panel(title, message, **panel_options)
      panel = create_panel(title, message, :info, **panel_options)
      info(panel_to_string(panel))
    end

    def warn_panel(title, message, **panel_options)
      panel = create_panel(title, message, :warn, **panel_options)
      warn(panel_to_string(panel))
    end

    def error_panel(title, message, **panel_options)
      panel = create_panel(title, message, :error, **panel_options)
      error(panel_to_string(panel))
    end

    def debug_panel(title, message, **panel_options)
      panel = create_panel(title, message, :debug, **panel_options)
      debug(panel_to_string(panel))
    end

    # Log with custom styling
    def styled(level, message, style: nil)
      styled_message = style ? Text.new(message, style: style) : message
      send(level, styled_message)
    end

    # Log an exception with Rich formatting
    def exception(exception, level: :error, message: nil)
      msg = message ? "#{message}: " : ""
      msg += "#{exception.class}: #{exception.message}"
      
      if exception.backtrace
        msg += "\n" + exception.backtrace.first(10).map { |line| "  #{line}" }.join("\n")
      end
      
      send(level, msg)
    end

    private

    def extract_caller_info
      # Find the first caller that's not in this file
      caller_locations(3).find { |loc| !loc.path.end_with?('logging.rb') }&.then do |loc|
        "#{File.basename(loc.path)}:#{loc.lineno}"
      end
    end

    def create_panel(title, message, level, **options)
      border_style = case level
                    when :info
                      Style.new(color: "blue")
                    when :warn
                      Style.new(color: "yellow")
                    when :error, :fatal
                      Style.new(color: "red")
                    when :debug
                      Style.new(color: "bright_black")
                    else
                      Style.new(color: "white")
                    end

      # Note: Panel class needs to be implemented
      # For now, return a simple formatted string
      border_char = case level
                   when :info then "─"
                   when :warn then "─"
                   when :error, :fatal then "═"
                   when :debug then "┄"
                   else "─"
                   end
      
      title_line = "┌#{border_char * 2} #{title} #{border_char * (50 - title.length - 4)}┐"
      content_lines = message.lines.map { |line| "│ #{line.chomp.ljust(48)} │" }
      bottom_line = "└#{border_char * 50}┘"
      
      ([title_line] + content_lines + [bottom_line]).join("\n")
    end

    def panel_to_string(panel)
      panel
    end
  end

  # Module for adding Rich logging to any class
  module Logging
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def logger
        @logger ||= Rich::Logger.new
      end

      def logger=(new_logger)
        @logger = new_logger
      end
    end

    def logger
      self.class.logger
    end

    # Convenience methods
    def log_info(message, **options)
      logger.info(message, **options)
    end

    def log_warn(message, **options)
      logger.warn(message, **options)
    end

    def log_error(message, **options)
      logger.error(message, **options)
    end

    def log_debug(message, **options)
      logger.debug(message, **options)
    end

    def log_exception(exception, **options)
      logger.exception(exception, **options)
    end
  end
end