# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"

module Rich
  # Table rendering system with borders, alignment, and styling
  # Equivalent to Python's rich.table.Table
  class Table
    include Renderable

    # Box drawing characters for table borders
    module Box
      ASCII = {
        top_left: "+", top: "-", top_divider: "+", top_right: "+",
        head_left: "+", head: "-", head_divider: "+", head_right: "+",
        head_row: "|", mid_left: "+", mid: "-", mid_divider: "+", mid_right: "+",
        row: "|", foot_left: "+", foot: "-", foot_divider: "+", foot_right: "+",
        bottom_left: "+", bottom: "-", bottom_divider: "+", bottom_right: "+"
      }.freeze

      ROUNDED = {
        top_left: "╭", top: "─", top_divider: "┬", top_right: "╮",
        head_left: "├", head: "─", head_divider: "┼", head_right: "┤",
        head_row: "│", mid_left: "├", mid: "─", mid_divider: "┼", mid_right: "┤",
        row: "│", foot_left: "├", foot: "─", foot_divider: "┼", foot_right: "┤",
        bottom_left: "╰", bottom: "─", bottom_divider: "┴", bottom_right: "╯"
      }.freeze

      HEAVY = {
        top_left: "┏", top: "━", top_divider: "┳", top_right: "┓",
        head_left: "┣", head: "━", head_divider: "╋", head_right: "┫",
        head_row: "┃", mid_left: "┣", mid: "━", mid_divider: "╋", mid_right: "┫",
        row: "┃", foot_left: "┣", foot: "━", foot_divider: "╋", foot_right: "┫",
        bottom_left: "┗", bottom: "━", bottom_divider: "┻", bottom_right: "┛"
      }.freeze

      DOUBLE = {
        top_left: "╔", top: "═", top_divider: "╦", top_right: "╗",
        head_left: "╠", head: "═", head_divider: "╬", head_right: "╣",
        head_row: "║", mid_left: "╠", mid: "═", mid_divider: "╬", mid_right: "╣",
        row: "║", foot_left: "╠", foot: "═", foot_divider: "╬", foot_right: "╣",
        bottom_left: "╚", bottom: "═", bottom_divider: "╩", bottom_right: "╝"
      }.freeze
    end

    attr_reader :columns, :rows, :title, :caption, :width, :min_width, :box
    attr_accessor :show_header, :show_footer, :show_edge, :show_lines, :expand, :pad_edge
    attr_accessor :collapse_padding, :padding, :header_style, :footer_style, :border_style
    attr_accessor :row_styles, :leading, :highlight

    def initialize(
      *headers,
      title: nil,
      caption: nil,
      width: nil,
      min_width: nil,
      box: Box::ROUNDED,
      safe_box: nil,
      padding: [0, 1],
      collapse_padding: false,
      pad_edge: true,
      expand: false,
      show_header: true,
      show_footer: false,
      show_edge: true,
      show_lines: false,
      leading: 0,
      style: nil,
      header_style: nil,
      footer_style: nil,
      border_style: nil,
      title_style: nil,
      caption_style: nil,
      title_justify: "center",
      caption_justify: "center",
      highlight: false,
      row_styles: nil
    )
      @columns = []
      @rows = []
      @title = title
      @caption = caption
      @width = width
      @min_width = min_width
      @box = box || Box::ROUNDED
      @padding = padding.is_a?(Array) ? padding : [0, padding]
      @collapse_padding = collapse_padding
      @pad_edge = pad_edge
      @expand = expand
      @show_header = show_header
      @show_footer = show_footer
      @show_edge = show_edge
      @show_lines = show_lines
      @leading = leading
      @style = Style.parse(style)
      @header_style = Style.parse(header_style)
      @footer_style = Style.parse(footer_style)
      @border_style = Style.parse(border_style)
      @title_style = Style.parse(title_style)
      @caption_style = Style.parse(caption_style)
      @title_justify = title_justify
      @caption_justify = caption_justify
      @highlight = highlight
      @row_styles = row_styles || []

      # Add headers as columns
      headers.each { |header| add_column(header) }
    end

    # Add a column to the table
    def add_column(
      header = "",
      footer: "",
      header_style: nil,
      footer_style: nil,
      style: nil,
      justify: "left",
      vertical: "top",
      overflow: "ellipsis",
      width: nil,
      min_width: nil,
      max_width: nil,
      ratio: nil,
      no_wrap: false
    )
      column = {
        header: make_cell(header),
        footer: make_cell(footer),
        header_style: Style.parse(header_style),
        footer_style: Style.parse(footer_style),
        style: Style.parse(style),
        justify: justify,
        vertical: vertical,
        overflow: overflow,
        width: width,
        min_width: min_width,
        max_width: max_width,
        ratio: ratio,
        no_wrap: no_wrap,
        index: @columns.length
      }
      @columns << column
      self
    end

    # Add a row to the table
    def add_row(*row_data, style: nil, end_section: false)
      cells = row_data.map { |cell| make_cell(cell) }
      
      # Pad row to match column count
      while cells.length < @columns.length
        cells << make_cell("")
      end

      row = {
        cells: cells,
        style: Style.parse(style),
        end_section: end_section
      }
      
      @rows << row
      self
    end

    # Add a section separator
    def add_section
      return self if @rows.empty?
      @rows.last[:end_section] = true
      self
    end

    # Set column styles
    def columns=(column_data)
      column_data.each_with_index do |data, index|
        if index < @columns.length
          @columns[index].merge!(data)
        end
      end
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      max_width = options.max_width || console.width
      segments = []

      # Calculate column widths
      widths = calculate_widths(console, max_width)
      return [Segment.new("Table too wide for console")] if widths.nil?

      # Render title
      if @title
        title_segments = render_title(console, max_width)
        segments.concat(title_segments)
        segments << Segment.line
      end

      # Render top border
      if @show_edge
        border_segments = render_border(:top, widths)
        segments.concat(border_segments)
        segments << Segment.line
      end

      # Render header
      if @show_header && @columns.any? { |col| !col[:header].plain.empty? }
        header_segments = render_row(@columns.map { |col| col[:header] }, widths, :header)
        segments.concat(header_segments)
        segments << Segment.line

        # Header separator
        if @rows.any? || @show_footer
          separator_segments = render_border(:head, widths)
          segments.concat(separator_segments)
          segments << Segment.line
        end
      end

      # Render rows
      @rows.each_with_index do |row, index|
        row_segments = render_row(row[:cells], widths, :row, row[:style])
        segments.concat(row_segments)
        segments << Segment.line

        # Row separator for sections
        if row[:end_section] && index < @rows.length - 1
          separator_segments = render_border(:mid, widths)
          segments.concat(separator_segments)
          segments << Segment.line
        end
      end

      # Render footer
      if @show_footer && @columns.any? { |col| !col[:footer].plain.empty? }
        separator_segments = render_border(:foot, widths)
        segments.concat(separator_segments)
        segments << Segment.line

        footer_segments = render_row(@columns.map { |col| col[:footer] }, widths, :footer)
        segments.concat(footer_segments)
        segments << Segment.line
      end

      # Render bottom border
      if @show_edge
        border_segments = render_border(:bottom, widths)
        segments.concat(border_segments)
        segments << Segment.line
      end

      # Render caption
      if @caption
        caption_segments = render_caption(console, max_width)
        segments.concat(caption_segments)
        segments << Segment.line
      end

      # Remove the last newline
      segments.pop if segments.last&.text == "\n"

      segments
    end

    private

    def make_cell(content)
      case content
      when Text
        content
      when String
        Text.new(content)
      else
        Text.new(content.to_s)
      end
    end

    def calculate_widths(console, max_width)
      return nil if @columns.empty?

      # Simple width calculation - could be enhanced
      available_width = max_width
      
      # Account for borders and padding
      if @show_edge
        available_width -= 2  # Left and right borders
      end
      
      # Account for column separators
      if @columns.length > 1
        available_width -= (@columns.length - 1)
      end

      # Account for padding
      padding_width = @padding[1] * 2
      available_width -= padding_width * @columns.length

      return nil if available_width <= 0

      # Distribute width evenly for now
      column_width = available_width / @columns.length
      [column_width] * @columns.length
    end

    def render_title(console, max_width)
      title_text = Text.new(@title.to_s, style: @title_style)
      title_segments = console.render(title_text)
      
      # Center title
      title_width = title_segments.sum(&:cell_length)
      if title_width < max_width
        padding = (max_width - title_width) / 2
        [Segment.new(" " * padding)] + title_segments + [Segment.new(" " * padding)]
      else
        title_segments
      end
    end

    def render_caption(console, max_width)
      caption_text = Text.new(@caption.to_s, style: @caption_style)
      caption_segments = console.render(caption_text)
      
      # Center caption
      caption_width = caption_segments.sum(&:cell_length)
      if caption_width < max_width
        padding = (max_width - caption_width) / 2
        [Segment.new(" " * padding)] + caption_segments + [Segment.new(" " * padding)]
      else
        caption_segments
      end
    end

    def render_border(border_type, widths)
      return [] unless @show_edge || border_type == :head || border_type == :mid || border_type == :foot

      segments = []
      
      # Left corner/edge
      case border_type
      when :top
        segments << Segment.new(@box[:top_left], @border_style)
      when :head
        segments << Segment.new(@box[:head_left], @border_style)
      when :mid
        segments << Segment.new(@box[:mid_left], @border_style)
      when :foot
        segments << Segment.new(@box[:foot_left], @border_style)
      when :bottom
        segments << Segment.new(@box[:bottom_left], @border_style)
      end

      # Column borders and dividers
      widths.each_with_index do |width, index|
        # Horizontal line for column
        line_char = case border_type
                   when :top then @box[:top]
                   when :head then @box[:head]
                   when :mid then @box[:mid]
                   when :foot then @box[:foot]
                   when :bottom then @box[:bottom]
                   end
        
        line_width = width + @padding[1] * 2
        segments << Segment.new(line_char * line_width, @border_style)

        # Divider (except for last column)
        if index < widths.length - 1
          divider_char = case border_type
                        when :top then @box[:top_divider]
                        when :head then @box[:head_divider]
                        when :mid then @box[:mid_divider]
                        when :foot then @box[:foot_divider]
                        when :bottom then @box[:bottom_divider]
                        end
          segments << Segment.new(divider_char, @border_style)
        end
      end

      # Right corner/edge
      case border_type
      when :top
        segments << Segment.new(@box[:top_right], @border_style)
      when :head
        segments << Segment.new(@box[:head_right], @border_style)
      when :mid
        segments << Segment.new(@box[:mid_right], @border_style)
      when :foot
        segments << Segment.new(@box[:foot_right], @border_style)
      when :bottom
        segments << Segment.new(@box[:bottom_right], @border_style)
      end

      segments
    end

    def render_row(cells, widths, row_type, row_style = nil)
      segments = []
      
      # Left border
      if @show_edge
        border_char = case row_type
                     when :header then @box[:head_row]
                     else @box[:row]
                     end
        segments << Segment.new(border_char, @border_style)
      end

      # Render cells
      cells.each_with_index do |cell, index|
        column = @columns[index] || {}
        width = widths[index] || 0

        # Apply padding
        segments << Segment.new(" " * @padding[1]) if @padding[1] > 0

        # Get cell style
        cell_style = case row_type
                    when :header
                      Style.combine(column[:header_style], @header_style)
                    when :footer
                      Style.combine(column[:footer_style], @footer_style)
                    else
                      Style.combine(Style.combine(column[:style], row_style), @style)
                    end

        # Render cell content
        cell_text = cell.copy
        cell_text.instance_variable_set(:@style, Style.combine(cell_text.style, cell_style)) if cell_style

        # Truncate or pad to fit width
        cell_content = cell_text.plain
        if cell_content.length > width
          cell_content = cell_content[0...width]
        else
          # Justify content
          justify = column[:justify] || "left"
          case justify
          when "right"
            cell_content = cell_content.rjust(width)
          when "center"
            cell_content = cell_content.center(width)
          else
            cell_content = cell_content.ljust(width)
          end
        end

        segments << Segment.new(cell_content, cell_style)

        # Apply padding
        segments << Segment.new(" " * @padding[1]) if @padding[1] > 0

        # Column separator
        if index < cells.length - 1
          segments << Segment.new(@box[:row], @border_style)
        end
      end

      # Right border
      if @show_edge
        border_char = case row_type
                     when :header then @box[:head_row]
                     else @box[:row]
                     end
        segments << Segment.new(border_char, @border_style)
      end

      segments
    end
  end
end