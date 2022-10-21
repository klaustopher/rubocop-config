# klaustopher's rubocop config

Add the following to your Gemfile:

```ruby
group :development, :test do
  gem 'rubocop-klaustopher', github: 'klaustopher/rubocop-config', require: false
end
```

Add the following `.rubocop.yml` config:

```yaml
inherit_gem:
  rubocop-klaustopher: rubocop.yml
```

Run `rubocop` and write code like I would 😂