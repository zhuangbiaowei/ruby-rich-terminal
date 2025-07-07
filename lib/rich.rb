# frozen_string_literal: true

require_relative "rich/version"
require_relative "rich/console"
require_relative "rich/renderable"
require_relative "rich/segment"
require_relative "rich/style"
require_relative "rich/markup"
require_relative "rich/text"
require_relative "rich/table"
require_relative "rich/progress"
require_relative "rich/syntax"
require_relative "rich/markdown"
require_relative "rich/tree"
require_relative "rich/columns"
require_relative "rich/panel"
require_relative "rich/rule"
require_relative "rich/status"
require_relative "rich/traceback"
require_relative "rich/inspect"
require_relative "rich/logging"

module Rich
  class Error < StandardError; end

  # Rich print function for easy access
  def self.print(*args, **kwargs)
    console = kwargs.delete(:console) || Console.new
    console.print(*args, **kwargs)
  end

  # Rich inspect function
  def self.inspect(obj, **kwargs)
    console = kwargs.delete(:console) || Console.new
    inspector = Inspect.new(**kwargs)
    console.print(inspector.render(obj))
  end

  # Install Rich as default print handler
  def self.install
    Kernel.define_method(:rich_print) do |*args, **kwargs|
      Rich.print(*args, **kwargs)
    end
  end
end