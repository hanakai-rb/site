---
title: Deprecated Features
---

## Value

:warning: `Dry::Struct::Value` is deprecated in 1.2.0. Structs are already meant to be immutable, freezing them doesn't add any value (no pun intended) beyond a bad example of defensive programming.

You can define value objects which will behave like structs but will be _deeply frozen_:

```ruby
class Location < Dry::Struct::Value
  attribute :lat, Types::Float
  attribute :lng, Types::Float
end

loc1 = Location.new(lat: 1.23, lng: 4.56)
loc2 = Location.new(lat: 1.23, lng: 4.56)

loc1.frozen? # true
loc2.frozen? # true

loc1 == loc2
# true
```
