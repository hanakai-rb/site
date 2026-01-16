---
title: Maybe matcher
---

dry-matcher provides a ready-to-use `MaybeMatcher` for working with Maybe from [Dry Monads](//doc/dry/dry-monads) or any other compatible gems.

```ruby
require "dry/monads"
require "dry/matcher/maybe_matcher"

value = Dry::Monads::Maybe("success!")

result = Dry::Matcher::MaybeMatcher.(value) do |m|
  m.some(Integer) do |i|
    "Got int: #{i}"
  end

  m.some do |v|
    "Yay: #{v}"
  end

  m.none do
    "Boo: none"
  end
end

result # => "Yay: success!"
```
