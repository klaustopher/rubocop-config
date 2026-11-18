# klaustopher's rubocop config

An opinionated, shared [RuboCop](https://rubocop.org) configuration for Ruby and Rails projects. It bundles and configures:

- [rubocop](https://github.com/rubocop/rubocop)
- [rubocop-rails](https://github.com/rubocop/rubocop-rails)
- [rubocop-rspec](https://github.com/rubocop/rubocop-rspec) and [rubocop-rspec_rails](https://github.com/rubocop/rubocop-rspec_rails)
- [rubocop-capybara](https://github.com/rubocop/rubocop-capybara)
- [rubocop-factory_bot](https://github.com/rubocop/rubocop-factory_bot)
- [rubocop-performance](https://github.com/rubocop/rubocop-performance)

All plugin versions are pinned exactly, and every newly added cop is explicitly enabled or disabled, so upgrading this gem is the only thing that changes how your code is linted.

## Installation

The gem is not published to RubyGems. Add it to your `Gemfile` from GitHub, pinned to a [release tag](https://github.com/klaustopher/rubocop-config/releases):

```ruby
group :development, :test do
  gem 'rubocop-klaustopher', git: 'https://github.com/klaustopher/rubocop-config', tag: 'v2.1.0', require: false
end
```

Then inherit the config in your `.rubocop.yml`:

```yaml
inherit_gem:
  rubocop-klaustopher: rubocop.yml

inherit_mode:
  merge:
    - Exclude
```

`inherit_mode` merges your own `Exclude` lists with the shared ones instead of replacing them.

Run `rubocop` and write code like I would 😂

## Overriding settings

Anything defined in your own `.rubocop.yml` wins over the shared config:

```yaml
inherit_gem:
  rubocop-klaustopher: rubocop.yml

inherit_mode:
  merge:
    - Exclude

Layout/LineLength:
  Max: 100

AllCops:
  Exclude:
    - lib/legacy/**/*
```

By default `bin/`, `config/`, `db/migrate/`, `db/schema.rb`, `node_modules/`, `tmp/` and `vendor/` are excluded.

## Notable choices

The config lives in one file per department (`rubocop-style.yml`, `rubocop-rails.yml`, …), with comments explaining the less obvious decisions. Some of the choices you'll notice first:

- Double-quoted strings, and no `# frozen_string_literal: true` comment
- Nested `module`/`class` definitions instead of compact `Foo::Bar` style
- Leading dots for multi-line method chains, indented one level
- Table-aligned hash keys and values
- Trailing commas in multi-line array and hash literals, none in method arguments
- No hash value shorthand (`{ foo: foo }`, not `{ foo: }`)
- Lines up to 120 characters
- Most `Metrics/*` cops disabled
- Explicit `association` definitions in FactoryBot factories

## Development

### Trying out config changes

`sample/` contains Rails-shaped code (models, controllers, services, jobs, specs, factories, rake tasks) that is kept free of offenses against the current config. It consumes the gem the same way a real project does, through `inherit_gem` and a `path:` dependency. After changing a setting, run RuboCop on it to see what the change does to real code:

```sh
cd sample
bundle exec rubocop --ignore-parent-exclusion
```

CI runs RuboCop on both the gem itself and `sample/`.

### New cops

When a RuboCop gem adds new cops, RuboCop warns about them until they're explicitly configured. The `Check for new Cops` workflow fails PRs that update the gems while new cops are still unconfigured, and comments with the list of cops that need a decision.

## Releases

Releases are managed with [Knope](https://knope.tech) and [changesets](https://github.com/changesets/changesets).

Every change that should be released needs a change file in `.changeset/`. Create one with `knope document-change`. Keep the summary on a single line, so it's rendered as a bullet point in the changelog. Dependabot PRs that bump one of the RuboCop gems get a change file automatically, with the same semver level as the bumped gem.

Every push to `main` with pending change files creates or updates the `chore: prepare release` PR, which contains the version bump, the changelog and the updated lockfiles. Merging that PR tags the release and creates a GitHub release. Preview the next release locally with `knope prepare-release --dry-run`.
