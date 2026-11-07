---
title: Headers
---

Each mailer declares the email's headers. You can set standard headers using dedicated methods, and you can add any other header with `header`. All header methods accept a static value or a block, and blocks follow the [parameter rule](//page/exposures-and-input#the-block-parameter-rule): keyword parameters receive input, positional parameters receive exposures.

## Standard headers

The standard headers each have a convenience method: `from`, `to`, `cc`, `bcc`, `reply_to`, `return_path` and `subject`.

Use a static value when the header never changes:

```ruby
class NewsletterMailer < Bookshelf::Mailer
  from "news@bookshelf.test"
  subject "This week at Bookshelf"
end
```

Use a block to compute a header from the input or an exposure:

```ruby
class WelcomeMailer < Bookshelf::Mailer
  from "welcome@bookshelf.test"
  to { |user:| user[:email] }
  subject { |user:| "Welcome, #{user[:name]}!" }

  expose :user
end
```

Recipient headers accept a single address or an array:

```ruby
to { |recipients:| recipients.map { |r| r[:email] } }
bcc "archive@bookshelf.test"
```

## Custom headers

Add any other header with `header`. As with the standard headers, the value can be static or computed by a block:

```ruby
class CampaignMailer < Bookshelf::Mailer
  from "campaigns@bookshelf.test"
  to { |recipient:| recipient[:email] }
  subject { |subject_line:| subject_line }

  header :precedence, "bulk"
  header(:list_unsubscribe) { |unsubscribe_url:| "<#{unsubscribe_url}>" }
end
```

A symbol header name is converted to Title-Case, with underscores becoming dashes:

```ruby
header(:x_campaign_id) { |campaign:| campaign[:id] }   # => "X-Campaign-Id"
header(:x_user_segment) { |user:| user[:segment] }     # => "X-User-Segment"
```

Use a string when you need exact control over the casing:

```ruby
header "X-Mailer-Version", "2.0"
```

## Overriding headers at delivery time

Override any header when you call `deliver`, by passing a `headers:` hash. This takes precedence over the mailer's own declarations:

```ruby
class NotificationMailer < Bookshelf::Mailer
  from "notifications@bookshelf.test"
  to "default@example.com"
  subject "Notification"
end

notification_mailer.deliver(
  headers: {
    to: "priority-user@example.com",
    subject: "URGENT: Important update",
    cc: "manager@example.com",
    x_priority: "1"
  }
)
```

This is handy for one-off deliveries where the recipient or subject must be decided by the calling code rather than the mailer.

## Inheritance

When you create a new Hanami app, Hanami generates a base mailer class at `app/mailer.rb` (and one for each slice) for your mailers to inherit from:

```ruby
# app/mailer.rb

require "hanami/mailer"

module Bookshelf
  class Mailer < Hanami::Mailer
  end
end
```

Headers are inherited, so this base mailer is a natural home for shared values like `from`:

```ruby
module Bookshelf
  class Mailer < Hanami::Mailer
    from "noreply@bookshelf.test"
  end
end
```

Subclasses inherit `from` and can add or override their own headers. The same applies to exposures, attachments and delivery options.
