---
title: Other monads
---

While you typically return `Success` and `Failure` from operation steps, you can also use other monads from [Dry Monads](//org_guide/dry/dry-monads). These are automatically converted to a `Result` when you pass them to `#step`.

## `Try` for exception handling

The `Try` monad is useful for wrapping code that may raise exceptions. When used with `#step`, any caught exception becomes a `Failure`:

```ruby
class ImportData < Dry::Operation
  include Dry::Monads[:try]

  # If File.read raises Errno::ENOENT, or JSON.parse raises JSON::ParserError, step will receive a
  # Failure and short-circuit the operation
  def call(file_path)
    content = step Try { File.read(file_path) }
    data = step Try { JSON.parse(content) }
    step save_to_database(data)
    :imported
  end
end
```

You can also specify which exceptions to catch:

```ruby
step Try[Errno::ENOENT, Errno::EACCES] { File.read(file_path) }
```

[Learn more about Try](//org_guide/dry/dry-monads/try).

## `Maybe` for nil handling

The `Maybe` monad converts `nil` values to `None` and non-nil values to `Some`. These become `Failure` and `Success` respectively when converted to a `Result`.

```ruby
class LookupProfile < Dry::Operation
  include Dry::Monads[:maybe]

  def call(user_id)
    # If find_user returns nil, Maybe(nil) becomes None, which converts to Failure
    user = step Maybe(find_user(user_id))

    # If user.profile is nil, this will also fail
    profile = step Maybe(user.profile)

    profile
  end

  private

  def find_user(id)
    # Returns user or nil
    User.find_by(id:)
  end
end
```

A `None` converts to a `Failure` with no value (`Failure()`). If you need to tell failures apart, convert the `Maybe` yourself and give a failure value:

```ruby
user = step Maybe(find_user(user_id)).to_result(:user_not_found)
```

[Learn more about Maybe](//org_guide/dry/dry-monads/maybe).

## `Validated` for validation with error accumulation

The `Validated` type is useful when you want to collect multiple validation errors instead of failing on the first one. Combine `Validated` values with `List`, then pass the result to `#step`:

```ruby
class ValidateUserInput < Dry::Operation
  include Dry::Monads[:list, :validated]

  def call(input)
    name, email, age = step List::Validated[
      validate_name(input),
      validate_email(input),
      validate_age(input)
    ].traverse

    {name:, email:, age:}
  end

  private

  def validate_name(input)
    # Valid(name) or Invalid(:invalid_name)
  end

  def validate_email(input)
    # Valid(email) or Invalid(:invalid_email)
  end

  def validate_age(input)
    # Valid(age) or Invalid(:invalid_age)
  end
end
```

When any validation fails, the `Failure` includes all the collected errors:

```ruby
ValidateUserInput.new.call(input)
# => Failure(List[:invalid_name, :invalid_email])
```

[Learn more about Validated](//org_guide/dry/dry-monads/validated).

## Including monads in your operations

To use one or more monads (other than `Result`) in your operations, specify them when including `Dry::Monads`.

```ruby
class MyOperation < Dry::Operation
  include Dry::Monads[:try, :maybe, :validated]

  def call(input)
    # Now you can use Try, Maybe, and Validated
  end
end
```

The `Result` monad is always available through the `Success` and `Failure` constructors that Dry Operation provides, so you don't need to explicitly include it.

## Result conversion via `#to_result`

The `#step` method calls `#to_result` on any object given to it, expecting a `Dry::Monads::Success` or `Dry::Monads::Failure` (or any other object responding to `#value_or`) in return. Implement this protocol on your own objects to make them compatible with steps.

```ruby
class ValidationOutcome
  def initialize(errors, value)
    @errors = errors
    @value = value
  end

  def to_result
    if @errors.empty?
      Dry::Monads::Success(@value)
    else
      Dry::Monads::Failure(@errors)
    end
  end
end

class CreateUser < Dry::Operation
  def call(input)
    attrs = step check(input) # returns a ValidationOutcome
    # ...
  end
end
```

If you pass `#step` an object that does not respond to `#to_result`, it raises a `Dry::Operation::InvalidStepResultError`.
