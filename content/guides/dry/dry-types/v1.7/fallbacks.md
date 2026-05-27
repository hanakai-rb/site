---
title: Fallbacks
---

Fallback value will be returned when invalid input is provided:

```ruby
type = Dry::Types['integer'].fallback(100)

type.call(99) # => 99
type.call('99') # => 100
type.call(:invalid) # => 100
```

Block syntax:

```ruby
cnt = 0
type = Dry::Types['integer'].fallback { cnt += 1 }

type.call(99) # => 99
type.call('99') # => 1
type.call(:invalid) # => 2
```

Fallbacks are different from default values because the latter are triggered on _missing_ input rather than invalid. They can be combined:

```ruby
schema = Dry::Types['hash'].schema(
  size: Dry::Types['integer'].fallback(50).default(100)
)
schema.call({}) # => { size: 100 }
schema.call({ size: 'invalid' }) # => { size: 50 }
```
