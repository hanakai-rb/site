---
title: Settings
---

You can define your own settings for your app through a `Settings` class, defined in `config/settings.rb`.

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    # Define your app settings here, for example:
    #
    # setting :my_flag, default: false, constructor: Types::Params::Bool
  end
end
```

Using this class, you can specify what settings exist within your application, what types and defaults they have, and whether or not they are required for your application to boot.

These "app settings" are unrelated to ["app configs"](//page/app-config), which configure framework behaviours. App settings are your own to define and use.

Each app setting is read from an environment variable matching its name. For example, the Redis URL and Sentry DSN settings below are sourced from the `REDIS_URL` and `SENTRY_DSN` environment variables respectively. You can also provide setting values in [YAML files](#yaml-settings-files).

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    setting :redis_url, constructor: Types::String
    setting :sentry_dsn, constructor: Types::String
  end
end
```

## Types

Environment variables are strings, but it's convenient for settings like `analytics_enabled` to be a boolean value, or `max_cart_items` to be an integer.

You can coerce settings to these types by specifying the relevant constructor. For example, `Types::Params::Bool` and `Types::Params::Integer` will coerce values to boolean and integer values respectively:

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    setting :analytics_enabled, constructor: Types::Params::Bool
    setting :max_cart_items, constructor: Types::Params::Integer
  end
end
```

We can see this in action in the Hanami console:

```shell
$ ANALYTICS_ENABLED=true MAX_CART_ITEMS=100 bundle exec hanami console
```

```ruby
bookshelf[development]> Hanami.app["settings"].analytics_enabled
=> true

bookshelf[development]> Hanami.app["settings"].max_cart_items
=> 100
```

Common types that are useful in settings constructors include:

```ruby
Types::String
Types::Params::Bool
Types::Params::Integer
Types::Params::Float
Types::Params::Date
Types::Params::Time
```

These types are provided by [dry-types](//org_guide/dry/dry-types), and the `Types` module is generated for you automatically when you subclass `Hanami::Settings`.

## Required and optional settings

Whether or not each setting is required for your application to boot is determined by its constructor.

If a setting uses a constructor like `Types::String` or `Types::Params::Bool`, then Hanami will raise an exception if the setting is missing, rather than let your application boot in a potentially invalid state.

The below settings will result in a `Hanami::Settings::InvalidSettingsError` when `DATABASE_URL` and `ANALYTICS_ENABLED` environment variables are not set:

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    setting :analytics_enabled, constructor: Types::Params::Bool
    setting :max_cart_items, constructor: Types::Params::Integer
  end
end
```

```shell
$ bundle exec hanami server

! Unable to load application: Hanami::Settings::InvalidSettingsError: Could not initialize settings. The following settings were invalid:

analytics_enabled:  cannot be coerced to false
max_cart_items: can’t convert nil into Integer
```

The same exception will be raised if a setting can't be correctly coerced:

```shell
$ ANALYTICS_ENABLED=true MAX_CART_ITEMS="not coerceable to integer" bundle exec hanami server

! Unable to load application: Hanami::Settings::InvalidSettingsError: Could not initialize settings. The following settings were invalid:

max_cart_items: invalid value for Integer(): "not coerceable to integer"
```

To make a setting optional, use `optional` to allow `nil` values:

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    setting :analytics_enabled, constructor: Types::Params::Bool.optional
    setting :max_cart_items, constructor: Types::Params::Integer.optional
  end
end
```

## Default values

Settings can also specify defaults to be used in the absence of the relevant environment variable.

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    setting :redis_url, default: "redis://localhost:6379", constructor: Types::String
    setting :analytics_enabled, default: false, constructor: Types::Params::Bool
    setting :max_cart_items, default: 100, constructor: Types::Params::Integer
  end
end
```

## YAML settings files

As well as environment variables, Hanami reads setting values from two optional YAML files:

- `config/settings/default.yml`, for values in every environment.
- `config/settings/[HANAMI_ENV].yml`, for values in one environment, such as `config/settings/production.yml`.

Each top-level key in a file gives the value for the setting with the same name:

```yaml
# config/settings/default.yml
analytics_enabled: false
max_cart_items: 100
```

```yaml
# config/settings/production.yml
analytics_enabled: true
```

For each setting, Hanami uses the first value it finds, in this order:

1. The environment variable, such as `ANALYTICS_ENABLED`.
2. `config/settings/[HANAMI_ENV].yml`.
3. `config/settings/default.yml`.
4. The setting's `default:`.

This means an environment variable always wins, so you can use one to override a value from a file.

YAML values can be strings, numbers, booleans and more. Your setting constructors still apply to them, so a value is coerced and checked in the same way as one from an environment variable.

Hanami evaluates each file as ERB before it parses the YAML, so you can compute values:

```yaml
# config/settings/default.yml
support_email: support@<%= ENV.fetch("APP_DOMAIN", "localhost") %>
```

Slices don't have their own YAML settings files. Like environment variables, the files in your app's `config/settings/` are shared by your app and all its slices.

Hanami reads these files once, when it first loads your settings. [Code reloading](//page/code-reloading) does not pick up changes to them, so restart your server or console after you change them, just as you would after changing your `.env` files.

If you check these files into git, keep secrets such as API keys in environment variables instead.

### Custom settings stores

To read settings from somewhere else, set `config.settings_store` in your app class. A settings store is any object with a `#fetch` method that works like `Hash#fetch`.

Hanami provides `Hanami::Settings::YAMLFileStore` for reading a YAML file, and `Hanami::Settings::CompositeStore` for combining stores. A composite store tries each store in order, and uses the first value it finds:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.settings_store = Hanami::Settings::CompositeStore.new(
      Hanami::Settings::EnvStore.new,
      Hanami::Settings::YAMLFileStore.new { config.root.join("config/my_settings.yml") }
    )
  end
end
```

Give `YAMLFileStore` a block, like above, to find the file's path when the settings are first loaded, rather than when the store is made.

## Constraints

To enforce additional contraints on settings, you can use a [constraint](//org_guide/dry/dry-types/constraints) in your constructor type.

Here, the value of the `session_secret` must be at least 32 characters, while the value of the `from_email` setting must satisfy the EMAIL_FORMAT regular expression:

```ruby
# config/settings.rb

module Bookshelf
  class Settings < Hanami::Settings
    EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

    setting :session_secret, constructor: Types::String.constrained(min_size: 32)
    setting :from_email, constructor: Types::String.constrained(format: EMAIL_FORMAT)
  end
end
```

## Using settings within your app

Hanami makes your settings available within your app as a `"settings"` component.

```ruby
Hanami.app["settings"]
```

### Accessing settings within components

To access settings within one of your components, use the Deps mixin:

```ruby
# app/analytics/send_event.rb

module Bookshelf
  module Analytics
    class SendEvent
      include Deps["settings"]

      def call(event_type, payload)
        return unless settings.analytics_enabled

        # ...send event to analytics service here ...
      end
    end
  end
end
```

For more information on components and the Deps mixin, see the [architecture guide](//page/container-and-components).

### Accessing settings within providers

When registering a provider, you can access the app's settings via the `target`, which returns the app's container:

```ruby
# config/providers/redis.rb

Hanami.app.register_provider :redis do
  start do
    require "redis"

    redis = Redis.new(url: target["settings"].redis_url)

    register "redis", redis
  end
end
```

See the guides for [providers](//page/providers) and [containers](//page/container-and-components) for more information.

### Accessing settings within your app class

In some cases, you may want to use a setting to inform an application configuration inside your `App` class. Within the `App` class, settings are exposed at the class level for you, via a `settings` method:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.sessions = :cookie, {
      key: "bookshelf.session",
      secret: settings.session_secret,
      expire_after: 60*60*24*365
    }
  end
end
```

> [!NOTE]
> Because settings can be accessed at this early point in the app's boot process, it's important to ensure that the `Settings` class remains self contained, with no dependencies to other code within your app.

## Adding custom methods

One benefit of using a concrete `Settings` class is that you can add methods to the settings class. This allows you to encapsulate settings-related logic and provides you with a way to a design the best interface into your settings.

```ruby
module Bookshelf
  class Settings < Hanami::Settings
    setting :analytics_enabled, default: false, constructor: Types::Params::Bool
    setting :analytics_api_key, constructor: Types::String.optional

    def send_analytics?
      analytics_enabled && !analytics_api_key.nil?
    end
  end
end
```

## Using dotenv to manage environment variables

Hanami uses the [dotenv gem](https://github.com/bkeepers/dotenv) to load environment variables from `.env` files.

This allows you to maintain specific sets of per-environment variables for your app settings. Which set is used depends on the current environment, which is determined by `HANAMI_ENV`.

`.env.development` is used if `HANAMI_ENV` is "development":

```shell
# .env.development
$ DATABASE_URL=postgres://localhost:5432/bookshelf_development
ANALYTICS_ENABLED=true
```

```shell
$ HANAMI_ENV=development bundle exec hanami console
```

```ruby
bookshelf[development]> Hanami.app["settings"].database_url
=> "postgres://localhost:5432/bookshelf_development"

bookshelf[development]> Hanami.app["settings"].analytics_enabled
=> true
```

`.env.test` is used if `HANAMI_ENV` is "test":

```shell
# .env.test
$ DATABASE_URL=postgres://localhost:5432/bookshelf_test
ANALYTICS_ENABLED=false
```

```shell
$ HANAMI_ENV=test bundle exec hanami console
```

```ruby
bookshelf[test]> Hanami.app["settings"].database_url
=> "postgres://localhost:5432/bookshelf_test"

bookshelf[test]> Hanami.app["settings"].analytics_enabled
=> false
```

For a given `HANAMI_ENV` environment, the `.env` files are looked up in the following order, which adheres to the recommendations made by the [dotenv gem](https://github.com/bkeepers/dotenv#what-other-env-files-can-i-use):

- .env.{environment}.local
- .env.local (unless the environment is `test`)
- .env.{environment}
- .env

This means a variable in `.env.development.local` will override a variable declared in `.env.development`.

Exactly which `.env` files to create and manage is up to you. But we recommend the following as a reasonable set up for development and test environments in shared projects:

| Filename               | Environment          | Checked into git | Purpose                                             |
| ---------------------- | -------------------- | ---------------- | --------------------------------------------------- |
| .env.development.local | development          | no               | Local overrides of development-specific settings.   |
| .env.development       | development          | yes              | Shared development-specific settings.               |
| .env.test.local        | test                 | no               | Local overrides of test-specific settings.          |
| .env.test              | test                 | yes              | Shared test-specific settings.                      |
| .env                   | development and test | yes              | Shared settings applicable in test and development. |

We do not recommend using dotenv in production environments.

> [!NOTE]
> Hanami will only use the dotenv gem if it is included in your Gemfile. Applications generated using "hanami new" include the gem in development and test by default.
