---
title: ROM
---

The `ROM` extension adds transaction support to your operations when working with the [ROM](https://hanakai.org/rom) database persistence toolkit. When a step returns a `Failure`, the transaction will automatically roll back, ensuring data consistency.

First, make sure you have rom-sql installed:

```ruby
gem "rom-sql"
```

Require and include the extension in your operation class and provide access to the ROM container through a `#rom` method:

```ruby
require "dry/operation/extensions/rom"

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::ROM

  attr_reader :rom

  def initialize(rom:)
    @rom = rom
    super()
  end

  def call(input)
    transaction do
      user = step create_user(input)
      step assign_role(user)
      user
    end
  end

  # ...
end
```

By default, the `:default` gateway will be used and no additional options will be passed to the ROM transaction. You can specify a different gateway and/or default transaction options when including the extension:

```ruby
include Dry::Operation::Extensions::ROM[
  gateway: :my_gateway,
  isolation: :serializable
]
```

You can also override the gateway and/or transaction options at runtime. Options given to `#transaction` are merged with the options given when including the extension:

```ruby
transaction(gateway: :my_gateway, savepoint: true) do
  # ...
end
```
