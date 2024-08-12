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

inherit_mode:
  merge:
    - Exclude
```

> [!CAUTION]
> Currently the gem is configured to support Ruby 3.2 as well, so when using the gem with a newer version, you need to specify `TargetRubVersion: 3.3` in your local rubocop config

Run `rubocop` and write code like I would 😂
