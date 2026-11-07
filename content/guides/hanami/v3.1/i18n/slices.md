---
title: Slices
---

By default, each [slice](//guide/app/slices) in your app gets its own isolated i18n backend. This means each slice has its own translations, its own locale state, and its own configuration.

This isolation suits apps where slices represent distinct bounded contexts, each with their own translation needs. But Hanami also supports a range of sharing patterns for apps where some or all translations should be common across slices.

## Per-slice configuration

Each slice can configure its own i18n settings independently. Settings configured on the app are inherited by slices unless they override them:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.i18n.default_locale = :en
  end
end
```

```ruby
# config/slices/admin.rb

module Admin
  class Slice < Hanami::Slice
    # Override the default locale for the admin slice only
    config.i18n.default_locale = :de
  end
end
```

Each slice also looks for its own `config/i18n/` directory at its own root. For example, the `admin` slice would load translations from `slices/admin/config/i18n/`.

## Full isolation (default)

By default, each slice has its own i18n instance with its own translations, with no sharing between them:

```
config/i18n/en.yml          # App-only translations
slices/admin/config/i18n/en.yml  # Admin-only translations
slices/main/config/i18n/en.yml   # Main-only translations
```

Each slice's i18n instance sees only the translations from its own `config/i18n/` directory:

```ruby
Hanami.app["i18n"].t("admin_message")     # => "admin_message" (missing)
Admin::Slice["i18n"].t("admin_message")   # => "Admin area"
Main::Slice["i18n"].t("admin_message")    # => "admin_message" (missing)
```

This is the simplest pattern and a good fit for apps where each slice has its own translation needs.

## Shared translations via config/i18n/shared/

Files under `config/i18n/shared/` in your app are loaded into _every_ slice's i18n backend by default, without needing to duplicate them per-slice. Each slice still has its own i18n instance with its own locale state, but they all share these base translations.

```
config/i18n/shared/en.yml        # Loaded into every slice
config/i18n/en.yml               # App slice only
slices/admin/config/i18n/en.yml  # Admin slice only
```

```yaml
# config/i18n/shared/en.yml
en:
  validation:
    required: "This field is required"
```

```ruby
Hanami.app["i18n"].t("validation.required")    # => "This field is required"
Admin::Slice["i18n"].t("validation.required")  # => "This field is required"
Main::Slice["i18n"].t("validation.required")   # => "This field is required"
```

Shared files are loaded _before_ each slice's own translations, so slice-specific translations override shared keys for that slice:

```yaml
# slices/admin/config/i18n/en.yml
en:
  validation:
    required: "Admin: this is required"
```

```ruby
Admin::Slice["i18n"].t("validation.required")  # => "Admin: this is required"
Main::Slice["i18n"].t("validation.required")   # => "This field is required"
```

This is the recommended pattern for apps that need common base translations (validation messages, shared UI labels, common `date.*` and `time.*` formats) while still keeping slice-specific translations distinct.

### Disabling or relocating shared translations

To disable shared translations for the whole app, set [`shared_load_path`](//page/configuration#shared-load-path) to `[]`:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.i18n.shared_load_path = []
  end
end
```

To opt a single slice out of shared translations:

```ruby
# config/slices/main.rb

module Main
  class Slice < Hanami::Slice
    config.i18n.shared_load_path = []
  end
end
```

To use a different directory for shared translations:

```ruby
config.i18n.shared_load_path = ["config/i18n_baseline/**/*.yml"]
```

## Full sharing via shared_app_component_keys

For apps that don't need per-slice translations at all, you can have every slice use the app's i18n component directly. This means a single i18n instance is shared across the app and all slices, including the current locale state:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.shared_app_component_keys += ["i18n"]
  end
end
```

With this in place, all slices see the same translations and share the same locale state. Changing the locale via `Admin::Slice["i18n"].locale = :tl` also affects the app and any other slice:

```ruby
Hanami.app["i18n"]    # => same instance as Admin::Slice["i18n"]
Admin::Slice["i18n"]  # => same instance as Main::Slice["i18n"]
```

This is the simplest approach if your app doesn't really have per-slice translation needs.

### Mixing patterns

You can also have some slices share the app's i18n while others remain isolated. To opt a slice out of sharing when `"i18n"` is in `shared_app_component_keys`:

```ruby
# config/slices/search.rb

module Search
  class Slice < Hanami::Slice
    config.shared_app_component_keys -= ["i18n"]
  end
end
```

With this configuration, the `search` slice has its own isolated i18n backend (and reads its own `slices/search/config/i18n/` directory), while other slices continue to share the app's instance.

## Shared base translations with slice-specific overrides

If you want each slice to have its own i18n instance (and its own locale state) while still inheriting a common base set of translations from the app, configure the app's [`load_path`](//page/configuration#load-path) with absolute paths so that slices can include them:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.i18n.load_path = [
      root.join("config/i18n/**/*.yml").to_s
    ]
  end
end
```

```ruby
# config/slices/admin.rb

module Admin
  class Slice < Hanami::Slice
    config.i18n.load_path += ["config/i18n/**/*.yml"]
  end
end
```

The app's load path uses an absolute path (via `root.join(...).to_s`), so each slice that inherits it can still resolve those files. Each slice then appends its own relative `config/i18n/**/*.yml` to add slice-specific translations.

In most cases, the [shared translations directory](#shared-translations-via-config-i18n-shared) is a simpler way to achieve the same outcome. Reach for this pattern only when you need finer-grained control over which paths each slice loads.
