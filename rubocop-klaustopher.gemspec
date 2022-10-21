# frozen_string_literal: true

require_relative "lib/rubocop/klaustopher/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-klaustopher"
  spec.version = Rubocop::Klaustopher::VERSION
  spec.authors = ["Klaus Zanders"]
  spec.email = ["code@kgz.me"]

  spec.summary = "My Rubocop configuration"
  spec.description = "If you want your code to be formatted like mine, this is the place"
  spec.homepage = "https://github.com/klaustopher/rubocop-config"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/klaustopher/rubocop-config/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = %w[
    rubocop.yml
    rubocop-rails.yml
    rubocop-rspec.yml
    rubocop-performance.yml
  ]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'rubocop', '~> 1.37'
  spec.add_dependency 'rubocop-rails', '~> 2.16'
  spec.add_dependency 'rubocop-rspec', '~> 2.13'
  spec.add_dependency 'rubocop-performance', '~> 1.15'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
