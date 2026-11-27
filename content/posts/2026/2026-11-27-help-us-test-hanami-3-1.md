---
title: Help us test the Hanami 3.1 release candidate
date: 2026-11-27 13:30:00 UTC
tags: announcements
author: Tim Riley
org: hanami
excerpt: >
  Our Hanami 3.1 release candidate is here, with in-place code reloading, a brand new development error page, lazy view exposures and much more. Come help us test it.
---

Today we're sharing the **release candidate for Hanami 3.1**, feature-complete and ready for testing. Even though it's only been five months since 3.0, this has turned out to be another big one! We'd love your help to give it a good workout before our final release.

## What's coming in 3.1

We'll save the full announcement for when 3.1 ships. For now, here's where we'd love your help with testing.

### In-place code reloading

Code reloading no longer uses Guard. `hanami server` now keeps a single process running, and reloads your app in place on the next request after a file changes. It picks up new, changed, deleted and renamed files, and it waits for any open responses (like streams) to finish first. If reloading fails, you'll see the error right there in your browser.

The `reload` command in `hanami console` now works the same way, so you keep your console session. Underneath both is a new `Hanami.app.reload` API.

To upgrade, delete your `Guardfile`. If you added `guard` or `guard-puma` to your `Gemfile` yourself, you can remove those too. See [Code reloading](/learn/hanami/v3.1/app/code-reloading) for details.

### A new error page

We've replaced better_errors with a brand new, Hanami-native error page. It shows the full cause chain for your exception, lists your routes when you get a 404, and links straight to files in your editor (set `HANAMI_EDITOR` to choose yours). You can also copy the whole error as Markdown. See [Error pages](/learn/hanami/v3.1/app/error-pages) for more.

### Error diagnostics (experimental)

Alongside the new error page comes an experimental new feature: error diagnostics. With diagnostics, your app or gem can explain its own errors on the error page, and offer a fix you can run with one click. A diagnostic is a plain Ruby class, and gems can register their own via their gemspec metadata.

This is a new API, and your feedback will help us shape it. See [Error diagnostics](/learn/hanami/v3.1/app/error-pages#error-diagnostics) to get started.

### Lazy exposures

View exposures are now lazy: they run only when a template reads them, and never if nothing reads them. For most views this is a free performance win. If you need an exposure to run before rendering starts (to raise a "not found" error, say), use `expose!`:

```ruby
expose!(:book) do |id:|
  book_repo.get!(id)
end
```

See [When exposures run](/learn/hanami/v3.1/views/input-and-exposures#when-exposures-run) for more.

### Declared template locals

Templates can now declare their locals with a magic comment. Hanami raises an error for missing or unknown locals, and you can give defaults too. This works with ERB, Haml and Slim.

```erb
<%# locals: (title:, subtitle: nil) %>
<h1><%= title %></h1>
```

See [Declaring locals](/learn/hanami/v3.1/views/templates-and-partials#declaring-locals) for more.

### Response streaming

Actions can now stream their responses with `response.stream`. `send_file` streams too, rather than reading the whole file into memory.

```ruby
def handle(request, response)
  response.stream do |out|
    records.each_slice(500) { |batch| out << serialize(batch) }
  end
end
```

See [Streaming responses](/learn/hanami/v3.1/actions/request-and-response#streaming-responses) for more.

### Settings from YAML files

Hanami now reads settings from `config/settings/default.yml`, as well as a file for each env, like `config/settings/production.yml`. Both files are optional, and values from `ENV` still take precedence. See [YAML settings files](/learn/hanami/v3.1/app/settings#yaml-settings-files) for more.

### Translated validation messages

Validation error messages are now translated using your slice's i18n and its current locale. This covers your contracts as well as the `params` and `contract` blocks in your actions. Messages fall back to English, so English-only apps will see no change. See [Translating validation messages](/learn/hanami/v3.1/i18n#translating-validation-messages) for more.

### Router improvements

Resource routes now support `collection` and `member` blocks, so you can add your own routes to a resource:

```ruby
resources :books do
  collection { get "/latest", to: "books.latest", as: :latest }
  member { post "/publish", to: "books.publish", as: :publish }
end
```

Path and URL generation is also now around 10x faster. And there's a new public `Router#routes` API, along with route formatters, for anyone wanting to build their own route listings. See [Resource routes](/learn/hanami/v3.1/routing#resource-routes) and [Inspecting routes](/learn/hanami/v3.1/routing#inspecting-routes) for more.

### Tuned SQLite by default

Hanami now applies a well-tuned set of pragmas to every SQLite connection, including WAL mode, `synchronous=normal` and memory-mapped I/O. Your SQLite apps should be faster with no extra work. See our [SQLite guide](/learn/hanami/v3.1/database/configuration#sqlite) for more.

### Styled CLI output

The `hanami` CLI got a makeover. Output is now coloured, with neatly aligned file actions and a summary after each `generate` command. `hanami new` shows its progress with spinners and ends with your next steps. Output stays plain when piped, and respects `NO_COLOR`. See [Command output](/learn/hanami/v3.1/cli-commands#command-output) for more.

### JRuby support

Hanami now works on JRuby, across the framework, the CLI, and your database setup. If you run JRuby, we'd love to hear how it goes. See our [JRuby database guide](/learn/hanami/v3.1/database/configuration#jruby) for the JDBC database URLs we support.

## Upgrading an existing app

Already on 3.0? Our [3.1 upgrade notes](/learn/hanami/v3.1/upgrade-notes) walk you through every step, from the required changes through to the optional new features above.

## Try it out

You can try 3.1 in a fresh app with just a few commands:

```shell
$ gem install hanami --pre
$ hanami new my_app
$ cd my_app
$ bin/hanami dev
$ open http://localhost:2300
```

## Tell us how you go!

Right now is when your feedback can make the biggest difference. If you hit a snag or just want to share how it went, come talk to us on our [forum](https://discourse.hanakai.org) or [chat](https://discord.gg/KFCxDmk3JQ). We'd love to hear from you!

Thank you to everyone who's helped on the road to 3.1, and thanks in advance to everyone about to help us test it. :hanami:
