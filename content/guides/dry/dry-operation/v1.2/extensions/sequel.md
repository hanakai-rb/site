---
title: Sequel
---

The `Sequel` extension provides transaction support for operations when using the [Sequel](http://sequel.jeremyevans.net) database toolkit. It will automatically roll back the transaction if any step returns a `Failure`.

Make sure you have sequel installed:

```ruby
gem "sequel"
```

Require and include the extension in your operation class and provide access to the Sequel database object through a `#db` method:

```ruby
require "dry/operation/extensions/sequel"

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Sequel

  attr_reader :db

  def initialize(db:)
    @db = db
    super()
  end

  def call(input)
    transaction do
      user_id = step create_user(input)
      step create_profile(user_id)
      user_id
    end
  end

  # ...
end
```

You can pass options to the transaction either when including the extension:

```ruby
include Dry::Operation::Extensions::Sequel[isolation: :serializable]
```

Or at runtime:

```ruby
transaction(isolation: :serializable) do
  # ...
end
```

⚠️ Warning: The `:savepoint` option for nested transactions is not yet supported.
