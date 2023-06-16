# rubocop:disable Rails/SkipsModelValidations, Rails/RakeEnvironment
require "bundler/gem_tasks"
require "rubocop/rake_task"
require_relative "lib/rubocop/klaustopher/version"
require "semantic"

RuboCop::RakeTask.new

task default: [:spec, :rubocop]

desc "Bumps the minor version"
task :bump_minor_version do
  file = File.join(File.dirname(__FILE__), "lib/rubocop/klaustopher/version.rb")
  new_version = Semantic::Version.new(Rubocop::Klaustopher::VERSION).increment!(:patch)

  File.write(file, <<~FILE)
    module Rubocop
      module Klaustopher
        VERSION = "#{new_version}".freeze
      end
    end
  FILE

  puts "Bumped version to #{new_version}"
end

desc "Prints current gem version"
task :version do
  puts Rubocop::Klaustopher::VERSION
end
# rubocop:enable Rails/SkipsModelValidations, Rails/RakeEnvironment
