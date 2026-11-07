---
title: Configuration
---

Hanami's logger is built on [Dry Logger](//org_guide/dry/dry-logger), and is configured via `config.logger` in your `App` class, where you can set the log level, formatter, output stream, filtering and more. These come with [sensible defaults](//guide/logger) for each environment, and for many apps they may be all you need.

### Log level

The log level controls how much your logger emits: it writes entries at or above the level you set and ignores anything below. From most to least verbose, the levels are `:debug`, `:info`, `:warn`, `:error` and `:fatal`.

Hanami defaults to `:debug` in development and test, and `:info` in production. To change it, set `config.logger.level`:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.logger.level = :info
  end
end
```

You can also set the level for a single run with the `HANAMI_LOG_LEVEL` environment variable, which takes precedence over `config.logger.level`:

```shell
HANAMI_LOG_LEVEL=debug bundle exec hanami dev
```

### Formatter

The formatter controls how log entries are rendered. By default, Hanami uses `:string` (human-readable text) in development and test, and `:json` (structured JSON) in production.

To use a formatter across all environments, set `config.logger.formatter`. For example, to log JSON everywhere:

```ruby
module Bookshelf
  class App < Hanami::App
    config.logger.formatter = :json
  end
end
```

For the full list of built-in formatters, see the Dry Logger [formatters guide](//org_guide/dry/dry-logger/formatters).

### Output stream

By default, the logger writes to `$stdout` (except in test, where it writes to `log/test.log`). To send your logs elsewhere, set `config.logger.stream` to a file path or any `IO`-like object:

```ruby
module Bookshelf
  class App < Hanami::App
    config.logger.stream = root.join("log", "app.log")
  end
end
```

### Configuring per environment

Configuration like the above above apply to _all environments_. To configure a setting for in a single environment, wrap it with the `environment` method:

```ruby
module Bookshelf
  class App < Hanami::App
    environment :production do
      config.logger.level = :warn
    end
  end
end
```

### Log filters

To avoid sensitive information leaking into your log streams, Hanami configures log filtering to filter out the following keys:

- `_csrf`
- `password`
- `password_confirmation`

To add your own keys:

```ruby
module Bookshelf
  class App < Hanami::App
    config.logger.filters += ["token"]
  end
end
```

For more on filtering, including how keys are matched, see the Dry Logger [filtering guide](//org_guide/dry/dry-logger/filtering).

### Colorized output

In development, Hanami colorizes your log levels by default. You can control this yourself via the `colorize` option:

```ruby
module Bookshelf
  class App < Hanami::App
    environment :development do
      config.logger.options[:colorize] = false
    end
  end
end
```

With colorizing enabled, you can also customize the log template to apply your own colors:

```ruby
module Bookshelf
  class App < Hanami::App
    environment :development do
      config.logger.template = <<~TMPL
        [<blue>%<progname>s</blue>] [%<severity>s] [<green>%<time>s</green>] %<message>s %<payload>s
      TMPL
    end
  end
end
```

For the full set of color tags and template tokens, see the Dry Logger [templates guide](//org_guide/dry/dry-logger/templates).

### Customizing logging destinations

You may want to handle certain log entries specially, such as writing errors to their own file. You can do this by adding a dedicated backend to the logger.

Unlike the settings above, a backend isn't a configuration value you set. It's a method call on the built logger instance. That instance is created at boot and registered as the `"logger"` component by a [provider](//guide/app/providers), so you add your backend by extending that provider:

```ruby
# config/providers/logger.rb

Hanami.app.configure_provider :logger do
  before :start do
    # Write error entries to their own file
    logger.add_backend(
      stream: Hanami.app.root.join("log", "errors.log"),
      log_if: :error?
    )
  end
end
```

Inside the hook, `logger` is the instance Hanami registers as `"logger"`. Adding your backend in `before :start` puts it in place before the logger goes into service, so it's active from the first entry.

For more on adding and configuring backends, see the Dry Logger [backends guide](//org_guide/dry/dry-logger/backends).

### Routing and formatting by tag

Log entries can carry _tags_, which you attach using the logger's [`tagged` method](//guide/logger/usage#tagged-logging). Tags don't change your log output on their own; instead, they let you route and format entries based on how they're tagged.

Each entry exposes a `tag?` predicate, which you can use with `log_if` to route tagged entries to a dedicated backend. As with any backend, you add it by extending the logger provider:

```ruby
# config/providers/logger.rb

Hanami.app.configure_provider :logger do
  before :start do
    # Route payment entries to their own file
    logger.add_backend(
      stream: Hanami.app.root.join("log", "payments.log"),
      log_if: -> entry { entry.tag?(:payments) }
    )
  end
end
```

You can also give a backend its own `formatter`, so entries with a given tag are rendered differently from the rest. Hanami uses both of these internally to route its `:sql` and `:rack` entries to dedicated SQL and request formatters.

If you'd instead like tags to appear in your string-formatted output, include the `%<tags>s` token in your log template:

```ruby
# config/app.rb

config.logger.template = "[%<progname>s] [%<severity>s] [%<time>s] %<message>s %<payload>s %<tags>s"
```

### Bringing your own logger

If you'd rather use a different logger entirely, assign it to `config.logger`:

```ruby
# config/app.rb

require "logger"

module Bookshelf
  class App < Hanami::App
    config.logger = ::Logger.new($stdout)
  end
end
```

This replaces Hanami's logger completely, so the `config.logger` settings covered above (level, formatter, stream and so on) no longer apply. Your logger is responsible for its own configuration.

To build the logger yourself at boot (with access to your app's other components), register your own `:logger` provider instead. Hanami detects it and skips its built-in one:

```ruby
# config/providers/logger.rb

Hanami.app.register_provider :logger do
  start do
    register :logger, Dry.Logger(:bookshelf, formatter: :json)
  end
end
```

However you provide your logger, Hanami guarantees the `"logger"` component supports [structured](//guide/logger/usage#logging-data) and [tagged](//guide/logger/usage#tagged-logging) logging. For a logger that already does these, such as another `Dry::Logger`, Hanami uses it as-is. For a logger that doesn't, like Ruby's standard `Logger`, Hanami wraps it with `Hanami::UniversalLogger` to add that support.
