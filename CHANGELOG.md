# Changelog
## 2.1.0 (2026-11-18)

### Features

- Update rubocop-rspec requirement from = 3.9.0 to = 3.10.2 and enable new cops `RSpec/DiscardedMatcher` and `RSpec/MatchWithSimpleRegex`
- Update rubocop-capybara requirement from = 3.0.0 to = 3.1.0 and enable all new cops
- Update rubocop-performance requirement from = 1.26.1 to = 1.27.0
- Update rubocop-rspec_rails requirement from = 2.32.0 to = 2.33.0
- Disable `RSpecRails/TravelAround` and stop setting `UseCache`/`CacheRootDirectory`

### Fixes

- Update rubocop requirement from = 1.92.1 to = 1.92.2
- Fix the Rake task running `spec` that does not exist
