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

## Releases

Releases are managed with [Knope](https://knope.tech) and [changesets](https://github.com/changesets/changesets). Pin a release tag to get a stable config:

```ruby
gem 'rubocop-klaustopher', git: 'https://github.com/klaustopher/rubocop-config', tag: 'v2.1.0'
```

Every change that should be released needs a change file in `.changeset/`. Create one with `knope document-change`. Dependabot PRs that bump one of the RuboCop gems get a change file automatically, with the same semver level as the bumped gem.

Every push to `main` with pending change files creates or updates the `chore: prepare release` PR. Merging that PR tags the release and creates a GitHub release.

The `sample/` directory contains Rails-shaped code to check config changes against: `cd sample && bundle exec rubocop --ignore-parent-exclusion`.
