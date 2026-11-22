---
title: Help us test the Hanami 3.0 release candidate
date: 2026-06-16 13:00:00 UTC
tags: announcements
author: Tim Riley
org: hanami
excerpt: >
  Our Hanami 3.0 release candidate is here. Come help us test it.
---

Today we're sharing the **release candidate for Hanami 3.0**, feature-complete and ready for testing. We'd love your help to give it a good workout before our final release—which, all going well, will be in just a couple of weeks!

## What's coming in 3.0

There's a lot I'm excited for in 3.0, but I'll save the full announcement for when it ships. For now, here's where we'd love your help with testing.

### Built-in i18n

Internationalization is now a built-in feature. Bundle the `i18n` gem and Hanami loads your translations and makes translation and localization helpers available across your views and actions. See [Previewing i18n integration in Hanami 3.0](https://discourse.hanakai.org/t/previewing-i18n-integration-in-hanami-3-0/1400/6) for details.

### First-class mailers

We've rebuilt [Hanami Mailer](https://github.com/hanami/hanami-mailer) and integrated it into the framework, with generators, templates, and SMTP delivery. See [Previewing mailers in Hanami 3.0](https://discourse.hanakai.org/t/previewing-mailers-in-hanami-3-0/1462/3) for more.

### Minitest support

We've created a new [Hanami Minitest](https://github.com/hanami/hanami-minitest) gem to give you a fully integrated Minitest setup. Activate it with `hanami new --test=minitest`. See all the details in [Feedback on Hanami Minitest](https://discourse.hanakai.org/t/feedback-on-hanami-minitest/1415/10).

### Memoized components

Container components are now memoized by default: each is resolved once and reused, instead of being built fresh each time. This is one of several performance improvements landing in 3.0, and a good one to test. If you have a component that cannot safely be memoized, you can opt it out.

### Improved logging

Web and SQL logs are colorized by default in development. SQL queries are now logged as consistently structured entries, syntax highlighted when the `rouge` gem is bundled. SQL logs are now emitted at the `:debug` level for cleaner production logs, which you can adjust with `config.db.log_level`.

Hanami ensures that structured and tagged logging is available even if you configure your own alternative logger. Emit structured logs via keyword args on the main log methods, and tagged logs via `tagged` blocks. You can also now control the overall app log level via a `HANAMI_LOG_LEVEL` env var.

### Smoother asset watching

`hanami assets watch` now keeps up with more of your changes: it picks up newly added or removed entry points, and reacts to edits to static assets like images and fonts. Previously, both meant restarting the watcher.

### Other changes

Here are a few more changes worth flagging, especially if you're upgrading an existing app:

- The actions gem is renamed from hanami-controller to hanami-action.
- The hanami-validations gem is retired. Hanami Action now checks for dry-validation directly.
- Views default to undecorated exposures.
- Request body parsing has moved into Hanami Action, driven by your formats config.
- Hanami now requires Ruby 3.3 or newer.

## Upgrading an existing app

Already on 2.3? Our [3.0 upgrade notes](/learn/hanami/v3.0/upgrade-notes) walk you through every step, from the required changes through to the optional new features above.

## Try it out

You can step into the 3.0 future with just a few commands:

```shell
$ gem install hanami --pre
$ hanami new my_app
$ cd my_app
$ bin/hanami dev
$ open http://localhost:2300
```

## Tell us how you go!

This is the moment your feedback makes the biggest difference. If you hit a snag or just want to share how it went, come talk to us on our [forum](https://discourse.hanakai.org) or [chat](https://discord.gg/KFCxDmk3JQ). We'd love to hear from you!

Thank you to everyone who's helped on the road to 3.0, and thanks in advance to everyone about to help us test it. 🌸
