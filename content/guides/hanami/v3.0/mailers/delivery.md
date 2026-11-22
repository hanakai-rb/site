---
title: Delivery
---

A mailer doesn't send email itself; it hands a prepared message to a **delivery method**. A delivery method is any object that responds to `#call(message)` and returns a result. Inside a Hanami app, every mailer is given a delivery method automatically: SMTP delivery when you've configured it, and an in-memory test method otherwise.

## Delivery in your app

The standard delivery method is available as a `"mailers.delivery_method"` component, which Hanami registers in your app and each slice. Each mailer instance receives it automatically, so `deliver` just works:

```ruby
welcome_mailer = Hanami.app["mailers.welcome"]
welcome_mailer.delivery_method  # => the slice's "mailers.delivery_method"

welcome_mailer.deliver(user: user)
```

What that delivery method is depends on your environment:

- In **development**, it's the [test delivery method](#test-delivery) unless you've configured SMTP.
- In **test**, it's always the test delivery method, regardless of any SMTP configuration. Your test suite can never send real email.
- In **production**, it's [SMTP](#smtp-delivery) when configured. If it isn't, Hanami logs a warning and falls back to the test method; no mail will be sent.

### Configuring SMTP

Hanami builds an SMTP delivery method from environment variables when they're present:

```shell
SMTP_ADDRESS=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=mailer@example.com
SMTP_PASSWORD=s3cr3t
SMTP_AUTHENTICATION=plain
```

`SMTP_ADDRESS` is the trigger: once it's set, Hanami uses SMTP and passes the rest of the `SMTP_*` variables through.

Each slice resolves its own delivery method, so different slices can send through different SMTP servers. A slice looks for a variable prefixed with its name, falling back to the unprefixed one. For example, an `admin` slice looks for `ADMIN__SMTP_ADDRESS` before falling back to `SMTP_ADDRESS`:

```shell
# Admin mail goes through a dedicated server
ADMIN__SMTP_ADDRESS=smtp.admin.example.com

# Everything else shares this one
SMTP_ADDRESS=smtp.example.com
```

These variables are sensitive. If you're setting them locally, place them in `.env.local` or another file kept out of source control.

### Customizing delivery

To take full control over delivery, register your own `:mailers` provider. This is helpful when you need a third-party delivery method or different setup logic. Hanami won't override a provider you've defined:

```ruby
# config/providers/mailers.rb

Hanami.app.register_provider(:mailers, namespace: true) do
  start do
    require "hanami/mailer"

    delivery_method =
      if Hanami.env == :test
        Hanami::Mailer::Delivery::Test.new
      else
        Bookshelf::CustomDeliveryMethod.new(
          api_token: slice["settings"].delivery_method_token
        )
      end

    register "delivery_method", delivery_method
  end
end
```

When you register your own provider, it replaces Hanami's own, so you must take care of enabling the [test delivery method](#test-delivery) during tests, as above.

### Overriding per delivery

You can also supply a delivery method to a single mailer instance, which takes precedence over the slice's default:

```ruby
smtp = Hanami::Mailer::Delivery::SMTP.new(address: "smtp.example.com")
Bookshelf::Mailers::Welcome.new(delivery_method: smtp).deliver(user: user)
```

## Delivery methods

### Test delivery

The test delivery method stores messages in memory instead of sending them. This is the default when no other delivery method is configured, and what you'll assert against in tests:

```ruby
result = welcome_mailer.deliver(user: user)

result.success?   # => true
result.message    # => the delivered Hanami::Mailer::Message

deliver_method = welcome_mailer.delivery_method
delivery_method.deliveries        # => [result, ...]
delivery_method.deliveries.size   # => 1
delivery_method.clear             # reset between tests
```

See [Testing](//page/testing) for the full picture.

### SMTP delivery

For real delivery, use SMTP. In a Hanami app this is built for you from `SMTP_*` environment variables, but you can also construct one directly:

```ruby
smtp = Hanami::Mailer::Delivery::SMTP.new(
  address: "smtp.example.com",
  port: 587,
  user_name: ENV["SMTP_USERNAME"],
  password: ENV["SMTP_PASSWORD"],
  authentication: :plain,
  enable_starttls_auto: true
)

result = WelcomeMailer.new(delivery_method: smtp).deliver(user: user)

result.success?   # => true if SMTP accepted the message
result.response   # => the underlying Mail::Message
result.error      # => nil on success, an exception on failure
```

### Custom delivery methods

A delivery method is any object responding to `#call(message)` that returns a `Hanami::Mailer::Delivery::Result`. A result is built from the `message`, an optional raw `response`, and an `error`; its `success?` is derived from the absence of an error. This is all you need to integrate a third-party email API:

```ruby
class MyAPIDelivery
  def call(message)
    response = error = nil

    begin
      response = SomeEmailAPI.send(
        from: message.from,
        to: message.to,
        subject: message.subject,
        html: message.html_body,
        options: message.delivery_options
      )
      error = response.error_message unless response.ok?
    rescue => exception
      error = exception
    end

    Hanami::Mailer::Delivery::Result.new(
      message: message,
      response: response,
      error: error
    )
  end
end
```

A delivery method can also subclass `Delivery::Result` to expose service-specific attributes, such as a remote message id.

## The result

Every delivery returns a `Delivery::Result`:

```ruby
result = welcome_mailer.deliver(user: user)

result.success?  # => true if delivery succeeded
result.failure?  # => true if delivery failed
result.message   # => the prepared Hanami::Mailer::Message
result.response  # => the delivery method's raw response (e.g. a Mail::Message for SMTP)
result.error     # => nil on success, the error on failure (anything with #to_s)
```

## Delivery options

Delivery options are extra, delivery-method-specific parameters passed through to your delivery method on the message. A third-party service might use them for scheduled sending, tracking, or tagging. Declare them with `delivery_option`, statically or with a block that follows the usual [parameter rule](//page/exposures-and-input#the-block-parameter-rule):

```ruby
class CampaignMailer < Bookshelf::Mailer
  from "campaigns@bookshelf.test"
  to { |recipient:| recipient[:email] }
  subject "Special offer"

  delivery_option :track_opens, true
  delivery_option(:send_at) { |scheduled_time:| scheduled_time }
  delivery_option(:tags) { |campaign:| ["campaign-#{campaign[:id]}"] }
end
```

Your delivery method receives these via `message.delivery_options` and acts on them however it sees fit. Hanami's built-in test and SMTP methods ignore them.

## Preparing and previewing

Use `prepare` to build a message without delivering it — useful for inspection, queuing, or sending later through a different method. It takes the same arguments as `deliver` and returns a `Hanami::Mailer::Message`:

```ruby
message = welcome_mailer.prepare(user: {name: "Alice", email: "alice@example.com"})

message.from       # => ["welcome@bookshelf.test"]
message.to         # => ["alice@example.com"]
message.subject    # => "Welcome, Alice!"
message.html_body  # => the rendered HTML
message.text_body  # => the rendered text

# Deliver it later through any delivery method
smtp.call(message)
```

To preview a message without sending it, use `preview`. It takes the same arguments as `deliver`, building the message and passing it through the delivery method's `preview` hook:

```ruby
preview = welcome_mailer.preview(user: user)
```

The test and SMTP methods return the message unchanged, so `preview` gives you back the prepared message. A third-party delivery method can override its `preview` hook to apply service-specific logic, such as resolving a template through a remote API, and `preview` returns the result.
