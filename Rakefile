# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

task default: [:rubocop, :spec]

desc "Run the Rich gem CLI"
task :rich do
  system("ruby -Ilib lib/rich.rb")
end