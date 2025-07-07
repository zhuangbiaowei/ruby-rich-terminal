# frozen_string_literal: true

require_relative "renderable"
require_relative "segment"
require_relative "style"
require_relative "text"

module Rich
  # Tree structure display with guide lines
  # Equivalent to Python's rich.tree.Tree
  class Tree
    include Renderable

    attr_reader :label, :style, :guide_style, :expanded

    def initialize(
      label,
      style: nil,
      guide_style: nil,
      expanded: true,
      highlight: false,
      hide_root: false
    )
      @label = label
      @style = style
      @guide_style = guide_style || Style.new(color: "bright_black", dim: true)
      @expanded = expanded
      @highlight = highlight
      @hide_root = hide_root
      @children = []
    end

    # Add a child node to the tree
    def add(label, style: nil, guide_style: nil, expanded: true)
      child = Tree.new(
        label,
        style: style,
        guide_style: guide_style || @guide_style,
        expanded: expanded
      )
      @children << child
      child
    end

    # Add multiple children at once
    def add_many(*labels)
      labels.map { |label| add(label) }
    end

    # Renderable protocol implementation
    def __rich_console__(console, options)
      segments = []
      
      unless @hide_root
        # Render the root label
        if @label.respond_to?(:__rich_console__)
          label_segments = @label.__rich_console__(console, options)
        else
          label_segments = [Segment.new(@label.to_s, @style)]
        end
        segments.concat(label_segments)
        segments << Segment.line
      end
      
      # Render children if expanded
      if @expanded && @children.any?
        render_children(segments, [], console, options)
      end
      
      segments
    end

    # Get all child nodes
    def children
      @children.dup
    end

    # Check if tree has children
    def has_children?
      @children.any?
    end

    # Expand all nodes recursively
    def expand_all
      @expanded = true
      @children.each(&:expand_all)
    end

    # Collapse all nodes recursively
    def collapse_all
      @expanded = false
      @children.each(&:collapse_all)
    end

    # Remove all children
    def clear
      @children.clear
    end

    # Iterate over all nodes in the tree
    def each(&block)
      return to_enum(:each) unless block_given?
      
      yield self
      @children.each { |child| child.each(&block) }
    end

    # Find nodes by label
    def find(label)
      results = []
      each do |node|
        if node.label == label || (node.label.respond_to?(:to_s) && node.label.to_s == label.to_s)
          results << node
        end
      end
      results
    end

    # Get depth of the tree
    def depth
      return 0 if @children.empty?
      1 + @children.map(&:depth).max
    end

    # Count total nodes in tree
    def count
      1 + @children.sum(&:count)
    end

    protected

    def render_children(segments, prefixes, console, options)
      @children.each_with_index do |child, index|
        is_last = index == @children.length - 1
        
        # Create prefix for this level
        if is_last
          current_prefix = "└── "
          next_prefix = "    "
        else
          current_prefix = "├── "
          next_prefix = "│   "
        end
        
        # Add the guide lines and current prefix
        prefixes.each do |prefix|
          segments << Segment.new(prefix, @guide_style)
        end
        segments << Segment.new(current_prefix, @guide_style)
        
        # Render the child label
        if child.label.respond_to?(:__rich_console__)
          label_segments = child.label.__rich_console__(console, options)
        else
          label_segments = [Segment.new(child.label.to_s, child.style)]
        end
        segments.concat(label_segments)
        segments << Segment.line
        
        # Recursively render children if expanded
        if child.expanded && child.has_children?
          new_prefixes = prefixes + [next_prefix]
          child.render_children(segments, new_prefixes, console, options)
        end
      end
    end
  end
end