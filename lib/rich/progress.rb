# frozen_string_literal: true

require "thread"
require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"

module Rich
  # Progress bar system with customizable display
  # Equivalent to Python's rich.progress
  module Progress
    # Individual progress task
    class TaskID
      attr_reader :id
      
      def initialize(id)
        @id = id
      end
      
      def ==(other)
        other.is_a?(TaskID) && @id == other.id
      end
      
      def hash
        @id.hash
      end
    end

    # Progress task data
    class Task
      attr_accessor :id, :description, :total, :completed, :started, :finished, :visible, :fields, :speed
      attr_reader :start_time, :stop_time, :elapsed_time

      def initialize(id, description, total: 100.0, completed: 0.0, start_time: nil, stop_time: nil, visible: true, fields: {}, speed: nil)
        @id = id
        @description = description
        @total = total.to_f
        @completed = completed.to_f
        @start_time = start_time
        @stop_time = stop_time
        @visible = visible
        @fields = fields
        @speed = speed
        @started = !@start_time.nil?
        @finished = @completed >= @total
        @elapsed_time = 0.0
        update_elapsed_time
      end

      def percentage
        return 0.0 if @total <= 0
        [(@completed / @total * 100.0), 100.0].min
      end

      def remaining
        [@total - @completed, 0.0].max
      end

      def time_remaining
        return nil unless @speed && @speed > 0
        remaining / @speed
      end

      def start
        @start_time = Time.now unless @started
        @started = true
      end

      def stop
        @stop_time = Time.now
        @finished = true
        update_elapsed_time
      end

      def advance(amount = 1.0)
        @completed = [@completed + amount, @total].min
        @finished = @completed >= @total
        update_elapsed_time
      end

      def update(completed: nil, total: nil, advance: nil, description: nil, visible: nil, refresh: false, **fields)
        @completed = completed.to_f if completed
        @total = total.to_f if total
        advance(advance) if advance
        @description = description if description
        @visible = visible unless visible.nil?
        @fields.merge!(fields)
        update_elapsed_time
        @finished = @completed >= @total
      end

      private

      def update_elapsed_time
        if @start_time
          end_time = @stop_time || Time.now
          @elapsed_time = end_time - @start_time
          
          # Calculate speed
          if @elapsed_time > 0
            @speed = @completed / @elapsed_time
          end
        end
      end
    end

    # Progress column base class
    class ProgressColumn
      def render(task)
        raise NotImplementedError
      end

      def get_width(tasks)
        0
      end
    end

    # Text description column
    class TextColumn < ProgressColumn
      def initialize(text_format = "{task.description}", style: nil, justify: "left", markup: true, highlighter: nil, table_column: nil)
        @text_format = text_format
        @style = Style.parse(style)
        @justify = justify
        @markup = markup
        @highlighter = highlighter
        @table_column = table_column
      end

      def render(task)
        text = format_text(@text_format, task)
        Text.new(text, style: @style)
      end

      def get_width(tasks)
        max_width = 0
        tasks.each do |task|
          text = format_text(@text_format, task)
          max_width = [max_width, text.length].max
        end
        max_width
      end

      private

      def format_text(format_string, task)
        # Simple template substitution
        result = format_string.dup
        result.gsub!("{task.description}", task.description)
        result.gsub!("{task.id}", task.id.to_s)
        result.gsub!("{task.completed}", task.completed.to_s)
        result.gsub!("{task.total}", task.total.to_s)
        result.gsub!("{task.percentage:.1f}", "%.1f" % task.percentage)
        result
      end
    end

    # Progress bar column
    class BarColumn < ProgressColumn
      def initialize(bar_width: nil, style: "bar.back", complete_style: "bar.complete", finished_style: "bar.finished", pulse_style: "bar.pulse")
        @bar_width = bar_width
        @style = Style.parse(style)
        @complete_style = Style.parse(complete_style)
        @finished_style = Style.parse(finished_style)
        @pulse_style = Style.parse(pulse_style)
      end

      def render(task)
        width = @bar_width || 20
        if task.total.nil? || task.total <= 0
          # Indeterminate progress
          bar_text = "━" * width
          Text.new(bar_text, style: @pulse_style)
        else
          completed_width = (width * task.percentage / 100).round
          remaining_width = width - completed_width
          
          completed_bar = "━" * completed_width
          remaining_bar = "━" * remaining_width
          
          completed_text = Text.new(completed_bar, style: task.finished ? @finished_style : @complete_style)
          remaining_text = Text.new(remaining_bar, style: @style)
          
          bar_text = Text.new
          bar_text.append(completed_bar, completed_text.style) if completed_width > 0
          bar_text.append(remaining_bar, remaining_text.style) if remaining_width > 0
          bar_text
        end
      end

      def get_width(tasks)
        @bar_width || 20
      end
    end

    # Percentage column
    class PercentageColumn < ProgressColumn
      def initialize(style: nil, justify: "right")
        @style = Style.parse(style)
        @justify = justify
      end

      def render(task)
        percentage = task.percentage
        text = "%6.1f%%" % percentage
        Text.new(text, style: @style)
      end

      def get_width(tasks)
        8  # "100.0%" width
      end
    end

    # Time remaining column
    class TimeRemainingColumn < ProgressColumn
      def initialize(style: nil, compact: false, elapsed_when_finished: false)
        @style = Style.parse(style)
        @compact = compact
        @elapsed_when_finished = elapsed_when_finished
      end

      def render(task)
        if task.finished && @elapsed_when_finished
          text = format_time(task.elapsed_time)
        elsif task.time_remaining
          text = format_time(task.time_remaining)
        else
          text = "--:--"
        end
        
        Text.new(text, style: @style)
      end

      def get_width(tasks)
        8  # "99:59:59" width
      end

      private

      def format_time(seconds)
        return "--:--" if seconds.nil? || seconds.infinite?
        
        hours = (seconds / 3600).to_i
        minutes = ((seconds % 3600) / 60).to_i
        secs = (seconds % 60).to_i
        
        if hours > 0
          "%d:%02d:%02d" % [hours, minutes, secs]
        else
          "%02d:%02d" % [minutes, secs]
        end
      end
    end

    # Speed column
    class SpeedColumn < ProgressColumn
      def initialize(style: nil, suffix: "it/s")
        @style = Style.parse(style)
        @suffix = suffix
      end

      def render(task)
        if task.speed && task.speed > 0
          if task.speed >= 1
            text = "%.1f %s" % [task.speed, @suffix]
          else
            text = "%.2f %s" % [task.speed, @suffix]
          end
        else
          text = "-- %s" % @suffix
        end
        
        Text.new(text, style: @style)
      end

      def get_width(tasks)
        12  # Enough for "999.99 it/s"
      end
    end

    # Main Progress class
    class Progress
      include Renderable

      attr_reader :tasks, :columns, :console, :auto_refresh, :refresh_per_second
      attr_accessor :disable

      def initialize(
        *columns,
        console: nil,
        auto_refresh: true,
        refresh_per_second: 10,
        speed_estimate_period: 30.0,
        transient: false,
        redirect_stdout: true,
        redirect_stderr: true,
        get_time: nil,
        disable: false,
        expand: false
      )
        @columns = columns.empty? ? default_columns : columns
        @console = console || Console.new
        @auto_refresh = auto_refresh
        @refresh_per_second = refresh_per_second
        @speed_estimate_period = speed_estimate_period
        @transient = transient
        @redirect_stdout = redirect_stdout
        @redirect_stderr = redirect_stderr
        @get_time = get_time || -> { Time.now }
        @disable = disable
        @expand = expand

        @tasks = {}
        @next_task_id = 0
        @live_render = nil
        @refresh_thread = nil
        @lock = Mutex.new
      end

      def add_task(description, total: 100.0, start: true, **fields)
        task_id = TaskID.new(@next_task_id)
        @next_task_id += 1

        task = Task.new(task_id.id, description, total: total, **fields)
        task.start if start
        
        @lock.synchronize do
          @tasks[task_id] = task
        end

        start_refresh_thread if @auto_refresh && !@disable
        task_id
      end

      def start_task(task_id)
        @lock.synchronize do
          task = @tasks[task_id]
          task&.start
        end
      end

      def stop_task(task_id)
        @lock.synchronize do
          task = @tasks[task_id]
          task&.stop
        end
      end

      def update(task_id, **kwargs)
        @lock.synchronize do
          task = @tasks[task_id]
          task&.update(**kwargs)
        end
      end

      def advance(task_id, advance = 1.0)
        @lock.synchronize do
          task = @tasks[task_id]
          task&.advance(advance)
        end
      end

      def remove_task(task_id)
        @lock.synchronize do
          @tasks.delete(task_id)
        end
      end

      def stop
        @refresh_thread&.kill
        @refresh_thread = nil
      end

      # Context manager support
      def with_progress
        start_refresh_thread if @auto_refresh && !@disable
        begin
          yield self
        ensure
          stop
        end
      end

      # Renderable protocol
      def __rich_console__(console, options)
        return [] if @disable || @tasks.empty?

        segments = []
        visible_tasks = nil
        
        @lock.synchronize do
          visible_tasks = @tasks.values.select(&:visible)
        end

        visible_tasks.each do |task|
          task_segments = render_task(task, console, options)
          segments.concat(task_segments)
          segments << Segment.line
        end

        # Remove the last newline
        segments.pop if segments.last&.text == "\n"
        segments
      end

      # Class method for simple progress tracking
      def self.track(sequence, description: "Working...", total: nil, **kwargs)
        total ||= sequence.respond_to?(:length) ? sequence.length : 100
        
        progress = new(**kwargs)
        task_id = progress.add_task(description, total: total.to_f)
        
        progress.with_progress do
          if sequence.respond_to?(:each_with_index)
            sequence.each_with_index do |item, index|
              yield item, index if block_given?
              progress.advance(task_id)
            end
          else
            sequence.each do |item|
              yield item if block_given?
              progress.advance(task_id)
            end
          end
        end
      end

      private

      def default_columns
        [
          TextColumn.new("[progress.description]{task.description}"),
          BarColumn.new,
          PercentageColumn.new,
          TimeRemainingColumn.new,
          SpeedColumn.new
        ]
      end

      def render_task(task, console, options)
        segments = []
        
        @columns.each_with_index do |column, index|
          column_segments = console.render(column.render(task), options)
          segments.concat(column_segments)
          
          # Add spacing between columns (except last)
          if index < @columns.length - 1
            segments << Segment.new(" ")
          end
        end
        
        segments
      end

      def start_refresh_thread
        return if @refresh_thread || @disable
        
        @refresh_thread = Thread.new do
          loop do
            sleep(1.0 / @refresh_per_second)
            refresh_display
          end
        end
      end

      def refresh_display
        return if @disable
        
        # In a real implementation, this would use Live display
        # For now, just print the current state
        segments = __rich_console__(@console, RenderOptions.new(max_width: @console.width))
        return if segments.empty?
        
        # Clear previous lines and render new state
        print "\r\e[K"  # Clear current line
        @console.write_segments(segments)
      end
    end
  end

  # Convenience module methods
  def self.track(sequence, **kwargs, &block)
    Progress::Progress.track(sequence, **kwargs, &block)
  end
end