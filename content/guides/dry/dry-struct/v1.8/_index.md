---
title: Introduction
pages:
  - nested-structs
  - recipes
  - extensions
  - deprecated-features
  - virtus
---

Dry Struct is a gem built on top of [Dry Types](//org_guide/dry/dry-types) which provides a DSL for defining typed struct classes. It allows building immutable data structures with type safety and coersions, making sure that the data is in the shape you want it to be.

### Basic Usage

You can define struct objects which will have readers for specified attributes using a simple DSL:

```ruby
require 'dry-struct'

Types = Dry.Types()

class User < Dry::Struct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
end

user = User.new(name: nil, age: '21')

user.name # nil
user.age # 21

user = User.new(name: 'Jane', age: '21')

user.name # => "Jane"
user.age # => 21
```

<sub>Note: An `optional` type means that the value can be nil, not the key in the hash can be skipped.</sub>

### Hash Schemas

Dry Struct out of the box uses [hash schemas](//org_guide/dry/dry-types/hash-schemas) from Dry Types for processing input hashes. `with_type_transform` and `with_key_transform` are exposed as `transform_types` and `transform_keys`:

```ruby
class User < Dry::Struct
  transform_keys(&:to_sym)

  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
end

User.new('name' => 'Jane', 'age' => '21')
# => #<User name="Jane" age=21>
```

This plays nicely with inheritance, you can define a base struct for symbolizing input and then reuse it:

```ruby
class SymbolizeStruct < Dry::Struct
  transform_keys(&:to_sym)
end

class User < SymbolizeStruct
  attribute :name, Types::String.optional
  attribute :age, Types::Coercible::Integer
end
```

### Validating data with Dry Struct

Please don't. Structs are meant to work with valid input, it cannot generate error messages good enough for displaying them for a user etc. Use [Dry Validation](//org_guide/dry/dry-validation) for validating incoming data and then pass its output to structs.
