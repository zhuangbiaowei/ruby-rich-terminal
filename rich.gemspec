# frozen_string_literal: true

require_relative "lib/rich/version"

Gem::Specification.new do |spec|
  spec.name = "rich"
  spec.version = Rich::VERSION
  spec.authors = ["Rich Ruby Team"]
  spec.email = ["rich@example.com"]

  spec.summary = "Rich text and beautiful formatting in the terminal"
  spec.description = "Rich Ruby is a library for creating rich text and beautiful formatting in the terminal. " \
                     "It provides tools for rendering rich text, tables, progress bars, syntax highlighting, " \
                     "markdown, tree structures, columns, logging, tracebacks, status indicators, and object inspection."
  spec.homepage = "https://github.com/rich-ruby/rich"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rich-ruby/rich"
  spec.metadata["changelog_uri"] = "https://github.com/rich-ruby/rich/blob/main/CHANGELOG.md"
  spec.metadata["documentation_uri"] = "https://rich-ruby.github.io/rich"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "tty-color", "~> 0.6"
  spec.add_dependency "tty-cursor", "~> 0.7"
  spec.add_dependency "tty-screen", "~> 0.8"
  spec.add_dependency "rouge", "~> 4.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end