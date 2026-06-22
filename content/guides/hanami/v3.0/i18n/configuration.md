---
title: Configuration
---

Hanami's i18n integration is configured via `config.i18n` in your app class or any slice class. Each setting can be configured independently per slice, and slices inherit defaults from the app.

```ruby
# config/app.rb

require "hanami"

module Bookshelf
  class App < Hanami::App
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :tl, :de]
    config.i18n.fallbacks = true
  end
end
```

## default_locale

The locale to use when no other locale is set. Defaults to `:en`.

```ruby
config.i18n.default_locale = :tl
```

The default locale is used as the initial value of `Hanami.app["i18n"].locale`, and as the locale for any `translate` or `localize` call that doesn't explicitly supply one.

## available_locales

The list of locales that should be considered available for the app. Defaults to `[]`, meaning every locale that appears in your translation files is available.

```ruby
config.i18n.available_locales = [:en, :tl, :de]
```

When set, only the listed locales are returned from `Hanami.app["i18n"].available_locales`, even if translation files exist for other locales. This is useful for limiting the locales that your app accepts, regardless of which translation files happen to be loaded.

## load_path

The list of file path patterns from which translation files are loaded. Defaults to `["config/i18n/**/*.{yml,yaml,json,rb}"]`.

Relative patterns are resolved against the slice's own root. Absolute paths are used as-is.

To add a custom path alongside the default:

```ruby
config.i18n.load_path += ["config/custom_translations/**/*.yml"]
```

To replace the default entirely:

```ruby
config.i18n.load_path = ["translations/**/*.yml"]
```

## shared_load_path

The list of file path patterns for translation files that should be loaded into _every_ slice's i18n backend. Defaults to `["config/i18n/shared/**/*.{yml,yaml,json,rb}"]`.

Relative patterns are resolved against the **app root**, regardless of which slice is being loaded. This is the recommended place for foundational translation data needed everywhere in your app, such as base validation messages or shared `date.*` and `time.*` keys.

Shared files are loaded into each slice's backend _before_ that slice's own [`load_path`](#load-path) files, so slice-specific translations can override the shared ones.

To disable shared translations for the app entirely:

```ruby
config.i18n.shared_load_path = []
```

To relocate the shared directory:

```ruby
config.i18n.shared_load_path = ["config/i18n_baseline/**/*.yml"]
```

See [Slices](//page/slices) for more on how shared translations work across slices.

## fallbacks

Configures locale fallbacks for missing translations. Defaults to `nil` (fallbacks disabled).

Set to `true` to enable fallback to the [default locale](#default-locale):

```ruby
config.i18n.fallbacks = true
```

Set to an array to use a custom default fallback chain for all locales:

```ruby
config.i18n.fallbacks = [:en]
```

Set to a hash to configure explicit fallback chains per locale:

```ruby
config.i18n.fallbacks = {
  de: [:de, :en],
  tl: [:tl, :en]
}
```

Fallbacks are applied only when using the default i18n backend. Custom backends (see [Custom backends](#custom-backends)) are expected to handle their own fallback logic.

## Custom backends

The i18n provider uses [`I18n::Backend::Simple`](https://github.com/ruby-i18n/i18n) by default. To use a different backend, configure the provider directly via `config/providers/i18n.rb`:

```ruby
# config/providers/i18n.rb

Hanami.app.configure_provider(:i18n) do
  configure do |config|
    config.default_locale = :tl
    config.available_locales = [:tl, :de]
  end

  before :start do
    backend = I18n::Backend::Simple.new
    backend.store_translations(:tl, greeting: "Kumusta")
    backend.store_translations(:de, greeting: "Hallo")

    config.backend = backend
  end
end
```

When a custom backend is supplied, Hanami won't load any translation files into it (your custom backend is expected to manage its own loading), and the [`fallbacks`](#fallbacks) setting is ignored.

## Bundled English defaults

Hanami ships with a small set of English (`:en`) translations for date and time formatting. These are loaded into every slice's i18n backend before any of your own translations, so `localize` works out of the box without any setup:

```ruby
Hanami.app["i18n"].l(Date.new(2026, 5, 22), format: :short)
# => "22 May"

Hanami.app["i18n"].l(Time.now, format: :long)
# => "22 May 2026 9:05 am"
```

The [bundled defaults](https://github.com/hanami/hanami/blob/main/lib/hanami/providers/i18n/locale/en.yml) provide:

- `date.formats.default`, `date.formats.short`, `date.formats.long`
- `date.day_names`, `date.abbr_day_names`
- `date.month_names`, `date.abbr_month_names`
- `time.formats.default`, `time.formats.short`, `time.formats.long`
- `time.am`, `time.pm`

You can override any of these by setting the same keys in your own translation files:

```yaml
# config/i18n/en.yml
en:
  date:
    formats:
      short: "%d/%m/%Y"
```

Keys you don't override continue to use the bundled values.
