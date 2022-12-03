require_relative 'lib/rubocop/klaustopher/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-klaustopher'
  spec.version = Rubocop::Klaustopher::VERSION
  spec.authors = ['Klaus Zanders']
  spec.email = ['code@kgz.me']

  spec.summary = 'My Rubocop configuration'
  spec.description = 'If you want your code to be formatted like mine, this is the place'
  spec.homepage = 'https://github.com/klaustopher/rubocop-config'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/klaustopher/rubocop-config/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = %w[
    rubocop.yml
    rubocop-rails.yml
    rubocop-rspec.yml
    rubocop-performance.yml
  ]

  spec.add_dependency 'rubocop', '= 1.39.0'
  spec.add_dependency 'rubocop-performance', '= 1.15.1'
  spec.add_dependency 'rubocop-rails', '= 2.17.3'
  spec.add_dependency 'rubocop-rspec', '= 2.15.0'
end
