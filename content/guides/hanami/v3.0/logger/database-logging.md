---
title: Database logging
---

When your app has a database, Hanami logs every SQL query. In development, they appear alongside your HTTP request logs:

```shell
[bookshelf] [DEBUG] [2026-03-04 10:15:32] SQL sqlite 1.234ms SELECT * FROM users
[bookshelf] [DEBUG] [2026-03-04 10:15:32] GET 200 1ms 127.0.0.1 /users -
```

### Log level

Database query logging has its own log level, which you configure via `config.db.log_level`. It defaults to `:debug`:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.db.log_level = :info
  end
end
```

This sets the severity at which queries are logged. Whether they actually appear also depends on `config.logger.level`, your app's overall log level: the logger only writes entries at or above it.

The default app log level in production is `:info`, which means the `:debug`-level SQL queries are not logged. If you want to log queries in production, raise the database log level to `:info`, or whatever matches your app's logger level.

### SQL syntax highlighting

When colorized output is enabled (the default in development) and the [rouge gem](https://github.com/rouge-ruby/rouge) is bundled, Hanami syntax highlights your SQL queries in the log output.

Rouge is an optional dependency. New Hanami apps include it in their `Gemfile` for the development and test environments:

```ruby
group :development, :test do
  # Syntax highlighting SQL logs
  gem "rouge"
end
```

If Rouge isn't available, queries are logged as plain unhighlighted text.

#### Customizing the theme

Highlighting uses the `pastie` Rouge theme by default. You can choose a different theme by setting the `HANAMI_LOG_SYNTAX_THEME` environment variable to any Rouge theme name:

```shell
HANAMI_LOG_SYNTAX_THEME=base16.solarized bundle exec hanami dev
```

You can list the available themes from a console:

```ruby
require "rouge"
Rouge::Theme.registry.keys
# => ["thankful_eyes", "colorful", "base16", "base16.dark", "base16.light", "base16.solarized", ...]
```
