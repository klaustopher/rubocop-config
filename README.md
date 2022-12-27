# klaustopher's rubocop config

Add the following to your Gemfile:

```ruby
group :development do
  gem 'rubocop-klaustopher', git: 'https://github.com/klaustopher/rubocop-config'
end
```

Add the following `.rubocop.yml` config:

```yaml
inherit_gem:
  rubocop-klaustopher: rubocop.yml
```

The gem is currently compatible with Ruby 3.0 (as I am using this in some projects. When using a newer version, this
should be specified in the `.rubocop.yml` config:

```yaml
AllCops:
  TargetRubyVersion: 3.2
```

Run `rubocop` and write code like I would 😂
