---
title: Dry Operation 1.2 released
date: 2026-11-24 00:00:00 UTC
tags: announcements
author: Paweł Świątkowski
org: dry
excerpt: Read what's new in Dry Operation.
---

A few days ago we released version 1.2.0 of Dry Operation – the engine behind Hanami's [operation layer](/learn/hanami/v3.0/operations), but also a standalone library for organizing business logic.

The release brings one important change: a **validation extension**. With it you can specify the arguments that the operation takes and they will be automatically validated.

Say you have an operation to like a post:

```ruby
class LikePost < Dry::Operation
  def call(post_id:, user_id:, like_type:)
    # ...
  end
end
```

We can take an educated guess about what shape each of the arguments takes: IDs would be integers (or maybe a UUID or ULID?) and like type is probably some enum (but symbol or string?). But if we provide wrong data, we will often end up with a cryptic error, such as a ROM exception saying we are querying an integer column with a string.

So let's refine it with the new validation extension:

```ruby
require "dry/operation/extensions/validation"

class LikePost < Dry::Operation
  include Dry::Operation::Extensions::Validation

  Types = Dry.Types()
  LikeType = Types::String.enum("love", "funny", "insightful")

  params do
    required(:post_id).filled(:integer)
    required(:user_id).filled(:integer)
    required(:like_type).filled(LikeType)
  end

  def call(post_id:, user_id:, like_type:)
    # ...
  end
end
```

We now have our questions from before answered: the IDs are integers and the like type values are strings. And if we pass the wrong data, the operation will bail out immediately, without even touching the `call` method:

```ruby
LikePost.new.call(post_id: 1, user_id: 2, like_type: "anger")
#=> Failure([:invalid, #<Dry::Validation::Result{post_id: 1, user_id: 2, like_type: "anger"} errors={like_type: ["must be one of: love, funny, insightful"]}>])
```

You are not limited to just schema validations. Replace `params` with `contract` and you can have a proper [contract from Dry Validation](/learn/dry/dry-validation/v1.11/rules).

You don't need to validate everything that goes into `call` — you can limit the validation to only certain keys. This supports a common practice of separating the data from the context. If you are creating an event, you want the event data (name, description, start date, end date) and the context in which it's created:

```ruby
class CreateEvent < Dry::Operation
  def call(data:, user:, group:)
    # ...
  end
end
```

In this example `user` is the current user and `group` is the current group. We're not that interested in validating them, so we just validate the data:

```ruby
class CreateEvent < Dry::Operation
  include Dry::Operation::Extensions::Validation

  contract(for: :data) do
    params do
      required(:name).filled(:string)
      required(:start_date).filled(:date)
      required(:end_date).filled(:date)
    end

    rule(:start_date, :end_date) do
      key.failure("must be before end date") if values[:start_date] >= values[:end_date]
    end
  end

  def call(data:, user:, group:)
    # ...
  end
end
```

This should make your operation more resilient with clearer error messages and better-defined APIs. You can find the complete documentation of this new feature [here](/learn/dry/dry-operation/v1.2/extensions/validation).
