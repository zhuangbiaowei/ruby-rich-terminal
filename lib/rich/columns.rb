# frozen_string_literal: true

require "tty-screen"
require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"

module Rich
  # Multi-column layout system
  # Equivalent to Python's rich.columns.Columns
  class Columns
    include Renderable

    attr_reader :renderables, :width, :padding, :expand, :equal, :column_first

    def initialize(
      renderables = nil,
      width: nil,
      padding: [0, 1],
      expand: false,
      equal: false,
      column_first: false,
      right_to_left: false,
      align: "left"
    )
      @renderables = renderables ? Array(renderables) : []
      @width = width
      @padding = padding.is_a?(Array) ? padding : [0, padding]
      @expand = expand
      @equal = equal
      @column_first = column_first
      @right_to_left = right_to_left
      @align = align
    end

    # Add a renderable to the columns
    def add_renderable(renderable)
      @renderables << renderable
    end

    # Add multiple renderables
    def add_renderables(*renderables)
      @renderables.concat(renderables)
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      render_width = @width || console.size[0] || 80
      
      return [] if @renderables.empty?
      
      # Render all renderables to get their dimensions
      rendered_items = @renderables.map do |renderable|
        if renderable.respond_to?(:__rich_console__)
          segments = renderable.__rich_console__(console, options)
        else
          segments = [Segment.new(renderable.to_s)]
        end
        
        # Calculate dimensions of this item
        lines = segments_to_lines(segments)
        max_width = lines.map { |line| line.sum { |seg| seg.text.length } }.max || 0
        
        {
          segments: segments,
          lines: lines,
          width: max_width,
          height: lines.length
        }
      end
      
      # Calculate optimal column layout
      layout = calculate_layout(rendered_items, render_width)
      
      # Generate the column output
      generate_columns(rendered_items, layout, render_width)
    end

    private

    def segments_to_lines(segments)
      lines = []
      current_line = []
      
      segments.each do |segment|
        if segment.text == "\n"
          lines << current_line
          current_line = []
        else
          current_line << segment
        end
      end
      
      lines << current_line unless current_line.empty?
      lines
    end

    def calculate_layout(items, total_width)
      return { columns: 1, column_width: total_width } if items.empty?
      
      # Find the maximum width needed
      max_item_width = items.map { |item| item[:width] }.max
      min_column_width = max_item_width + @padding[1] * 2
      
      # Calculate number of columns that can fit
      max_columns = [total_width / min_column_width, items.length].min.to_i
      max_columns = [max_columns, 1].max
      
      if @equal
        # Equal width columns
        column_width = total_width / max_columns
        column_width = [column_width, min_column_width].max
        actual_columns = [total_width / column_width, items.length].min.to_i
        
        {
          columns: actual_columns,
          column_width: column_width.to_i,
          equal_width: true
        }
      else
        # Variable width columns - try to fit as many as possible
        best_layout = nil
        best_columns = 1
        
        (1..max_columns).each do |num_cols|
          items_per_col = (items.length.to_f / num_cols).ceil
          col_widths = []
          
          (0...num_cols).each do |col_idx|
            start_idx = col_idx * items_per_col
            end_idx = [(col_idx + 1) * items_per_col - 1, items.length - 1].min
            
            if start_idx <= end_idx
              col_items = items[start_idx..end_idx]
              col_width = col_items.map { |item| item[:width] }.max || 0
              col_widths << col_width + @padding[1] * 2
            end
          end
          
          total_needed = col_widths.sum
          if total_needed <= total_width
            best_layout = {
              columns: num_cols,
              column_widths: col_widths,
              items_per_column: items_per_col,
              equal_width: false
            }
            best_columns = num_cols
          end
        end
        
        best_layout || {
          columns: 1,
          column_widths: [total_width],
          items_per_column: items.length,
          equal_width: false
        }
      end
    end

    def generate_columns(items, layout, total_width)
      return [] if items.empty?
      
      columns_data = []
      items_per_col = layout[:equal_width] ? 
        (items.length.to_f / layout[:columns]).ceil :
        layout[:items_per_column]
      
      # Organize items into columns
      (0...layout[:columns]).each do |col_idx|
        start_idx = col_idx * items_per_col
        end_idx = [(col_idx + 1) * items_per_col - 1, items.length - 1].min
        
        next if start_idx > end_idx
        
        col_items = items[start_idx..end_idx]
        col_width = layout[:equal_width] ? 
          layout[:column_width] :
          layout[:column_widths][col_idx]
        
        columns_data << {
          items: col_items,
          width: col_width
        }
      end
      
      # Find maximum height needed
      max_height = columns_data.map do |col|
        col[:items].sum { |item| item[:height] }
      end.max || 0
      
      # Generate output line by line
      segments = []
      
      (0...max_height).each do |row_idx|
        line_segments = []
        
        columns_data.each_with_index do |col_data, col_idx|
          # Find which item and line within that item for this row
          current_row = 0
          item_found = nil
          line_in_item = 0
          
          col_data[:items].each do |item|
            if current_row + item[:height] > row_idx
              item_found = item
              line_in_item = row_idx - current_row
              break
            end
            current_row += item[:height]
          end
          
          # Add left padding
          line_segments << Segment.new(" " * @padding[1])
          
          if item_found && line_in_item < item_found[:lines].length
            # Add the content for this line
            item_line = item_found[:lines][line_in_item]
            line_segments.concat(item_line)
            
            # Add padding to reach column width
            content_width = item_line.sum { |seg| seg.text.length }
            remaining_width = col_data[:width] - @padding[1] * 2 - content_width
            line_segments << Segment.new(" " * [remaining_width, 0].max)
          else
            # Empty space in this column
            empty_width = col_data[:width] - @padding[1] * 2
            line_segments << Segment.new(" " * empty_width)
          end
          
          # Add right padding
          line_segments << Segment.new(" " * @padding[1])
        end
        
        segments.concat(line_segments)
        segments << Segment.line unless row_idx == max_height - 1
      end
      
      segments
    end
  end
end