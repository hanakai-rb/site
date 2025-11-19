---
title: Array With Member
---

The built-in array type supports defining the member's type:

```ruby
PostStatuses = Types::Array.of(Types::Coercible::String)

PostStatuses[[:foo, :bar]] # ["foo", "bar"]
```
