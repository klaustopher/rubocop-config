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

Run `rubocop` and write code like I would 😂
