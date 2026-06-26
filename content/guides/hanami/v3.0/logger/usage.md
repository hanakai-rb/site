---
title: Usage
---

You can access the logger anywhere in your app as the `"logger"` component. It offers the same API as Ruby's standard `Logger`, and accepts plain text messages, structured data, or both.

### Basic usage

To log a text entry, simply use a logger method with a name corresponding to the log level that you want to use. Let's say you want to log an entry with `INFO` level:

```ruby
app["logger"].info "Hello World"
# [bookshelf] [INFO] [2022-11-20 13:47:13 +0100] Hello World
```

If you wanted to log an error:

```ruby
app["logger"].error "Something's wrong"
# [bookshelf] [ERROR] [2022-11-20 13:48:05 +0100] Something's wrong
```

The following logging methods are available:

- `debug`
- `info`
- `warn`
- `error`
- `fatal`

### Logging data

In addition to plain text logging, you can log arbitrary data by passing a log entry _payload_ to a log method, as keyword arguments:

```ruby
app["logger"].info "Hello World", component: "admin"
# [bookshelf] [INFO] [2022-11-20 13:50:43 +0100] Hello World component="admin"
```

The text message argument is not mandatory, which means you can choose to provide the structured payload only:

```ruby
app["logger"].info message: "Hello World", component: "admin"
# [bookshelf] [INFO] [2022-11-20 13:51:40 +0100] message="Hello World" component="admin"
```

In development, the payload is rendered as `key=value` pairs, which are easy to read at a glance. In production, Hanami switches to the `:json` formatter by default, which is the better choice wherever your logs are collected and processed by other tools.

### Tagged logging

You can attach _tags_ to your log entries using the `tagged` method. Any entries logged within the given block will carry those tags:

```ruby
app["logger"].tagged(:payments) do
  app["logger"].info "Charging card", amount: 1000
end
```

Tagged blocks can be nested, with inner tags adding to those of the enclosing block.

Tags don't change your log output on their own. Instead, they let you route and format entries based on how they're tagged. Hanami uses this internally to send its SQL query and HTTP request logs to their own formatters. See [Routing and formatting by tag](//guide/logger/configuration#routing-and-formatting-by-tag) to do the same with your own tags.

### Logging exceptions

Hanami logger supports logging exceptions out of the box without the need to write custom formatters. Simply rescue from an exception and pass it to the `error` log method:

```ruby
begin
  raise "OH NOEZ!"
rescue => e
  app["logger"].error(e)
end
# [bookshelf] [ERROR] [2022-11-20 13:54:55 +0100]
#   OH NOEZ! (RuntimeError)
#   (pry):7:in `__pry__'
#   ...
```

You can also pass in any additional information that should be helpful in a payload:

```ruby
begin
  raise "OH NOEZ!"
rescue => e
  app["logger"].error(e, component: "admin")
end
# [bookshelf] [ERROR] [2022-11-20 13:56:36 +0100] component="console"
#   OH NOEZ! (RuntimeError)
#   (pry):12:in `__pry__'
```
