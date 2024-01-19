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
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/klaustopher/rubocop-config/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = ["rubocop.yml", "rubocop-klaustopher.gemspec"] + Dir["rubocop-*.yml"]

  spec.add_dependency "rubocop", "= 1.60.1"
  spec.add_dependency "rubocop-factory_bot", "= 2.25.1"
  spec.add_dependency "rubocop-performance", "= 1.20.2"
  spec.add_dependency "rubocop-rails", "= 2.23.1"
  spec.add_dependency "rubocop-rspec", "= 2.26.1"
end
