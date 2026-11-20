---
title: ActiveRecord
---

The `ActiveRecord` extension adds transaction support for operations using the [ActiveRecord](https://api.rubyonrails.org/classes/ActiveRecord) ORM. Like the other database extensions, it will roll back the transaction if any step returns a `Failure`.

Make sure you have activerecord installed:

```ruby
gem "activerecord"
```

Require and include the extension in your operation class:

```ruby
require "dry/operation/extensions/active_record"

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::ActiveRecord

  def call(input)
    transaction do
      user = step create_user(input)
      step create_profile(user)
      user
    end
  end

  # ...
end
```

By default, `ActiveRecord::Base` is used to initiate transactions. You can specify a different class either when including the extension:

```ruby
include Dry::Operation::Extensions::ActiveRecord[User]
```

Or at runtime:

```ruby
transaction(User) do
  # ...
end
```

This is particularly useful when working with multiple databases in ActiveRecord.

You can also provide default transaction options when including the extension:

```ruby
include Dry::Operation::Extensions::ActiveRecord[isolation: :serializable]
```

You can override these options at runtime:

```ruby
transaction(isolation: :serializable) do
  # ...
end
```

⚠️ Warning: The `:requires_new` option for nested transactions is not yet fully supported.
