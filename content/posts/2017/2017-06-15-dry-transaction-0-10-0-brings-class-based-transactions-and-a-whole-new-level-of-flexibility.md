---
title: "dry-transaction 0.10.0 brings class-based transactions and a whole new level of flexibility"
date: 2017-06-15 12:00 UTC
author: Tim Riley
---

We're thrilled to announce the release of [dry-transaction 0.10.0](/gems/dry-transaction), which offers a huge improvement in ease-of-use and flexibility around designing your application's business transactions.

dry-transaction has been around for long enough now that it's really been put through its paces across many different apps and use cases. We'd begun to notice one big deficiency in its design: apart from defining the steps, we couldn't customize any other aspect of transaction behavior.

This all changes with dry-transaction 0.10.0 and the introduction of **class-based transactions**. Instead of defining a transaction in a special DSL block, you can now define it within your own class:

```ruby
class MyTransaction
  include Dry::Transaction(container: MyContainer)

  step :one, with: "operations.one"
  step :two, with: "operations.two"
end

my_trans = MyTransaction.new
my_trans.(some_input)
```

Transactions may resolve their operations from containers as before, but they can also now work entirely with local methods ("look ma, no container!"):

```ruby
class MyTransaction
  include Dry::Transaction

  step :one
  step :two

  def one(input)
    Right(do_something(input))
  end

  def two(input)
    Right(do_another_thing(input))
  end
end
```

This isn't an either/or proposition. You can _mix_ steps using instance methods and container operations:

```ruby
class MyTransaction
  include Dry::Transaction(container: MyContainer)

  step :one, with: "operations.one"
  step :local
  step :two, with: "operations.two"

  def local(input)
    # Do something between steps one and two
    Right(input)
  end
end

my_trans = MyTransaction.new
```

We can also use local methods to _wrap_ external operations and provide some custom behaviour that is specific to their particular transaction. For example, this would be useful if you need to massage the input/output arguments to suit the requirements of individual operations.

```ruby
class MyTransaction
  include Dry::Transaction(container: MyContainer)

  step :one, with: "operations.one"
  step :two, with: "operations.two"

  def two(input)
    adjusted_input = do_something_with(input)

    # Call super to run the original operation
    super(adjusted_input)
  end
end
```

Of course, this is just one example. We can't pretend to know everything you might do here, but what's exciting is that anything is now possible!

Another benefit of building transactions into classes is that we can now inject alternative step operations via the initializer. This allows you to modify the behavior of your transactions at runtime, and would be especially helpful for testing, since you can supply test doubles to simulate various different conditions.

```ruby
class MyTransaction
  include Dry::Transaction(container: MyContainer)

  step :one, with: "operations.one"
  step :two, with: "operations.two"
end

my_trans = MyTransaction.new(one: alternative_operation_for_one)
```

Now that our transaction builder is a module, we can much more naturally provide common behavior across multiple transactions, like be defining a reusable module for a particular configuration:

```ruby
module MyApp
  Transaction = Dry::Transaction(container: MyContainer)

class MyTransaction
  include MyApp::Transaction

  step :one, with: "operations.one"
  step :two, with: "operations.two"
end
```

Or even by building a base class for defining additional, common transaction behavior:

```ruby
module MyApp
  class Transaction
    self.inherited(klass)
      klass.send :include, Dry::Transaction(container: MyContainer)
    end

    def call(input)
      # Provide custom behaviour for calling transactions
      super(input)
    end

    # Or add common methods for all your transactions here
  end
end

class MyTransaction < MyApp::Transaction
  step :one, with: "operations.one"
  step :two, with: "operations.two"
end
```

This release wouldn't have happened without the efforts of [Gustavo Caso](https://github.com/GustavoCaso), our newly-minted dry-rb core team member. Gracias, Gustavo 🙏🏻

We're really excited to see what you can do with the new dry-transaction. Please give it a try and [share your experiences with us](http://discuss.dry-rb.org)!
