---
title: Extensions
---

Dry Struct provides one extension.

## super_diff

With [super_diff](https://github.com/splitwise/super_diff) extension you can get nicer diffs in failed expectations in RSpec.

```
expected: #<User name="Jane" age=22>
got: #<User name="Jane" age=21>

#<User {
      name: "Jane",
  -   age: 22
  +   age: 21
}>
```

To use it, make sure you have `super_diff` in your Gemfile and enable the extension in your `spec_helper.rb`:

```ruby
# Gemfile
gem 'super_diff', group: :test

# spec_helper.rb
Dry::Struct.load_extensions(:super_diff)
```
