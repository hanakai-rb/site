---
title: "Hanami 3.0: In full bloom"
date: 2026-06-30 23:30:00 UTC
tags: announcements
author: Tim Riley
image: true
org: hanami
excerpt: >
  New mailers, i18n, and Minitest. Your apps faster by default. Our most complete Hanami yet!
---

From the very beginning we set out to make Hanami a different kind of Ruby framework: clear, modular, and built to grow. Today it comes into full bloom. We're thrilled to share **Hanami 3.0** with you!

This release rounds out the framework with three big new features: **mailers**, **internationalization**, and **Minitest**. On top of that, your apps are now **faster by default**, and your developer experience is sharper, from your logs all the way to your assets.

## First-class mailers

Our long lost gem is back! Hanami apps now come with [integrated mailers][mailers-guide], which feel right at home next to your actions, views, and operations.

Mailer classes describe everything you need to deliver an email:

```ruby
module Bookshelf
  module Mailers
    class Welcome < Bookshelf::Mailer
      from "welcome@bookshelf.test"
      to { |user:| user.email }
      subject { |user:| "Welcome to Bookshelf, #{user.name}!" }

      expose :user
    end
  end
end
```

As standalone objects, mailers are injectable via the [Deps mixin][deps-guide] and accessible wherever you need them. Call `.deliver` and the mailer will use your input to prepare headers and render mail body templates, which work as a fully featured extension of your view layer.

Mailers support multiple delivery methods. SMTP delivery works out of the box: populate some env vars for your SMTP host and you're good to go. In test, your emails are accumulated in memory for you to inspect.

If you need something more, you can also write your own delivery methods. In addition to a clean interface for these, Hanami Mailer provides hooks for threading delivery options all the way through your mailers, allowing new delivery methods to make the most of special features offered by email delivery providers.

Like all our gems, Hanami Mailer is also designed for standalone use. Check out the comprehensive [README][mailer-readme] for everything you need to know about using it in your Ruby app.

Hanami Mailer leans on the venerable mail gem to handle all its low-level mail wrangling. Thank you to the [mail maintainers][mail-maintainers] for all their work over the years!

[mailers-guide]: /learn/hanami/v3.0/mailers
[deps-guide]: /learn/hanami/v3.0/app/container-and-components#injecting-dependencies-via-deps
[mailer-readme]: https://github.com/hanami/hanami-mailer/#readme-ov-file
[mail-maintainers]: https://github.com/mikel/mail/graphs/contributors?all=1

## Built-in internationalization

Taking your apps to the world just got easier: i18n is now [built right into Hanami][i18n-guide]. Bundle the [i18n gem][i18n-gem] and Hanami sets up a self-contained translation backend in your app and every slice, with `translate` and `localize` helpers ready to use across your actions and views.

Your translations live in `config/i18n/` in your app or slice:

```yaml
# config/i18n/en.yml
en:
  posts:
    index:
      title: "Latest posts"
    create:
      created: "Your post is live!"
  greetings:
    welcome: "Welcome, %{name}!"
```

From there, i18n helpers are everywhere you'd expect them! Like in your views:

```erb
<%# app/templates/posts/index.html.erb %>
<h1><%= t(".title") %></h1>
```

And your actions:

```ruby
# app/actions/posts/create.rb
def handle(request, response)
  response.flash[:notice] = t(".created")
  # ...
end
```

And for everywhere else, the `"i18n"` component is just one Deps mixin away:

```ruby
class Greeter
  include Deps["i18n"]

  def call(name)
    i18n.t("greetings.welcome", name:)
  end
end
```

We've got localization too. `localize` formats your dates and times for the current locale, and ships with sensible defaults for English:

```ruby
localize(Date.new(2026, 5, 22))
# => "Fri, 22 May 2026"

localize(Time.new(2026, 5, 22, 9, 5), format: :short)
# => "22 May 9:05 am"
```

Like every aspect of Hanami, i18n is designed to work out of the box with minimal setup, but there are plenty of settings if you need something custom. Check out the [i18n guide][i18n-guide] for the full picture.

You can't spell _internationalization_ without the i18n gem, which does all the heavy lifting for this new feature. So a big `en-AU` "cheers, mates" to the [i18n maintainers][i18n-maintainers] — thank you for helping Rubyists the world over!

[i18n-gem]: https://github.com/ruby-i18n/i18n
[i18n-guide]: /learn/hanami/v3.0/i18n
[i18n-maintainers]: https://github.com/ruby-i18n/i18n/graphs/contributors?all=1

## Now with Minitest

Hanami has always shipped with a ready-to-go RSpec setup. We're delighted we can finally make the other half of you happy, thanks to our brand new Minitest support!

Pick your testing framework when you generate an app:

```shell
$ hanami new my_app --test=minitest
```

RSpec stays our default, but reach for Minitest and you'll now get an equally complete setup, rather than having to build something yourself.

A big thank you to Ryan Davis and all the contributors for their work on Minitest. Minitest ships with Ruby itself, and we're glad to make it part of the Hanami story going forward.

## Faster by default

Hanami 3.0 is significantly faster, and you can enjoy the benefits right from the get-go. In a test app, the same request runs **nearly 3x faster over HTTP** while allocating a fraction of the memory.

Hanami now **memoizes your components by default**. This means that each component in your app's containers is resolved just once and then reused, rather than built fresh every time it's needed.

This is the change you'll really feel. We took an app whose action resolves a graph of nine components and renders a view, then measured the same request on 2.3 and 3.0. In 3.0, there were **14x fewer allocations per request** and **nearly 3x the throughput over HTTP** (and **closer to 9x throughput** when measured in-process, where the server isn't the bottleneck). Tail latency dropped sharply too: p99 reduced from 89ms to 4ms as the per-request allocation churn and GC pauses went away.

We also focused on improving performance across the hottest parts of the framework:

- Hanami Action snapshots each action's config up front rather than recomputing it per-request, and overall allocates far less per request. A minimal action drops from **88 allocations to 17** — that's **80% fewer** — and runs around **3.7x faster** in isolation.
- Hanami View gets the same config snapshot treatment, and also no longer decorates exposures by default. A minimal render drops from **100 allocations to 42** and runs around **2.9x faster**.

The best part of all this? It's a free lunch! Upgrade to 3.0 and your apps simply run faster, on less memory, all without any changes to your code.

A special thank you to [Sean Collins](https://github.com/cllns) for driving much of our performance work for 3.0. We love you nearly 3x more than before!

## Clearer, more useful logs

We've given logs some love for 3.0, across both day-to-day development and production.

In development, logs are now colorized by default. SQL statements are formatted to match your request logs, and they're also syntax highlighted when the rouge gem is bundled.

![Hanami logs](/blog/assets/2026-06-30-hanami-3-0-in-full-bloom/logs.webp)

SQL statements now log at the `:debug` level rather than `:info`, for quieter production logs, and you can tune this with `config.db.log_level`.

You can also conveniently set the log level from the env with `HANAMI_LOG_LEVEL`, which takes precedence over any config in your app class.

Underneath, Hanami now guarantees a consistent interface for its logger (even if you configure a third-party replacement), so you can always count on:

- **Structured logging**, via keyword args passed to the standard log methods.
- **Tagged logging**, via `#tagged` blocks.

Read our [revamped logger guide][logger-guide] to learn more.

[logger-guide]: /learn/hanami/v3.0/logger

## Smoother asset watching

`hanami assets watch` now keeps pace with more of your work: it picks up newly added and removed entry points, and reacts to changes in static assets like images and fonts. In earlier versions, each of these meant restarting the watcher. Now it just keeps up, so you can stay in the flow!

We also published a [spec][assets-spec] covering how any asset bundler can plug cleanly into Hanami. Our own bundler is based on esbuild, but we don't want you to feel locked in! We'd love to see you bring your favorite bundler to Hanami.

[assets-spec]: https://github.com/hanami/hanami-assets/blob/main/SPEC.md

## Body parsing comes to Hanami Action

Hanami's request body parsing has moved out of middleware and into Hanami Action, where it's now driven by your `formats` config. Your actions parse exactly the formats you accept, and you can configure this right alongside the rest of your content negotiation.

Parsers for multipart form bodies and JSON work out of the box. And if you need something else, you can register your own:

```ruby
formats.register(:custom, "application/custom", parser: ->(body, env) { ... })
```

Learn more in our [formats and media types][formats-guide] guide.

[formats-guide]: /learn/hanami/v3.0/actions/formats-and-media-types

## Simpler views with undecorated exposures

[View exposures][exposures-guide] are now undecorated by default. Your templates receive exactly what you expose, with no decoration unless you ask for it. This is a more predictable default, and avoids extra work when decoration isn't strictly required.

When you do want to decorate, the new `.decorate` method makes those exposures stand out in your code. You can also bring back the old behaviour across a view with `config.decorate_exposures = true`.

[exposures-guide]: /learn/hanami/v3.0/views/input-and-exposures

## A cleaner foundation

A major new version is a chance to put the house in order:

- **hanami-controller is now hanami-action.** The gem name finally matches the classes we've been using for years. Require it as `hanami-action` or `hanami/action`.
- **hanami-validations has been retired.** Hanami Action now reaches for dry-validation directly for your action's params and contracts, with one fewer gem in between.

Hanami 3.0 also requires Ruby 3.3 or newer.

The result is fewer moving parts, clearer names for the gems we use, and a more approachable Hanami overall.

## And much more!

We've landed plenty of smaller refinements in 3.0 too:

- New `hanami generate provider` and `hanami generate mailer` generators.
- A `--force` option across all generators, to overwrite existing files instead of stopping.
- A `--name` option for `hanami new`, to set the app namespace separately from the directory path: `hanami new my_bookshelf --name=bookshelf`.
- `--gem-source=gem.coop` for `hanami new` installs gems [from](https://gem.coop/@hanami) [our](https://gem.coop/@dry) gem.coop namespaces.
- Generated apps require Puma 7.1 and drop app preloading boilerplate from `config/puma.rb`.
- A `--template-engine` option for `hanami new` and `hanami generate` creates templates for the given engine (`erb`, `haml`, or `slim`). Set a project-wide default with `config.default_template_engine` in your app class.
- Explicit redirect helpers in the router: `permanent_redirect` (301) and `temporary_redirect` (302), with plain `redirect` now requiring an explicit `code:` argument for clarity.
- `Hanami::Settings::CompositeStore` for chaining settings lookups across multiple stores.
- `Hanami::Slice.with_slices` returns a slice together with all its nested slices.
- Hanami View exposes the currently-rendering template name as `Hanami::View::Scope#template_name` and `Hanami::View::Context#current_template_name` (this supports our relative i18n key lookups).
- Raise a helpful error when a slice is called as a Rack app with no routes available.
- Various fixes: multipart uploads to the router, URL generation with array variables, duplicate routes on `generate action`, and more.
- A beautiful new welcome screen, matching our Hanakai visuals. (Thank you [Max](https://github.com/makenosound)!)

![Welcome screen in light mode](/blog/assets/2026-06-30-hanami-3-0-in-full-bloom/hanami-3-welcome-light.webp)

![Welcome screen in dark mode](/blog/assets/2026-06-30-hanami-3-0-in-full-bloom/hanami-3-welcome-dark.webp)

## Try it out

You're only a few commands away from a new Hanami 3.0 app:

```shell
$ gem install hanami
$ hanami new my_app
$ cd my_app
$ bin/hanami dev
$ open http://localhost:2300
```

We'd love to hear how you go! Come say hi in our [forum](https://discourse.hanakai.org) or our [chat](https://discord.gg/KFCxDmk3JQ). Our community is super friendly and always willing to help you on your Hanami journey.

## Upgrading from 2.3

Already on 2.3? Our [3.0 upgrade notes](/learn/hanami/v3.0/upgrade-notes) walk you through every step.

## Thank you to our contributors!

Thank you to everyone who contributed to this release:

- [Aaron Allen](https://github.com/aaronmallen)
- [Adam Lassek](https://github.com/adamlassek)
- [Carolyn Cole](https://github.com/carolyncole)
- [Edouard](https://github.com/inouire)
- [Jane Sandberg](https://github.com/sandbergja)
- [Joshua Young](https://github.com/joshuay03)
- [Konstantin Haase](https://github.com/rkh)
- [Kyle Plump](https://github.com/kyleplump)
- [Matthew Stanton](https://github.com/StantonMatt)
- [Max Wheeler](https://github.com/makenosound)
- [Paweł Świątkowski](https://github.com/katafrakt)
- [Philip Arndt](https://github.com/parndt)
- [Ramón Valles](https://github.com/rvmtz)
- [Sean Collins](https://github.com/cllns)
- [Tim Riley](https://github.com/timriley)
- [Wout](https://github.com/wout)
- [Yi Sangwon](https://github.com/yosangwon)

## Thank you to our sponsors!

This release is another huge step forward for Hanami, and there's no way we could have done this without the support of our [sponsors](/sponsor). Thank you, from the bottom of my heart!

Thank you to our business sponsors:

- **[Sidekiq](https://sidekiq.org)**, our Platinum sponsor.
- **[Brandon Weaver](https://github.com/baweaver)**, our Gold sponsor.
- **[Honeybadger](https://www.honeybadger.io)**, **[FastRuby.io](https://www.fastruby.io)**, **[AppSignal](https://www.appsignal.com)** and **[SerpApi](https://serpapi.com)**, our Silver sponsors.

And thank you to all the individuals supporting Hanakai through [GitHub Sponsors](https://github.com/sponsors/hanami) and [Open Collective](https://opencollective.com/hanami). Your encouragement means the world!

Hanami is in full bloom today, but a garden is never finished, and there's plenty more we want to grow. Your support is what makes that possible. We'd love for you to [become a sponsor](/sponsor). :hanami:
