---
title: Try
layout: gem-single
name: dry-monads
---

Rescues a block from an exception. The `Try` monad is useful when you want to wrap some code that can raise exceptions of certain types. A common example is making an HTTP request or querying a database.

```ruby
require 'dry/monads'

class ExceptionalLand
  include Dry::Monads[:try]

  def call
    res = Try { 10 / 2 }
    res.value! if res.value?
    # => 5

    res = Try { 10 / 0 }
    res.exception if res.error?
    # => #<ZeroDivisionError: divided by 0>

    # By default Try catches all exceptions inherited from StandardError.
    # However you can catch only certain exceptions like this
    Try[NoMethodError, NotImplementedError] { 10 / 0 }
    # => raised ZeroDivisionError: divided by 0 exception
  end
end
```

It is better if you pass a list of expected exceptions which you are sure you can process. Catching exceptions of all types is considered bad practice.

The `Try` monad consists of two types: `Value` and `Error`. The first is returned when code did not raise an error and the second is returned when the error was captured.

### `bind`

Allows you to chain blocks that can raise exceptions.

```ruby
Try[NetworkError, DBError] { grap_user_by_making_request }.bind { |user| user_repo.save(user) }

# Possible outcomes:
# => Value(persisted_user)
# => Error(NetworkError: request timeout)
# => Error(DBError: unique constraint violated)
```

### `fmap`

Works exactly the same way as `Result#fmap` does.

```ruby
require 'dry/monads'

class ExceptionalLand
  include Dry::Monads[:try]

  def call
    Try { 10 / 2 }.fmap { |x| x * 3 }
    # => Try::Value(15)

    Try[ZeroDivisionError] { 10 / 0 }.fmap { |x| x * 3 }
    # => Try::Error(ZeroDivisionError: divided by 0)
  end
end
```

### `value!` and `exception`

Use `value!` for unwrapping a `Success` and `exception` for getting error object from a `Failure`.

### `to_result` and `to_maybe`

`Try`'s `Value` and `Error` can be transformed to `Success` and `Failure` correspondingly by calling `to_result` and to `Some` and `None` by calling `to_maybe`. Keep in mind that by transforming `Try` to `Maybe` you lose the information about an exception so be sure that you've processed the error before doing so.

### `recover`

Recovers from an error:

```ruby
extend Dry::Monads[:try]

Try { 10 / 0 }.recover(ZeroDivisionError) { 1 } # => Try::Value(1)
```

No explicit list of exceptions required, StandardError will be the default:
```ruby
extend Dry::Monads[:try]
Try { Hash.new.fetch(:missing) }.recover { :found } # => Try::Value(:found)
```

Of course, it's a no-op on values:
```ruby
Try { 10 }.recover { 1 } # => Try::Value(10)
```

Multiple exception types are allowed:
```ruby
extend Dry::Monads[:try]

Try { bang! }.recover(KeyError, ArgumentError) { :failsafe }
```
