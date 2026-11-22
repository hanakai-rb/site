---
title: Helpers
---

Hanami makes `translate` and `localize` helpers available in your [actions](//guide/actions) and in your [view](//guide/views) templates, parts and scopes. Both have short aliases: `t` and `l`.

These helpers translate and localize content using the i18n backend belonging to the slice that owns the action or view, so each slice's actions and views see only that slice's translations (unless you've configured them to share, see [Slices](//page/slices)).

Actions and views also expose the i18n backend directly as `i18n`, which you can use to access the full backend API:

```ruby
class Create < Bookshelf::Action
  def handle(request, response)
    i18n.with_locale(request.params[:locale]) do
      # ...
    end
  end
end
```

The examples below show the helpers as plain method calls. They read the same in templates, actions, parts and scopes.

## translate

`translate` (aliased to `t`) looks up the given key from the slice's translation files:

```ruby
t("messages.welcome") # => "Welcome to Bookshelf"
```

Pass a `:locale` option to translate against a different locale:

```ruby
t("greeting", locale: :tl) # => "Kumusta!"
```

Any other keyword arguments are used as interpolation values:

```yaml
# config/i18n/en.yml
en:
  greeting: "Hello, %{name}!"
```

```ruby
t("greeting", name: "Alice") # => "Hello, Alice!"
```

You can also pass any of the standard i18n options like `:scope`, `:default` and `:count`. See the [i18n gem](https://github.com/ruby-i18n/i18n) documentation for the full list.

## Missing translations

By default, when a translation is missing, `translate` returns a `<span class="translation_missing">` element containing the missing key. This makes missing translations easy to spot during development:

```ruby
t("missing.key")
# => '<span class="translation_missing" title="...">missing.key</span>'
```

To return a custom fallback string instead, pass `:default`:

```ruby
t("missing.key", default: "Fallback text") # => "Fallback text"
```

To raise an error for missing translations, pass `raise: true` or use `translate!` (aliased to `t!`):

```ruby
t!("missing.key") # raises I18n::MissingTranslationData
```

## HTML-safe keys

When a key's final segment is `html` (e.g. `legal.html`) or ends in `_html` (e.g. `greeting_html`), the result is marked HTML-safe so its tags are not escaped when rendered. Any interpolated string values are HTML-escaped first, to keep untrusted input safe.

```yaml
# config/i18n/en.yml
en:
  greeting_html: "Hello, <strong>%{name}</strong>!"
```

```ruby
t("greeting_html", name: "<Alice>")
# => "Hello, <strong>&lt;Alice&gt;</strong>!"
```

Already-HTML-safe interpolation values (such as the result of another helper) are passed through unescaped:

```ruby
t("greeting_html", name: raw("<em>Alice</em>"))
# => "Hello, <strong><em>Alice</em></strong>!"
```

## Relative keys

A key that begins with `.` is treated as relative to the place it's called from. The exact resolution depends on whether you're in a template or an action.

### In templates

Inside a template, a relative key is resolved against the currently-rendering template's name. Slashes in the template name become dots, and partial basenames keep their leading underscore.

For example, given this translation file:

```yaml
# config/i18n/en.yml
en:
  users:
    index:
      title: "All users"
    _form:
      label: "Name"
```

In `app/templates/users/index.html.erb`, `t(".title")` resolves to `users.index.title`:

```ruby
t(".title") # => "All users"
```

In the partial `app/templates/users/_form.html.erb`, `t(".label")` resolves to `users._form.label`:

```ruby
t(".label") # => "Name"
```

Relative keys can only be used during a template render. Calling `t(".title")` outside of a template (for example, from a part or scope method that isn't rendering a template) raises `I18n::ArgumentError`.

### In actions

Inside an action, a relative key is resolved against the action's name. The slice namespace and the `Actions` module are stripped, the remaining segments are downcased, and `::` becomes `.`.

For example, given this translation file:

```yaml
# config/i18n/en.yml
en:
  posts:
    show:
      not_found: "We couldn't find that post"
    create:
      success: "Post created"
```

In `Bookshelf::Actions::Posts::Show`, `t(".not_found")` resolves to `posts.show.not_found`:

```ruby
module Bookshelf
  module Actions
    module Posts
      class Show < Bookshelf::Action
        def handle(request, response)
          response.status = 404
          response.body = t(".not_found")
        end
      end
    end
  end
end
```

And in `Bookshelf::Actions::Posts::Create`, `t(".success")` resolves to `posts.create.success`:

```ruby
response.flash[:notice] = t(".success")
```

Relative keys are only available in actions defined inside a slice. Calling `t(".something")` from an action that hasn't been integrated with a slice raises `I18n::ArgumentError`.

## localize

`localize` (aliased to `l`) formats a `Date`, `Time` or `DateTime` according to the current locale:

```ruby
l(Date.today, format: :short) # => "22 May"
```

Symbol formats are resolved through the slice's translations. For example, `format: :short` for a date is looked up at `date.formats.short`, and `format: :long` for a time at `time.formats.long`. Pass a string instead to use a literal `strftime` format:

```ruby
l(Date.today, format: "%B %d") # => "May 22"
```

Locale-dependent strftime codes (`%a`, `%A`, `%b`, `%B`, `%p`, `%P`) are resolved through the slice's translations too, so day and month names respect the current locale.

To localize against a specific locale, pass `:locale`:

```ruby
l(Date.today, format: :long, locale: :tl)
```

Hanami ships with English defaults for the common date and time formats, so `localize` works without any configuration. See [Bundled English defaults](//page/configuration#bundled-english-defaults) for details on what's included and how to override it.
