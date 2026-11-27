---
title: Code reloading
---

Hanami reloads your app's code in development, so you can see your changes without restarting anything.

## Reloading the server

When you run `hanami server` (or `hanami dev`) in development, Hanami checks your app's files at the start of each request. If a file has changed since the last request, Hanami reloads the app in place, then handles the request with the fresh code. The server process keeps running the whole time.

Hanami looks for changes to Ruby files, YAML files (such as translations) and templates in your `app/`, `config/`, `lib/` and `slices/` directories. It notices files you edit, add, delete or rename.

Server reloading comes from the hanami-reloader gem, which new apps include in their `Gemfile`:

```ruby
# Gemfile

group :cli, :development do
  gem "hanami-reloader", "~> 3.1"
end
```

It needs no other setup. The gem wraps your app in a Rack middleware when `hanami server` starts, so you don't need to change your `config.ru`.

Each reload is logged to the server output:

```shell
[hanami] Reloaded in 42ms
```

Thanks to [Zeitwerk](//page/autoloading) and [lazy loading](//page), reloading is fast. And since files are only checked when a request comes in, nothing runs in the background while you work.

### Changes that need a restart

Some files are read only once, when your app first loads, so a reload can't apply changes to them. If you change `config/app.rb`, `Gemfile`, `Gemfile.lock`, your `.env` files or your [YAML settings files](//page/settings#yaml-settings-files) in `config/settings/`, Hanami asks you to restart the server:

```shell
[hanami] config/app.rb cannot be reloaded. Restart the server to apply your changes.
```

### Turning off reloading

To start the server without code reloading, use the `--no-code-reloading` option:

```shell
$ bundle exec hanami server --no-code-reloading
```

To turn off server reloading for good, remove hanami-reloader from your `Gemfile`.

## Reloading in the console

If you have a console session open and you change your code, use the `reload` helper to load your updated code:

```ruby
bundle exec hanami console

bookshelf[development]> reload
Reloading... done (38ms)
```

The reload happens in place, so your session stays as it was, keeping your local variables and history.

Objects you made before the reload still use the old classes. After a reload, create or fetch them again to get the new versions.

If a reload fails, fix the error and call `reload` again.

## Reloading with Hanami.app.reload

The server and the console both use `Hanami.app.reload`, which you can also call yourself:

```ruby
Hanami.app.reload
```

This unloads your app and all its slices, then prepares them again. It picks up all your changes, except for the [changes that need a restart](#changes-that-need-a-restart).

Your app class stays the same object, so `run Hanami.app` in `config.ru` can keep working. This is why `config/app.rb` is not reloaded.

## Configuring code reloading

Code reloading is controlled by `config.code_reloading`, which is `true` in development and `false` in all other environments.

To change it, set it in your app class:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.code_reloading = false
  end
end
```

This setting is app-wide: slices use the app's value.
