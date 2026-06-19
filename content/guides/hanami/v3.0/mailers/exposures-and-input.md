---
title: Exposures and input
---

When you call `deliver` (or `prepare`) on a mailer, the keyword arguments you pass are the mailer's **input**. Exposures turn that input into the values your headers, templates, attachments and delivery options need.

```ruby
welcome_mailer.deliver(user: {name: "Alice", email: "alice@example.com"})
```

Here `user:` is the input. An exposure makes it available for rendering:

```ruby
class Welcome < Bookshelf::Mailer
  from "welcome@bookshelf.test"
  to { |user:| user[:email] }
  subject { |user:| "Welcome, #{user[:name]}!" }

  expose :user
end
```

## Defining exposures

`expose` comes in a few forms.

A value passed straight through from the input:

```ruby
expose :user
```

A value computed by a block:

```ruby
expose(:greeting) { |user:| "Hello, #{user[:name]}!" }
```

A default for optional input, used when the input has no matching key:

```ruby
expose :greeting, default: "Hello"
```

Expose several pass-through values at once:

```ruby
expose :user, :order
```

An exposure's value comes from the first of these that applies: the given block, an instance method matching the name, or the matching key in the input (falling back to `:default`).

## The block parameter rule

Exposures, the [header methods](//page/headers), [attachment blocks](//page/attachments) and [delivery option blocks](//page/delivery) all follow one rule for their block parameters:

- **Keyword parameters** receive matching keys from the input. Give them defaults to make those keys optional.
- **Positional parameters** receive exposure values, matched by name.

This lets later declarations build on earlier exposures:

```ruby
class OrderMailer < Bookshelf::Mailer
  from "orders@bookshelf.test"

  # `customer:` comes from the input given to `deliver`
  to { |customer:| customer[:email] }

  # `customer:` comes from the input; `greeting` becomes an exposure
  expose :greeting do |customer:|
    "Hello, #{customer[:name]}!"
  end

  # `greeting` (positional) receives the value from the `:greeting` exposure above
  subject { |greeting| greeting }
end

OrderMailer.new.deliver(customer: {name: "Alice", email: "alice@example.com"})
```

A keyword splat (`**input`) receives the entire input:

```ruby
expose :summary do |**input|
  input.keys.join(", ")
end
```

## Private exposures

A private exposure is computed and stays available as a dependency to your other exposures, headers, attachments and delivery options, but is never passed to the view for rendering. Use it for values you need while building the message, but don't want in your templates:

```ruby
class InvoiceMailer < Bookshelf::Mailer
  from "billing@bookshelf.test"
  to { |email:| email }
  subject { |full_name| "Invoice for #{full_name}" }
  
  private_expose :full_name do |first_name:, last_name:|
    "#{first_name} #{last_name}"
  end
end
```

`private_expose` is shorthand for `expose(..., private: true)`.

## Next steps

- [Headers](//page/headers) puts the parameter rule to work across all the standard and custom email headers.
- [Templates and rendering](//page/templates-and-rendering) covers how exposures reach your templates, including decorating them with view parts.
