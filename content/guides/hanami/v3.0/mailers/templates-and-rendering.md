---
title: Templates and rendering
---

A mailer renders its bodies with [Hanami View](//guide/views). Each mailer builds its own view behind the scenes, so your templates, exposures and helpers behave just like they do elsewhere in your app.

## Templates

A mailer has two body formats, `:html` and `:text`, each rendered from its own template. The format is the first extension in the template file name:

- `app/templates/mailers/welcome.html.erb` provides the `:html` body
- `app/templates/mailers/welcome.text.erb` provides the `:text` body

The template name is inferred from the mailer's name. `Bookshelf::Mailers::Welcome` renders the `mailers/welcome` template, found under `app/templates/mailers/`. A mailer in a deeper namespace keeps its path: `Bookshelf::Mailers::Notifications::Welcome` renders `mailers/notifications/welcome`.

Your [exposures](//page/exposures-and-input) are available in the templates as locals:

```erb
<%# app/templates/mailers/welcome.html.erb %>

<h1>Welcome, <%= user[:name] %>!</h1>
```

```erb
<%# app/templates/mailers/welcome.text.erb %>

Welcome, <%= user[:name] %>!
```

## Formats

Both HTML and text will render by default, producing a multipart email. If only one template exists, the mailer renders that format only.

To render a single format explicitly, pass `format:` to `deliver` (or `prepare`):

```ruby
welcome_mailer.deliver(user:, format: :html)
```

When rendering both formats, a missing template for one of them is tolerated, and only the available format is rendered. Requesting a specific format whose template is missing raises a `Hanami::View::TemplateNotFoundError`.

## View integration in your app

Inside a Hanami app, mailer views are built from your slice's view class. This means mailer templates share everything your other [view templates](//guide/views) have: the slice's [context](//guide/views/context), [parts](//guide/views/parts), [scopes](//guide/views/scopes), template paths and [helpers](//guide/helpers), including [i18n](//guide/i18n).

The only thing not available to mailer templates is request-related state — `request`, `session`, `flash` and `csrf_token` — because mailers aren't rendered from a request. Using one of these in a mailer template raises an error.

### Customizing the mailer view

To customize rendering across all your mailers, define a `Mailers::View` in your slice at `app/mailers/view.rb`. Because it lives in your slice, it's configured automatically, and every mailer's view inherits from it.

This is a good home for anything every email needs. For example, since mailer templates have no request to build links from, you might expose your app's base URL for use across all your emails:

```ruby
# app/mailers/view.rb

module Bookshelf
  module Mailers
    class View < Bookshelf::View
      include Deps["settings"]

      expose :base_url do
        settings.base_url
      end
    end
  end
end
```

```erb
<%# app/templates/mailers/welcome.html.erb %>

<p>Welcome, <%= user[:name] %>! <a href="<%= base_url %>/books">Browse the shelves</a>.</p>
```

### Decorating exposures with parts

When Hanami View is integrated, `decorate` exposes a value wrapped in a matching [view part](//guide/views/parts), so you can add presentation methods to the data your templates render:

```ruby
class WelcomeMailer < Bookshelf::Mailer
  from "welcome@bookshelf.test"
  to { |user:| user.email }
  subject "Welcome!"

  decorate :user
end
```

`decorate` is shorthand for `expose(..., decorate: true)`.

## Layouts

Mailers don't use a layout by default. To wrap your bodies in one, configure `config.layout` on the mailer (or your base mailer class), pointing at a template under your view's layouts directory:

```ruby
module Bookshelf
  class Mailer < Hanami::Mailer
    config.layout = "mailer"
  end
end
```

## Rendering without Hanami View

Mailers can render their bodies without Hanami View. This is useful for standalone projects that don't use it, or as a hook for another rendering system.

Override `render_view`, returning the body for each format:

```ruby
class CustomMailer < Hanami::Mailer
  from "custom@example.com"
  to { |user:| user[:email] }
  subject "Hello"

  expose :user

  private

  def render_view(format, input)
    user = input[:user]

    case format
    when :html then "<h1>Hello, #{user[:name]}!</h1>"
    when :text then "Hello, #{user[:name]}!"
    end
  end
end
```

If Hanami View is installed but you don't want a mailer building a view from it, turn off automatic view building with `config.integrate_view = false`. Your `render_view` then takes full responsibility for rendering.

## Standalone configuration

Outside a Hanami app, a mailer needs to know where to find its templates. Set `config.paths`, and optionally `config.template` to name the template explicitly:

```ruby
class WelcomeMailer < Hanami::Mailer
  config.paths = ["app/templates/mailers"]
  config.template = "welcome"

  from "welcome@example.com"
  to { |user:| user[:email] }
  subject "Welcome!"

  expose :user
end
```

To render through an existing, already-configured view class, set `config.view_class`. The mailer's view inherits that class's configuration — context, parts, scopes, paths and helpers — which is exactly how mailers in a Hanami app pick up the app's view behavior. With a view class configured, you typically don't need to set `config.paths` yourself.
