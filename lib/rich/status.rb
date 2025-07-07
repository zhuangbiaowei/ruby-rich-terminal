# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"
require_relative "console"

module Rich
  # Status indicator with animated spinners
  # Equivalent to Python's rich.status.Status
  class Status
    include Renderable

    # Built-in spinner definitions
    SPINNERS = {
      "dots" => {
        frames: ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
        interval: 0.08
      },
      "dots2" => {
        frames: ["⠋", "⠙", "⠚", "⠞", "⠖", "⠦", "⠴", "⠲", "⠳", "⠓"],
        interval: 0.08
      },
      "dots3" => {
        frames: ["⠄", "⠆", "⠇", "⠋", "⠙", "⠸", "⠰", "⠠", "⠰", "⠸", "⠙", "⠋", "⠇", "⠆"],
        interval: 0.08
      },
      "line" => {
        frames: ["-", "\\", "|", "/"],
        interval: 0.13
      },
      "pipe" => {
        frames: ["┤", "┘", "┴", "└", "├", "┌", "┬", "┐"],
        interval: 0.1
      },
      "simpleDots" => {
        frames: [".  ", ".. ", "...", "   "],
        interval: 0.4
      },
      "simpleDotsScrolling" => {
        frames: [".  ", ".. ", "...", " ..", "  .", "   "],
        interval: 0.2
      },
      "star" => {
        frames: ["✶", "✸", "✹", "✺", "✹", "✷"],
        interval: 0.12
      },
      "star2" => {
        frames: ["+", "x", "*"],
        interval: 0.12
      },
      "flip" => {
        frames: ["_", "_", "_", "-", "`", "`", "'", "´", "-", "_", "_", "_"],
        interval: 0.07
      },
      "hamburger" => {
        frames: ["☱", "☲", "☴"],
        interval: 0.15
      },
      "growVertical" => {
        frames: ["▁", "▃", "▄", "▅", "▆", "▇", "▆", "▅", "▄", "▃"],
        interval: 0.12
      },
      "growHorizontal" => {
        frames: ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "▊", "▋", "▌", "▍", "▎"],
        interval: 0.12
      },
      "balloon" => {
        frames: [" ", ".", "o", "O", "@", "*", " "],
        interval: 0.14
      },
      "balloon2" => {
        frames: [".", "o", "O", "°", "O", "o", "."],
        interval: 0.12
      },
      "noise" => {
        frames: ["▓", "▒", "░"],
        interval: 0.1
      },
      "bounce" => {
        frames: ["⠁", "⠂", "⠄", "⠂"],
        interval: 0.12
      },
      "boxBounce" => {
        frames: ["▖", "▘", "▝", "▗"],
        interval: 0.12
      },
      "boxBounce2" => {
        frames: ["▌", "▀", "▐", "▄"],
        interval: 0.1
      },
      "triangle" => {
        frames: ["◢", "◣", "◤", "◥"],
        interval: 0.05
      },
      "arc" => {
        frames: ["◜", "◠", "◝", "◞", "◡", "◟"],
        interval: 0.1
      },
      "circle" => {
        frames: ["◡", "⊙", "◠"],
        interval: 0.12
      },
      "squareCorners" => {
        frames: ["◰", "◳", "◲", "◱"],
        interval: 0.18
      },
      "circleQuarters" => {
        frames: ["◴", "◷", "◶", "◵"],
        interval: 0.12
      },
      "circleHalves" => {
        frames: ["◐", "◓", "◑", "◒"],
        interval: 0.05
      },
      "squish" => {
        frames: ["╫", "╪"],
        interval: 0.1
      },
      "toggle" => {
        frames: ["⊶", "⊷"],
        interval: 0.25
      },
      "toggle2" => {
        frames: ["▫", "▪"],
        interval: 0.08
      },
      "toggle3" => {
        frames: ["□", "■"],
        interval: 0.12
      },
      "toggle4" => {
        frames: ["■", "□", "▪", "▫"],
        interval: 0.1
      },
      "toggle5" => {
        frames: ["▮", "▯"],
        interval: 0.1
      },
      "toggle6" => {
        frames: ["ဝ", "၀"],
        interval: 0.3
      },
      "toggle7" => {
        frames: ["⦾", "⦿"],
        interval: 0.08
      },
      "toggle8" => {
        frames: ["◍", "◌"],
        interval: 0.1
      },
      "toggle9" => {
        frames: ["◉", "◎"],
        interval: 0.1
      },
      "toggle10" => {
        frames: ["㊂", "㊀", "㊁"],
        interval: 0.1
      },
      "toggle11" => {
        frames: ["⧇", "⧆"],
        interval: 0.05
      },
      "toggle12" => {
        frames: ["☗", "☖"],
        interval: 0.12
      },
      "toggle13" => {
        frames: ["=", "*", "-"],
        interval: 0.08
      },
      "arrow" => {
        frames: ["←", "↖", "↑", "↗", "→", "↘", "↓", "↙"],
        interval: 0.1
      },
      "arrow2" => {
        frames: ["⬆️ ", "↗️ ", "➡️ ", "↘️ ", "⬇️ ", "↙️ ", "⬅️ ", "↖️ "],
        interval: 0.08
      },
      "arrow3" => {
        frames: ["▹▹▹▹▹", "▸▹▹▹▹", "▹▸▹▹▹", "▹▹▸▹▹", "▹▹▹▸▹", "▹▹▹▹▸"],
        interval: 0.12
      },
      "bouncingBar" => {
        frames: ["[    ]", "[=   ]", "[==  ]", "[=== ]", "[ ===]", "[  ==]", "[   =]", "[    ]", "[   =]", "[  ==]", "[ ===]", "[====]", "[=== ]", "[==  ]", "[=   ]"],
        interval: 0.08
      },
      "bouncingBall" => {
        frames: ["( ●    )", "(  ●   )", "(   ●  )", "(    ● )", "(     ●)", "(    ● )", "(   ●  )", "(  ●   )", "( ●    )", "(●     )"],
        interval: 0.08
      }
    }.freeze

    attr_reader :text, :console, :spinner_name, :style, :speed

    def initialize(
      text,
      console: nil,
      spinner: "dots",
      style: nil,
      speed: 1.0
    )
      @text = text
      @console = console || Rich::Console.new
      @spinner_name = spinner
      @style = style
      @speed = speed
      @spinner_def = SPINNERS[spinner] || SPINNERS["dots"]
      @current_frame = 0
      @thread = nil
      @running = false
      @start_time = nil
    end

    # Start the status indicator
    def start
      return if @running

      @running = true
      @start_time = Time.now
      @current_frame = 0

      @thread = Thread.new do
        begin
          while @running
            # Clear current line and print status
            @console.write("\r\e[K")  # Move to beginning of line and clear
            
            segments = __rich_console__(@console, nil)
            @console.write_segments(segments)
            
            sleep(@spinner_def[:interval] / @speed)
            @current_frame = (@current_frame + 1) % @spinner_def[:frames].length
          end
        rescue => e
          # Handle thread errors gracefully
          @running = false
        end
      end
      
      self
    end

    # Stop the status indicator
    def stop
      if @running
        @running = false
        @thread&.join
        @thread = nil
        
        # Clear the line
        @console.write("\r\e[K")
      end
      
      self
    end

    # Update the status text
    def update(text)
      @text = text
      self
    end

    # Check if the status is running
    def running?
      @running
    end

    # Get current spinner frame
    def current_frame
      @spinner_def[:frames][@current_frame]
    end

    # Use with a block
    def self.show(text, console: nil, spinner: "dots", style: nil, speed: 1.0)
      status = new(text, console: console, spinner: spinner, style: style, speed: speed)
      status.start
      
      if block_given?
        begin
          yield status
        ensure
          status.stop
        end
      else
        status
      end
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      segments = []
      
      # Add spinner frame
      spinner_style = Style.new(color: "cyan", bold: true)
      combined_spinner_style = @style ? Style.combine(spinner_style, @style) : spinner_style
      
      segments << Segment.new(current_frame + " ", combined_spinner_style)
      
      # Add status text
      if @text.respond_to?(:__rich_console__)
        text_segments = @text.__rich_console__(console, options)
        segments.concat(text_segments)
      else
        text_style = @style
        segments << Segment.new(@text.to_s, text_style)
      end
      
      segments
    end

    # Get elapsed time
    def elapsed_time
      @start_time ? Time.now - @start_time : 0
    end

    # List available spinners
    def self.available_spinners
      SPINNERS.keys.sort
    end

    # Get spinner definition
    def self.spinner_info(name)
      SPINNERS[name]
    end

    private

    def ensure_stopped
      stop if @running
    end
  end

  # Convenience methods for status indicators
  module StatusHelpers
    # Show a status indicator while executing a block
    def with_status(text, **options)
      Rich::Status.show(text, **options) do |status|
        yield status
      end
    end

    # Create a new status indicator
    def status(text, **options)
      Rich::Status.new(text, **options)
    end
  end
end