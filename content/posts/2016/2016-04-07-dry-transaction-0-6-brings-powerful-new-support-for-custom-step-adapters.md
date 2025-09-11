---
title: dry-transaction 0.6 brings powerful new support for custom step adapters
date: 2016-04-07 12:00 UTC
author: Tim Riley
---

[dry-transaction](http://dry-rb.org/gems/dry-transaction) is dry-rb's answer to modelling complex business transactions in your applications. With dry-transaction, you can arrange multiple processing operations into a linear pipeline, with the output of each step becoming the input of the next. dry-transaction also elevates error handling to a first-class concern. Any error will halt the flow of operations, and you have powerful APIs for matching and acting on errors.

dry-transaction 0.6.0 is out today, and it brings a powerful new feature to your application's business transactions: support for defining your own custom step adapters. This allows you to encode powerful application-specific behaviours into steps that can be invoked with just a single word inside your transaction definitions.

Let's see this in action with a common sort of transaction:

```ruby
publish_article = Dry.Transaction(container: MyApp::Container) do
  step :publish, with: "admin.articles.operations.publish_article"
  step :index, with: "search.operations.index_article"
  step :generate_pdf, with: "admin.articles.operations.generate_pdf"
  step :notify_contributors, with: "admin.articles.operations.notify_contributors"
end
```

Here we have a series of operations we want to run whenever we publish an article. The beauty of managing them via a transaction here is that it's easy to see what will run, and each step is kept loosely coupled, with each only expecting an article object as input.

However, you might notice some of these steps look like they could be quite slow-running, namely `generate_pdf` and `notify_contributors`. We won't want to keep the user waiting for these steps to run before their browser request completes.

These are exactly the kind of steps we would want to push into a queue of background jobs. Here's where a custom step adapter comes in handy. Let's put one together:

```ruby
require "kleisli"
require "admin/import"

module Admin
  class TransactionStepAdapters < Dry::Transaction::StepAdapters
    class Enqueue
      include Admin::Import("admin.enqueue_background_job")

      def call(step, *args, input)
        enqueue_background_job.(step.operation_name, *args, input)
        Right(input)
      end
    end

    register :enqueue, Enqueue.new
  end
end
```

As you can see, dry-transaction step adapters only need to implement a single method: `#call(step, *args, input)`. In this case, we get the step's `operation_name` (its identifier within the container), and pass that name along with the step's input arguments to the `enqueue_background_job` object, whose purpose is to push that operation into the background queue. I won't go into detail about this object in this article, since it will be specific to your app and its queueing system.

Once we have this adapter in place, the next thing we need to do is make sure it's available to our transactions. You can see above that we've done this by making our own `TransactionStepAdapters` container that inherits from `Dry::Transaction::StepAdapters` (which means we keep dry-transaction's default adapters), and then registering our `enqueue` adapter with it.

Now we can pass the container to our transaction and start using the new adapter:

```ruby
publish_article = Dry.Transaction(container: MyApp::Container, step_adapters: Admin::TransactionStepAdapters) do
  step :publish, with: "admin.articles.operations.publish_article"
  step :index, with: "search.operations.index_article"
  enqueue :generate_pdf, with: "admin.articles.operations.generate_pdf"
  enqueue :notify_contributors, "admin.articles.operations.notify_contributors"
end
```

And there we have it! With the new infrastructure in place, we could change just two words in our transaction and have long-running jobs pushed into the background queue, while keeping everything just as easy to understand in a single glance.

You can [read more about custom step adapters](http://dry-rb.org/gems/dry-transaction/0.13/custom-step-adapters/) in the [dry-transaction documentation](http://dry-rb.org/gems/dry-transaction/) and get started using them with the 0.6.0 release now available on RubyGems. Enjoy!
