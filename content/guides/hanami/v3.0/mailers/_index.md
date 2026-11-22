---
title: Overview
pages:
  - exposures-and-input
  - headers
  - templates-and-rendering
  - attachments
  - delivery
  - testing
---

In a Hanami app, mailers are responsible for sending email. Each mailer is a class that describes an email: who it's from and to, its subject, its HTML and text bodies, and any attachments. You send it by calling `deliver` with the data the email needs.

Mailers render their bodies with [Hanami View](//guide/views), so their templates share your app's view context, parts, scopes and helpers, including [i18n](//guide/i18n). They deliver through a delivery method the app configures for you.

## Generating a mailer

Use the mailer generator to create a mailer and its templates:

```shell
$ bundle exec hanami generate mailer welcome
```

This creates three files:

- `app/mailers/welcome.rb` — the mailer class
- `app/templates/mailers/welcome.html.erb` — the HTML body template
- `app/templates/mailers/welcome.text.erb` — the text body template

Mailers inherit from a base mailer class defined in `app/mailer.rb`:

```ruby
# app/mailers/welcome.rb

module Bookshelf
  module Mailers
    class Welcome < Bookshelf::Mailer
    end
  end
end
```

Pass `--slice=admin` to generate into a slice, and `--template-engine=haml` (or `slim`) to use a different template engine for the HTML body. See [CLI commands](//guide/cli-commands/generate) for more.

## Your first mailer

Let's flesh out the welcome mailer. We want it to greet a new user by name, so we declare the headers and `expose` the user to the templates:

```ruby
# app/mailers/welcome.rb

module Bookshelf
  module Mailers
    class Welcome < Bookshelf::Mailer
      from "welcome@bookshelf.test"
      to { |user:| user[:email] }
      subject { |user:| "Welcome to Bookshelf, #{user[:name]}!" }

      expose :user
    end
  end
end
```

The bodies come from the templates, which render just like any other Hanami view template:

```erb
<%# app/templates/mailers/welcome.html.erb %>

<h1>Welcome, <%= user[:name] %>!</h1>
<p>We're glad to have you at Bookshelf.</p>
```

```erb
<%# app/templates/mailers/welcome.text.erb %>

Welcome, <%= user[:name] %>!

We're glad to have you at Bookshelf.
```

By default both formats are rendered, producing a multipart email with HTML and text alternatives.

## Delivering a mailer

Mailers are registered as components, so you can resolve them from the app container or inject them with `Deps`. Call `deliver`, passing the data the mailer needs:

```ruby
welcome_mailer = Hanami.app["mailers.welcome"]

welcome_mailer.deliver(user: {name: "Alice", email: "alice@example.com"})
```

More often you'll inject the mailer where you need it — say, from an [operation](//guide/operations):

```ruby
module Bookshelf
  module Operations
    class RegisterUser < Bookshelf::Operation
      include Deps[mailer: "mailers.welcome"]

      def call(attributes)
        user = yield create_user(attributes)
        mailer.deliver(user:)
        Success(user)
      end

      # ...
    end
  end
end
```

The data you pass to `deliver` (here, `user:`) flows to your headers, templates, attachments and delivery options. See [Exposures and input](//page/exposures-and-input) for details.

## Next steps

- [Exposures and input](//page/exposures-and-input) — how the data you pass to `deliver` reaches your headers, templates, attachments and delivery options.
- [Headers](//page/headers) — standard and custom email headers, computed dynamically or overridden at delivery time.
- [Templates and rendering](//page/templates-and-rendering) — HTML and text bodies, formats, view integration, and rendering without Hanami View.
- [Attachments](//page/attachments) — static, dynamic, inline and runtime attachments.
- [Delivery](//page/delivery) — delivery methods, SMTP configuration, delivery options, and preparing messages without sending.
- [Testing](//page/testing) — asserting on the email your app sends.
