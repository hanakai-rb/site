---
title: Testing
---

In the test environment, Hanami always uses the [test delivery method](//page/delivery#test-delivery), regardless of any SMTP configuration. Your tests will never send real email. Instead, the test delivery method records each delivery in memory, so you can assert on the email your app would have sent.

## Asserting on a delivery

`deliver` returns a result whose `message` is the email that was prepared. The quickest way to test a mailer is to deliver and then make expectations against that message:

```ruby
# spec/mailers/welcome_spec.rb

RSpec.describe "Welcome mailer", :mailers do
  subject(:mailer) { Bookshelf::Mailers::Welcome.new }

  it "greets the user by name" do
    result = mailer.deliver(user: {name: "Alice", email: "alice@example.com"})

    expect(result.success?).to be(true)
    expect(result.message.to).to eq(["alice@example.com"])
    expect(result.message.subject).to eq("Welcome to Bookshelf, Alice!")
    expect(result.message.html_body).to include("Welcome, Alice!")
    expect(result.message.text_body).to include("Welcome, Alice!")
  end
end
```

The `:mailers` tag keeps examples isolated from one another; [Resetting deliveries between examples](#resetting-deliveries-between-examples) below explains how.

A message's address headers are always arrays, even for a single recipient, so compare against `["alice@example.com"]` rather than a single string.

## Inspecting all deliveries

When the code under test delivers email as a side effect (such as an [operation](//guide/operations) that sends an email), assert on the deliveries recorded by the delivery method. Resolve `"mailers.delivery_method"` and inspect its `deliveries`:

```ruby
RSpec.describe Bookshelf::Operations::RegisterUser, :mailers do
  let(:operation) { described_class.new }
  let(:delivery_method) { Hanami.app["mailers.delivery_method"] }

  it "sends a welcome email" do
    operation.call(name: "Alice", email: "alice@example.com")

    expect(delivery_method.deliveries.size).to eq(1)

    message = delivery_method.deliveries.first.message
    expect(message.to).to eq(["alice@example.com"])
    expect(message.subject).to include("Welcome")
  end
end
```

## Resetting deliveries between examples

The test delivery method records each delivery in memory. When one delivery method is shared across examples, those recordings build up from one example to the next unless you reset them.

In a Hanami app, every mailer shares the same `"mailers.delivery_method"` component. New apps generate `spec/support/mailers.rb`, which clears the recorded deliveries before each example tagged `:mailers`. (In Minitest apps, `include TestSupport::Mailers` instead.)

Standalone, each mailer you construct gets its own test delivery method, so deliveries don't carry over between examples that build a fresh mailer. If you do share a delivery method across examples instead, clear it yourself:

```ruby
RSpec.describe WelcomeMailer do
  let(:delivery_method) { Hanami::Mailer::Delivery::Test.new }
  subject(:mailer) { described_class.new(delivery_method:) }

  before { delivery_method.clear }

  # ...
end
```

## Building a message without delivering

To test how a mailer renders without involving delivery at all, use `prepare`. It builds the same message `deliver` would send, but returns it directly:

```ruby
message = Hanami.app["mailers.welcome"].prepare(
  user: {name: "Alice", email: "alice@example.com"}
)

expect(message.html_body).to include("Welcome, Alice!")
```
