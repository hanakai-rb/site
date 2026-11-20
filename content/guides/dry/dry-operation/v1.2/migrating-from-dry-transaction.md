---
title: Migrating from Dry Transaction
---

Dry Operation is the successor to [Dry Transaction](//org_guide/dry/dry-transaction). Both libraries support [Railway Oriented Programming](//page/design-pattern), but Dry Operation offers a more flexible approach.

Dry Operation has an alternative for every Dry Transaction feature, so you can migrate all your transaction classes.

## Key differences

With Dry Transaction, you declare steps at the class level, and each step's output becomes the next step's input. With Dry Operation, you write your steps as ordinary Ruby inside your operation's `#call` method:

- Each step is a method call wrapped with `#step`. If the method returns a `Success`, `#step` returns its value. If it returns a `Failure`, the operation stops and returns that failure.
- You pass data between steps yourself. This means you can adjust values between steps, and your steps can have any signature.
- Steps have no names. To tell failures apart, return a `Failure` with an identifier, such as `Failure[:validate, errors]`.
- Operations wrap the return value of `#call` in a `Success` for you.

## Quick reference

| Dry Transaction                                       | Dry Operation                                      |
| ----------------------------------------------------- | -------------------------------------------------- |
| [`step`](#migrating-a-simple-transaction)             | A method call wrapped with `#step`, inside `#call` |
| [`map`](#map-wrapping-raw-values)                     | A plain method call                                |
| [`try`](#try-exception-handling)                      | The `Try` monad, or `begin`/`rescue`               |
| [`check`](#check-boolean-checks)                      | A conditional that returns a `Failure`             |
| [`tee`](#tee-side-effects)                            | A plain method call                                |
| [Custom step adapters](#custom-step-adapters)         | A plain method                                     |
| [Containers and `with:`](#external-steps)             | Dependency injection                               |
| [`#with_step_args`](#passing-step-arguments)          | Arguments to `#call`                               |
| [Step notifications](#step-notifications)             | Your own pub/sub, plus the `#on_failure` hook      |
| [`around` steps](#around-steps-database-transactions) | The [database extensions](//page/extensions)       |
| [Match blocks](#result-matching)                      | Pattern matching with `case`/`in`                  |

## Migrating a simple transaction

Move your class-level steps into your operation's `#call` method. Use the return value of each step to prepare the input for the next step, and pass it explicitly.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  step :validate
  step :create

  private

  def validate(input)
    # Returns Success(attrs) or Failure(errors)
  end

  def create(attrs)
    # Returns Success(user) or Failure(error)
  end
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    attrs = step validate(input)
    step create(attrs)
  end

  private

  def validate(input)
    # Returns Success(attrs) or Failure(errors)
  end

  def create(attrs)
    # Returns Success(user) or Failure(error)
  end
end
```

You call both classes in the same way, and both return a `Success` or `Failure`:

```ruby
result = CreateUser.new.call(name: "Jane", email: "jane@example.com")
result.success?
```

If your `validate` step uses Dry Validation, you can replace it with the [Validation extension](//page/extensions/validation). This validates your operation's input before `#call` runs.

## Step adapters

Dry Transaction's step adapters (`map`, `try`, `check`, `tee`) are a class-level DSL for handling step return values. With Dry Operation, you use plain Ruby, or other monads from [Dry Monads](//org_guide/dry/dry-monads). See [Other monads](//page/other-monads) for how these work with `#step`.

### `map`: wrapping raw values

A `map` step can't fail, so you don't need `#step` at all. Call the method directly.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  map :process # Wraps the return value in Success
  step :create
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    attrs = process(input)
    step create(attrs)
  end

  private

  def process(input)
    input.merge(processed: true)
  end

  def create(attrs)
    # Returns Success(user) or Failure(error)
  end
end
```

### `try`: exception handling

Use the `Try` monad, or your own `begin`/`rescue`.

**Dry Transaction**

```ruby
class FetchData
  include Dry::Transaction

  try :fetch, catch: NetworkError
  step :process
end
```

**Dry Operation**

```ruby
class FetchData < Dry::Operation
  include Dry::Monads[:try]

  def call(input)
    data = step fetch(input)
    step process(data)
  end

  private

  def fetch(input)
    # #step converts the Try to a Success or Failure
    Try[NetworkError] { HTTP.get("/data/#{input}") }
  end

  def process(data)
    Success(data.transform)
  end
end
```

Or with `begin`/`rescue`:

```ruby
def fetch(input)
  Success(HTTP.get("/data/#{input}"))
rescue NetworkError => e
  Failure(e)
end
```

### `check`: boolean checks

Return a `Failure` from a conditional.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  check :valid?
  step :create
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    return Failure(:invalid) unless valid?(input)

    step create(input)
  end

  private

  def valid?(input)
    input[:name] && input[:email]
  end

  def create(input)
    # Returns Success(user) or Failure(error)
  end
end
```

If you want a `nil` value to cause a failure, you can also use the `Maybe` monad. See [Other monads](//page/other-monads).

### `tee`: side effects

Call the method directly between steps. Its return value is ignored.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  step :create
  tee :notify # Runs for side effects, and passes its input through
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    user = step create(input)
    notify(user)
    user
  end

  private

  def create(input)
    # Returns Success(user) or Failure(error)
  end

  def notify(user)
    Mailer.send_welcome(user)
  end
end
```

## Custom step adapters

Dry Transaction lets you register your own step adapters, such as an `enqueue` adapter that runs a step in a background queue. With Dry Operation, write a plain method that does the same work, and call it from `#call`.

**Dry Transaction**

```ruby
class MyStepAdapters < Dry::Transaction::StepAdapters
  register :enqueue, -> step, input, *args {
    BackgroundQueue.push(step.operation, input, *args)
    Dry::Monads.Success(input)
  }
end

class CreateUser
  include Dry::Transaction(container: Container, step_adapters: MyStepAdapters)

  step :create
  enqueue :send_welcome_email
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    user = step create(input)
    enqueue(:send_welcome_email, user)
    user
  end

  private

  def enqueue(job_name, *args)
    BackgroundQueue.push(job_name, *args)
  end
end
```

To share this behavior across operations, put the method in a module, or in a base operation class.

## External steps

Dry Transaction uses a container to supply external steps, and the `with:` option to name them. With Dry Operation, make these steps available to your operation as dependencies.

**Dry Transaction**

```ruby
class Container
  extend Dry::Container::Mixin

  register "users.validate" do
    Users::Validate.new
  end

  register "users.create" do
    Users::Create.new
  end
end

class CreateUser
  include Dry::Transaction(container: Container)

  step :validate, with: "users.validate"
  step :create, with: "users.create"
end
```

**Dry Operation**

In a Hanami app, use the `Deps` mixin. Use the same approach with [Dry Auto Inject](//org_guide/dry/dry-auto_inject) outside Hanami.

```ruby
class CreateUser < Dry::Operation
  include Deps[validate: "users.validate", create: "users.create"]

  def call(input)
    attrs = step validate.call(input)
    step create.call(attrs)
  end
end
```

Without a container, accept the dependencies in your initializer:

```ruby
class CreateUser < Dry::Operation
  attr_reader :validate, :create

  def initialize(validate: Users::Validate.new, create: Users::Create.new)
    @validate = validate
    @create = create
    super()
  end

  def call(input)
    attrs = step validate.call(input)
    step create.call(attrs)
  end
end
```

Both approaches also replace Dry Transaction's support for injecting step objects at runtime. Pass a different object to the initializer, such as a test double:

```ruby
CreateUser.new(create: -> attrs { Dry::Monads::Failure(:could_not_create) })
```

## Passing step arguments

Dry Transaction passes each step's output as the next step's input. To give a step extra arguments, you must call `#with_step_args` from outside the transaction.

With Dry Operation, you pass arguments to each step yourself, inside `#call`. Give your operation the extra arguments it needs, and pass them on to the steps.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  step :validate
  step :create
  tee :notify

  # ...
end

CreateUser.new
  .with_step_args(
    create: [account_id: 123],
    notify: ["admin@example.com"]
  )
  .call(name: "Jane")
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input, account_id:, notification_recipient:)
    attrs = step validate(input)
    user = step create(**attrs, account_id:)
    notify(user, notification_recipient:)
    user
  end

  # ...
end

CreateUser.new.call(
  {name: "Jane"},
  account_id: 123,
  notification_recipient: "admin@example.com"
)
```

## Step notifications

Dry Operation has no built-in step notifications. Instead, publish your own events using a gem like Dry Events, or with plain Ruby. Use the [`#on_failure` hook](//page/error-handling) to publish an event when the operation fails.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction

  step :validate
  step :create
end

module UserCreationListener
  extend self

  def on_step(event)
    # Called when the step starts
  end

  def on_step_succeeded(event)
    # Called when the step succeeds
  end

  def on_step_failed(event)
    # Called when the step fails
  end
end

create_user = CreateUser.new
create_user.subscribe(create: UserCreationListener)
```

**Dry Operation**

Using [Dry Events](//org_guide/dry/dry-events):

```ruby
require "dry/events/publisher"

class CreateUser < Dry::Operation
  include Dry::Events::Publisher[:create_user]

  register_event "step.succeeded"
  register_event "step.failed"

  def call(input)
    attrs = step validate(input)
    publish("step.succeeded", step: :validate, result: attrs)

    user = step create(attrs)
    publish("step.succeeded", step: :create, result: user)

    user
  end

  private

  def on_failure(failure)
    publish("step.failed", failure:)
  end
end

module UserCreationListener
  extend self

  def on_step_succeeded(event)
    # event[:step], event[:result]
  end

  def on_step_failed(event)
    # event[:failure]
  end
end

create_user = CreateUser.new
create_user.subscribe(UserCreationListener)
```

## Around steps (database transactions)

Dry Transaction uses `around` steps to wrap all the steps that follow. This is typically used to roll back a database transaction when a step fails. With Dry Operation, use the [database extensions](//page/extensions) instead.

**Dry Transaction**

```ruby
class CreateUser
  include Dry::Transaction(container: Container)

  around :transaction, with: "transaction"
  step :create_user, with: "users.create"
  step :create_account, with: "accounts.create"
end
```

**Dry Operation**

```ruby
require "dry/operation/extensions/active_record"

class CreateUser < Dry::Operation
  include Dry::Operation::Extensions::ActiveRecord

  def call(input)
    transaction do
      user = step create_user(input)
      step create_account(user)
      user
    end
  end
end
```

These extensions are available:

- [ActiveRecord](//page/extensions/active-record)
- [ROM](//page/extensions/rom)
- [Sequel](//page/extensions/sequel)

## Result matching

Both Dry Transaction and Dry Operation return a `Result`, and you can use its full API in both cases.

Dry Operation does not support Dry Transaction's match blocks. Instead, use pattern matching with `case`/`in`.

Dry Transaction's `m.failure(:validate)` matches failures by step name. Dry Operation steps have no names, so return a `Failure` with an identifier from each step you want to match.

**Dry Transaction**

```ruby
CreateUser.new.call(input) do |m|
  m.success { |user| puts "Created: #{user.name}" }
  m.failure(:validate) { |errors| puts "Validation failed: #{errors}" }
  m.failure { |error| puts "Error: #{error}" }
end
```

**Dry Operation**

```ruby
class CreateUser < Dry::Operation
  def call(input)
    attrs = step validate(input)
    step create(attrs)
  end

  private

  def validate(input)
    errors = check_for_errors(input)

    if errors.any?
      Failure[:validate, errors]
    else
      Success(input)
    end
  end

  def create(attrs)
    # Returns Success(user) or Failure(error)
  end
end
```

Then use pattern matching to handle the result:

```ruby
case CreateUser.new.call(input)
in Success(user)
  puts "Created: #{user.name}"
in Failure[:validate, errors]
  puts "Validation failed: #{errors}"
in Failure(error)
  puts "Error: #{error}"
end
```

See the [pattern matching documentation](//org_guide/dry/dry-monads/pattern-matching) for more details.
