---
title: Error pages
---

When an error goes unhandled in development, Hanami shows a detailed error page in your browser. The page shows the exception, its backtrace and the request, and gives you an interactive console for each frame of the backtrace.

The error page comes from the hanami-webconsole gem, which new Hanami apps include in the `:development` group of their `Gemfile`. You can turn the page on or off with the `config.render_detailed_errors` app setting, which defaults to `true` in development only.

The error page is shown only to requests from your own machine only (from a loopback address such as `127.0.0.1`).

To learn about the error pages that your app shows in production, see [Rendering errors](//guide/views/rendering-errors).

## Opening files in your editor

Each frame in the backtrace has a link to open its file in your editor. To choose your editor, set the `HANAMI_EDITOR` environment variable to one of the following:

- `vscode` (or `code`)
- `vscodium` (or `codium`)
- `cursor`
- `zed`
- `subl` (or `sublime`, `st`)
- `txmt` (or `textmate`, `tm`, `mate`)

```shell
$ HANAMI_EDITOR=zed bundle exec hanami server
```

Without `HANAMI_EDITOR`, Hanami looks for one of these editors in your `VISUAL` or `EDITOR` environment variables (so `EDITOR="code -w"` gives VS Code). Otherwise, it links to VS Code.

<!-- TODO: The diagnostic example in this section was checked against hanami-webconsole's API, but it was not run. Its 'no such table' check works only for SQLite. Test it, or use a better example. -->

## Error diagnostics

> [!NOTE]
> Error diagnostics are experimental. Their API may change in a later release. Please give them a try and share your feedback!

Diagnostics let your app or gem explain its own errors on the error page, and optionally offer a fix that you can run with one click.

A diagnostic is a plain Ruby class. It's built with the exception and a context object, and can supply any of these methods:

- `applies?`: return false to skip this diagnostic for a particular exception
- `title`: a short, single-line name for the problem, shown in place of the exception's class name
- `explanation`: why the error happened, shown after the exception's message
- `fix`: how to fix it, as text or as a hash of `{name:, text:, destructive:}`
- `run_fix`: performs the fix when you click its button on the page. If it returns a string, the page shows it as the fix's output
- `dataset`: a table of evidence from your app, as a hash of `{title:, columns:, rows:}`

Explanations and fixes can use a small subset of Markdown: paragraphs, `- ` lists, inline code in backticks and fenced code blocks.

```ruby
# app/diagnostics/missing_table.rb

module Bookshelf
  module Diagnostics
    class MissingTable
      def initialize(exception, context)
        @exception = exception
      end

      def applies?
        @exception.message.include?("no such table")
      end

      def title = "Database table missing"

      def explanation
        "This table doesn't exist in your database. You may have a migration that hasn't run yet."
      end

      def fix
        {name: "Run migrations", text: "Run `hanami db migrate` to apply your pending migrations."}
      end

      def run_fix
        `bundle exec hanami db migrate 2>&1`
      end
    end
  end
end
```

The context's `#slice` method returns your app (or slice), which you can use to look into your app's state.

Register your diagnostics in `config/diagnostics.rb`, with the exception's class name and your diagnostic class (or its name, if it isn't loaded yet).

```ruby
# config/diagnostics.rb

Hanami::Diagnostics.register "Sequel::DatabaseError", Bookshelf::Diagnostics::MissingTable
```

The above diagnostic is checked for any `Sequel::DatabaseError`, including its subclasses and errors with a `Sequel::DatabaseError` in their `#cause` chain. Its `applies?` method narrows this down further.

Keep your `Hanami::Diagnostics.register` calls in this file only. Hanami Webconsole loads it in development, and `Hanami::Diagnostics` doesn't exist in other environments.

Each slice can have its own `config/diagnostics.rb` too.

Gems can provide diagnostics as well. Name a diagnostics file in your gemspec's metadata:

```ruby
# my_gem.gemspec
spec.metadata["hanami_diagnostics"] = "lib/my_gem/diagnostics.rb"
```

```ruby
# lib/my_gem/diagnostics.rb
Hanami::Diagnostics.register "MyGem::ConfigError", "MyGem::Diagnostics::ConfigError"
```
