---
title: Error Handling
---

When using dry-operation, errors are handled through the `Failure` type from [dry-monads](//org_guide/dry/dry-monads). Each step in your operation should return either a `Success` or `Failure` result. When a step returns a `Failure`, the operation short-circuits, skipping the remaining steps and returning the failure immediately.

You'll usually handle the failure from the call site, where you can pattern match on the result to handle success and failure cases. However, sometimes it's useful to encapsulate some error handling logic within the operation itself.

## Global error handling

You can define a global failure handler by implementing an `#on_failure` method in your operation class. This method is only called to perform desired side effects and it won't affect the operation's return value.

```ruby
class CreateUser < Dry::Operation
  def initialize(logger:)
    @logger = logger
  end

  def call(input)
    attrs = step validate(input)
    user = step persist(attrs)
    step notify(user)
    user
  end

  private

  def on_failure(failure)
    # Log or handle the failure globally
    logger.error("Operation failed: #{failure}")
  end
end
```

The `#on_failure` method can optionally accept a second argument: the name of the wrapped method that encountered the failure. This is the method dry-operation prepended around (`:call` by default), not the inner `#step` whose result was a `Failure`. This can be useful when you've configured additional wrapped methods with [`.operate_on`](//page/configuration) and want to handle their failures differently:

```ruby
class CreateUser < Dry::Operation
  operate_on :call, :update

  def initialize(logger:)
    @logger = logger
  end

  def call(input)
    attrs = step validate(input)
    user = step persist(attrs)
    step notify(user)
    user
  end

  def update(user, input)
    attrs = step validate(input)
    step persist_changes(user, attrs)
  end

  private

  def on_failure(failure, method_name)
    case method_name
    when :call
      logger.error("Create failed: #{failure}")
    when :update
      logger.error("Update failed: #{failure}")
    end
  end
end
```

To identify which inner step failed, inspect the `failure` value itself — for example, by returning distinguishing values from each step (`Failure[:validate, errors]`, `Failure[:persist, error]`, etc.).
