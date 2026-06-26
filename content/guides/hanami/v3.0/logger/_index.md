---
title: Overview
pages:
  - usage
  - configuration
  - database-logging
---

Hanami provides a built-in, general-purpose logger for your app, powered by [Dry Logger](//org_guide/dry/dry-logger). If you're building a web application, it also logs your HTTP requests, and if your app has a database, it logs your SQL queries.

The logger supports structured logging by default, so you can log _data_ rather than plain text messages. This makes your logs much easier to process and understand when running your system in production.

You can access the logger anywhere in your app as the `"logger"` component:

```ruby
app["logger"].info "Hello World"
# [bookshelf] [INFO] [2022-11-20 13:47:13 +0100] Hello World

app["logger"].info "Order placed", order_id: 123, customer: "alice"
# [bookshelf] [INFO] [2022-11-20 13:47:13 +0100] Order placed order_id=123 customer="alice"
```

In your app's own classes, you'll usually inject it as a dependency with [`Deps`](//guide/app/container-and-components#injecting-dependencies-via-deps):

```ruby
module Bookshelf
  class PlaceOrder
    include Deps["logger"]

    def call(order)
      logger.info "Order placed", order_id: order.id
    end
  end
end
```

Hanami sets up its logger differently depending on the environment:

- In `development`, the logger logs to `$stdout` in `:debug` mode.
- In `test`, the logger logs to `log/test.log` in `:debug` mode.
- In `production`, the logger logs to `$stdout` in `:info` mode using the `:json` formatter.

## Learn more

- [Usage](//guide/logger/usage): logging messages and data, tagged logging, and logging exceptions.
- [Configuration](//guide/logger/configuration): changing the level, formatter and stream, filtering sensitive data, colorized output, and custom destinations.
- [Database logging](//guide/logger/database-logging): SQL query logging and syntax highlighting.
