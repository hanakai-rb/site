---
title: Overview
pages:
  - configuration
  - helpers
  - slices
---

Hanami supports internationalization and localization for your app's content via the [i18n gem](https://github.com/ruby-i18n/i18n).

When the i18n gem is bundled, Hanami registers an `"i18n"` component in your app (and each slice) that provides a self-contained translation backend. You can then translate and localize content from anywhere in your app, and use `translate` and `localize` helpers in your actions and views.

## Enabling i18n

To enable i18n, add the i18n gem to your `Gemfile`:

```ruby
gem "i18n"
```

After running `bundle install`, Hanami registers the `"i18n"` component in your app and any slices.

You can confirm this in the console (`bundle exec hanami console`):

```ruby
Hanami.app["i18n"]
# => #<Hanami::Providers::I18n::Backend ...>
```

## Translation files

Translations live in YAML, JSON or Ruby files under `config/i18n/`. Files are loaded for all locales they define, with the top-level key naming the locale:

```yaml
# config/i18n/en.yml
en:
  greeting: "Hello!"
  messages:
    welcome: "Welcome to Bookshelf"
```

```yaml
# config/i18n/tl.yml
tl:
  greeting: "Kumusta!"
  messages:
    welcome: "Maligayang pagdating sa Bookshelf"
```

You can organize translation files however you like under `config/i18n/`. They are matched by the glob `config/i18n/**/*.{yml,yaml,json,rb}`, so nested directories are loaded too.

## Translating content

Use the `"i18n"` component to translate keys from your translation files:

```ruby
Hanami.app["i18n"].t("messages.welcome")
# => "Welcome to Bookshelf"

Hanami.app["i18n"].t("greeting", locale: :tl)
# => "Kumusta!"
```

The component exposes the full i18n API, including `translate` (aliased to `t`), `translate!` (aliased to `t!`, which raises on missing translations), `localize` (aliased to `l`), `exists?` and `transliterate`.

You can inject the `"i18n"` component into your own classes using the `Deps` mixin:

```ruby
module Bookshelf
  module Notifications
    class Welcome
      include Deps["i18n"]

      def call(name)
        i18n.t("messages.welcome_named", name: name)
      end
    end
  end
end
```

## Localizing dates and times

Use `localize` (or its alias `l`) to format dates and times according to the current locale:

```ruby
Hanami.app["i18n"].l(Date.new(2026, 5, 22), format: :short)
# => "22 May"

Hanami.app["i18n"].l(Time.now, format: :long)
# => "22 May 2026 9:05 am"
```

Hanami includes built-in English defaults for `date.formats`, `date.day_names`, `date.month_names`, `time.formats` and meridiem markers ("am" and "pm"), so `localize` works out of the box without any translation files.

You can override any of these defaults by setting the same keys in your own translation files:

```yaml
# config/i18n/en.yml
en:
  date:
    formats:
      short: "%d/%m/%Y"
```

The available formats and locale-dependent strftime codes (`%a`, `%A`, `%b`, `%B`, `%p`, `%P`) are resolved through the slice's i18n backend, so they respect the current locale.

## In your actions and views

The `translate` and `localize` helpers (along with their `t` and `l` aliases) are automatically available in your [actions](//guide/actions) and in your [view](//guide/views) templates, parts and scopes.

In an action:

```ruby
module Bookshelf
  module Actions
    module Posts
      class Create < Bookshelf::Action
        def handle(request, response)
          response.flash[:notice] = t("messages.post_created")
          response.redirect_to routes.path(:posts)
        end
      end
    end
  end
end
```

In a view template:

```erb
<h1><%= t("messages.welcome") %></h1>
```

See [Helpers](//page/helpers) for full details, including HTML-safe keys and relative key lookup.

## Switching the current locale

The current locale decides which translations are used. To change it, set `locale`:

```ruby
Hanami.app["i18n"].locale = :tl
```

Each slice's i18n backend keeps the current locale in thread-local storage, so setting it in one request never affects another running at the same time.

To run a block with a specific locale and have the previous locale restored afterwards (even if the block raises), use `with_locale`:

```ruby
Hanami.app["i18n"].with_locale(:tl) do
  Hanami.app["i18n"].t("greeting") # => "Kumusta!"
end
```

This is the recommended approach when setting the locale per-request (for example, from an action).

## Translating validation messages

Hanami integrates with [Dry Validation](//org_guide/dry/dry-validation) for validating input. This is used in the `params` and `contract` blocks in your [actions](//guide/actions/parameters#parameter-validation), and you can also use Dry Validation contract classes of your own throughout your code.

When input is invalid, a contract gives you error messages such as "must be filled". When your app bundles the i18n gem, Hanami translates these messages using your slice's translations. They follow the slice's default locale and current locale, just like the rest of your app.

Add your messages under the `dry_validation.errors` key, using the same keys as Dry Validation:

```yaml
# config/i18n/tl.yml
tl:
  dry_validation:
    errors:
      filled?: "dapat may laman"
```

Error messages then follow the current locale:

```ruby
# app/contracts/signup.rb

module Bookshelf
  module Contracts
    class Signup < Dry::Validation::Contract
      params do
        required(:name).filled(:string)
      end
    end
  end
end
```

```ruby
Hanami.app["i18n"].with_locale(:tl) do
  Bookshelf::Contracts::Signup.new.call(name: "").errors.to_h
end
# => {name: ["dapat may laman"]}
```

When a message is missing from the current locale, Hanami falls back to the slice's [default locale](//page/configuration#default_locale), then to Dry Validation's bundled English messages. For example, if your default locale is `:en` and the current locale is `:tl`, Hanami looks for the `filled?` message in your `tl.yml`, then in your `en.yml`, and finally uses Dry Validation's "must be filled".

Your translations always come first, even before messages from a contract's own `config.messages.load_paths`. This means you can also add English translations to reword Dry Validation's messages across your whole app.

To share validation messages across all your slices, put them in [`config/i18n/shared/`](//page/slices#shared-translations).

To keep Dry Validation's own messages for a contract, give the contract its own messages backend. Hanami doesn't change a backend that you set:

```ruby
class Signup < Dry::Validation::Contract
  config.messages.backend = :yaml
end
```

### Setting the locale for actions

Actions validate their params _before_ they run their `before` callbacks. If you set the locale in a `before` callback, your validation messages won't use it. Set the locale earlier instead, such as in a [Rack middleware](//guide/actions/rack-integration#rack-middleware).

## Next steps

- [Configuration](//page/configuration) covers all the available i18n configuration options.
- [Helpers](//page/helpers) covers the `translate` and `localize` view helpers, including HTML safety and relative key lookup.
- [Slices](//page/slices) covers how i18n works across slices and patterns for sharing translations.
