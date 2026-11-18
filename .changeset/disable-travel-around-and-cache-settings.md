---
default: minor
---

# Disable `RSpecRails/TravelAround` and drop cache settings

`travel_to` in an `around` block is allowed again: it cleans up regardless of example group type and also covers outer `let!`/`before` setup. `UseCache` and `CacheRootDirectory` are no longer set, so consumers no longer get the "not set at the top level" warning and RuboCop uses its default cache location.
