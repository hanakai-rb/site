---
title: Class Builder
---

```ruby
require 'dry/core/class_builder'

builder = Dry::Core::ClassBuilder.new(name: 'MyClass')

klass = builder.call
klass.name # => "MyClass"
```
