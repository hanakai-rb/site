---
title: Code reloading
---

Hanami offers fast code reloading in development via the [hanami-reloader](https://github.com/hanami/hanami-reloader) gem.

When you run `hanami server` in development, `guard` watches the file system for code edits and restarts the Hanami server when changes occur.

Which directories are watched can be configured in the `Guardfile` of your project.

```ruby
# Guardfile

group :server do
  guard "puma", port: ENV.fetch("HANAMI_PORT", 2300), environment: ENV.fetch("HANAMI_ENV", "development") do
    watch(%r{^(app|config|lib|slices)([\/][^\/]+)*.(rb|erb|haml|slim)$}i)
  end
end
```

Hanami takes an "outside the framework" approach to code reloading. This has several advantages:

- file system watching is delegated to `guard`.
- Hanami internals are free from code reloading awareness.
- if the hanami-reloader gem is not present (which is true in production), code reloading logic is eliminated.

Thanks to [Zeitwerk](//page/autoloading) and [lazy loading](//page/container-and-components#container-component-loading), code reloading is also very fast.

### Reloading in the console

If you have an existing console session and make a code change, you can use your updated code via the `reload` helper:

```ruby
bundle exec hanami console

bookshelf[development]> reload
Reloading...
```
