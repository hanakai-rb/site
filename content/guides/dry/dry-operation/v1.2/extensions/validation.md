---
title: Validation
---

The `Validation` extension adds input validation to your operations using [Dry Validation](//org_guide/dry/dry-validation). When you call an operation, the extension validates its input against your rules before the operation runs. If validation fails, the operation returns a `Failure` with the error details, and does not run its method body.

Make sure you have Dry Validation installed:

```ruby
gem "dry-validation"
```

Require and include the extension in your operation class, then define your validation rules with the `contract` class method:

```ruby
require "dry/operation/extensions/validation"

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  contract do
    params do
      required(:name).filled(:string)
      required(:email).filled(:string)
      optional(:age).maybe(:integer)
    end

    rule(:age) do
      key.failure("must be 18 or older") if value && value < 18
    end
  end

  def call(input)
    user = step create_user(input)
    step notify(user)
    user
  end

  # ...
end
```

When validation succeeds, the operation receives the validated input:

```ruby
result = CreateUser.new.call(name: "Alice", email: "alice@example.com", age: "25")
# => Success(user), with age coerced to the integer 25 and checked by the age rule
```

When validation fails, the operation returns a `Failure` tuple of `:invalid` and the validation result. None of the operation's steps run.

```ruby
result = CreateUser.new.call(name: "", email: "invalid")
# => Failure[:invalid, #<Dry::Validation::Result ...>]
```

## Input arguments and validation

The contract validates the **keyword arguments** given to your operation's wrapped method (typically `#call`). The method then receives the contract's output in place of those keyword arguments.

Your method can accept the validated input as keyword arguments, or as a single hash:

```ruby
class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
  end

  # Accept the validated input as keyword arguments
  def call(name:, email:)
    # ...
  end

  # Or as a single hash
  # def call(input)
  #   # ...
  # end
end

CreateUser.new.call(name: "Alice", email: "alice@example.com")
```

Keep these rules in mind:

- The method receives **only** the keyword arguments in the contract's output. Keyword arguments that the contract does not declare are dropped.
- Positional arguments are never validated. They are always passed through to your method untouched.
- Always pass the input as keyword arguments. A hash given as a positional argument is not validated.

```ruby
CreateUser.new.call(name: "Alice", email: "alice@example.com", admin: true)
# The method receives name: and email: only. admin: is dropped.
```

To pass other keyword arguments through to your method alongside the validated input, use the `for:` or `keys:` options.

## Validating a single keyword argument

Use `for:` to validate the value of a single keyword argument. All other arguments are passed through untouched:

```ruby
class UpdateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  params(for: :attrs) do
    required(:name).filled(:string)
  end

  def call(user, attrs:, notify: false)
    # ...
  end
end

UpdateUser.new.call(user, attrs: {name: "Alice", admin: true}, notify: true)
# user is passed through untouched
# attrs is {name: "Alice"}, with admin dropped by the contract
# notify is passed through untouched
```

If the `for:` keyword argument is not given, there is nothing to validate, so the extension calls your method without it. Your method's own signature then decides if that is allowed.

## Validating a subset of keyword arguments

Use `keys:` to validate a group of keyword arguments together. All other arguments are passed through untouched:

```ruby
class AuthorizeCode < Dry::Operation
  include Dry::Operation::Extensions::Validation

  params(keys: %i[account_id scope]) do
    required(:account_id).filled(:integer)
    optional(:scope).array(:string)
  end

  def call(code, account_id:, scope: [], notify: false)
    # ...
  end
end

AuthorizeCode.new.call("abc", account_id: "1", notify: true)
# code is passed through untouched
# account_id is coerced to 1
# scope is not given, so the method's default of [] applies
# notify is passed through untouched
```

You can give `for:` or `keys:` to `contract`, `params` and `schema`. You cannot give both `for:` and `keys:` together.

## Using `schema` and `params` blocks

For simpler validation that does not need custom rules, you can use `params` or `schema` blocks directly instead of `contract`.

The `params` method validates with type coercion, which suits HTTP params:

```ruby
class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    optional(:age).maybe(:integer)
  end

  def call(input)
    # input[:age] will be coerced from "25" to 25
    user = step create_user(input)
    step notify(user)
    user
  end

  # ...
end
```

The `schema` method validates without type coercion:

```ruby
class ProcessData < Dry::Operation
  include Dry::Operation::Extensions::Validation

  schema do
    required(:name).filled(:string)
    required(:age).filled(:integer)
  end

  def call(input)
    # input[:age] must already be an integer; "25" would fail validation
    # ...
  end
end
```

## Using contract classes

You can also pass a contract class to `contract`, instead of a block. This is useful to reuse validation rules across multiple operations:

```ruby
class UserContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:email).filled(:string)
    optional(:age).maybe(:integer)
  end
end

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  contract UserContract

  def call(input)
    user = step create_user(input)
    step notify(user)
    user
  end

  # ...
end

class UpdateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  contract UserContract, for: :attrs

  def call(user, attrs:)
    # ...
  end
end
```

## Injected contracts

You can also provide a contract instance via dependency injection. Make your contract available as a `#contract` method or `@contract` instance variable:

```ruby
class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::Validation

  def initialize(contract:)
    @contract = contract
    super()
  end

  def call(input)
    # ...
  end
end
```

## Validating custom wrapped methods

Validation applies to any custom wrapped methods configured with [`.operate_on`](//page/configuration):

```ruby
class ProcessData < Dry::Operation
  include Dry::Operation::Extensions::Validation

  operate_on :process, :transform

  params do
    required(:value).filled(:string)
  end

  def process(input)
    input[:value].upcase
  end

  def transform(input)
    input[:value].downcase
  end
end
```

## Inheritance

Subclasses inherit validation contracts, along with their `for:` and `keys:` options. This lets you build operation hierarchies with shared validation rules.
