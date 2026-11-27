---
title: Upgrade to 3.1
pages:
  - v3.0
  - v2.3
  - v2.2
  - v2.1
---

These notes cover an upgrade from 3.0 to 3.1.

<!-- TODO: Link "Hanami 3.1 release announcement" below once it's published. -->

Hanami 3.1 brings in-place code reloading, a new development error page, lazy view exposures, response streaming, and much more. For a complete overview of everything new in this release, see the Hanami 3.1 release announcement. The notes below focus on the specific steps to upgrade an existing app.

## Required changes

These changes are necessary for a baseline upgrade to 3.1.

### Upgrade your Hanami gems

Edit your `Gemfile` and update the versions of all your Hanami gems to `"~> 3.1"`, including those in your `development`, `test` and `cli` groups (such as hanami-webconsole, hanami-reloader and hanami-rspec):

```ruby
gem "hanami", "~> 3.1"
gem "hanami-action", "~> 3.1"
gem "hanami-assets", "~> 3.1"
gem "hanami-db", "~> 3.1"
gem "hanami-router", "~> 3.1"
gem "hanami-view", "~> 3.1"
```

Hanami now checks that its gems share the same major and minor version. If any are out of step, requiring `hanami` raises a `Hanami::GemVersionError` that lists the mismatched gems. If you need to skip this check, set the `HANAMI_SKIP_GEM_VERSION_CHECK` env var.

### Upgrade your assets package

> [!NOTE]
> This is only relevant if your app uses hanami-assets.

Edit your `package.json` and update the version of `"hanami-assets"` to `"^3.1.0"`:

```json
{
  "dependencies": {
    "hanami-assets": "^3.1.0"
  }
}
```

Then run `npm install`.

### Remove your Guardfile

Code reloading no longer uses Guard. `hanami server` now keeps a single process running and reloads your app's code in place on the next request after a file changes. See [Code reloading](//guide/app/code-reloading) for details.

Delete the `Guardfile` from your app. hanami-reloader no longer depends on guard or guard-puma, so if you added these to your `Gemfile` yourself, you can remove them too.

### Review your response bodies

`response.body=` now raises a `Hanami::Action::InvalidBodyError` when given an object that responds to `#each`, such as an Array or an Enumerator. Previously, it sent the `#inspect` output of that object to the client.

To send a response in chunks, use the new `response.stream` instead:

```ruby
# Before:
# response.body = ["Hello, ", "world"]

# After:
response.stream(["Hello, ", "world"])
```

`response.write` also raises an `InvalidBodyError` when the body is a stream. See [Streaming responses](//guide/actions/request-and-response#streaming-responses) for more.

### Review your view exposures

View exposures are now lazy. An exposure runs only when a template (or another exposure) first reads it, and exposures that no template reads never run at all.

For most views, this is a transparent performance improvement. But if an exposure has side effects, or must raise an error before rendering starts (such as a "not found" error), define it with `expose!` to make it eager:

```ruby
expose!(:book) do |id:|
  book_repo.get!(id)
end
```

See [When exposures run](//guide/views/input-and-exposures#when-exposures-run) and [Eager exposures](//guide/views/input-and-exposures#eager-exposures) for details.

### Review your use of view locals

Inside a view's template and layout, `locals` (and `_locals`) now return a `Hanami::View::Locals` object rather than a Hash. This lets Hanami resolve each local only when you read it. `Locals` supports `#[]`, `#fetch`, `#key?` and `#to_h`.

- Splatting locals into a partial, such as `render("item", **locals)`, now raises a `TypeError`. Pass only the locals the partial needs (`render("item", item: book)`), or convert them first with `**locals.to_h`.
- `Rendered#locals` also returns a `Locals`. In your view tests, add `.to_h` wherever you treat it as a Hash, such as with RSpec's `include` matcher:

  ```ruby
  expect(rendered.locals.to_h).to include(title: "Hello")
  ```

- `Rendered#==` now compares the rendered output only, not the locals.

See [Passing locals to partials](//guide/views/templates-and-partials#passing-locals-to-partials) and [Testing exposures](//guide/views/testing#testing-exposures) for details.

### Review your locals magic comments

Hanami View now supports declaring a template's locals with a magic comment, such as `<%# locals: (title:) %>`. If your templates already have comments in this form (for example, kept from a Rails app), they are now enforced.

To ignore these comments, set `config.renderer_options = {extract_fixed_locals: false}` in your view class.

See [Declaring locals](//guide/views/templates-and-partials#declaring-locals) for details.

### Review your resource routes

Resource routes now give more consistent names and params. Review your routes with `bundle exec hanami routes` if you use any of the following:

- **The `as:` option on `resources`** now goes through the inflector. Member routes and routes nested under the resource use its singular form, and the index and create routes use its plural form. For example, `resources :books, as: :publications` gives `publication`, `edit_publication` and `publication_reviews`, while the index route keeps its `publications` name.
- **The `path:` option on `resources`** no longer changes the names of nested params. `resources :posts, path: "articles" do resources :comments end` now gives `/articles/:post_id/comments`. If your actions read the old param name (`article_id`), change them to read the new one (`post_id`). Change your route helper calls to match, such as `routes.path(:post_comments, post_id: post.id)`.
- **Uncountable resource names**, like `news`, now give their index and create routes an `_index` suffix (`news_index`), so they no longer clash with the show route.
- **Routes nested under a singular `resource`** use the resource's name as given. `resource :settings do resources :items end` now gives `settings_items` rather than `setting_items`.

See [Resource routes](//guide/routing#resource-routes) for details.

### Review your SQLite databases

For apps using SQLite, Hanami now applies a set of default pragmas to every database connection, including `journal_mode = wal`. Your existing SQLite databases will switch to WAL mode on upgrade. SQLite stores this mode in the database file, and creates `-wal` and `-shm` files beside the database while it is in use.

A read-only connection cannot switch a database to WAL mode. Hanami leaves out the `journal_mode` pragma for gateways with `connection_options readonly: true`, but it does not detect `?readonly=true` in a database URL. If you make a gateway read-only through its URL, move the option to `connection_options`, or skip the default pragmas for that gateway:

```ruby
# config/providers/db.rb

Hanami.app.configure_provider :db do
  config.gateway :archive do |gw|
    gw.adapter :sql do |adapter|
      adapter.skip_defaults :connect_sqls
    end
  end
end
```

Also update your `.gitignore` to ignore the new files, by changing `db/*.sqlite` to `db/*.sqlite*`.

See [SQLite](//guide/database/configuration#sqlite) in the database configuration guide for the full list of pragmas and how to change them.

### Review your translation files

Each slice's `i18n` component now loads only the translation files configured for that slice. It no longer loads the files in the global `I18n.load_path`.

If you added translation files to `I18n.load_path` and used them via the `i18n` component, add them to your i18n config instead. Otherwise, their translations will be missing. This does not raise an error, so check your pages for missing text. Use `config.i18n.load_path` for a single slice, or `config.i18n.shared_load_path` for every slice:

```ruby
# config/app.rb

config.i18n.shared_load_path += ["config/locales/**/*.yml"]
```

Calling `I18n.t` directly still uses the global `I18n.load_path`, as before.

See [i18n configuration](//guide/i18n/configuration) for details.

### Review your validation error messages

Error messages from your Dry Validation contracts are now translated with your slice's i18n, using its current locale. This includes contracts in your slices as well as `params do` and `contract do` blocks in your actions. Messages fall back to Dry Validation's built-in English messages, so apps that use only English will see no change.

To keep the previous behaviour for a contract, set `config.messages.backend = :yaml` in that contract.

This requires dry-schema 1.17 or later. See [Translating validation messages](//guide/i18n#translating-validation-messages) for how to add your own translations.

### Review your handling of bad requests

Actions now respond with 400 Bad Request when a request's body or params cannot be parsed. This covers invalid JSON bodies, conflicting param types (such as `?a=1&a[b]=2`), invalid percent-encoding, and params that exceed Rack's limits. Previously, these raised errors that typically became 500 responses.

- If your tests expect these errors to be raised, change them to expect a 400 response instead.
- If you already handle `Hanami::Action::BodyParsingError` with `config.handle_exception`, your handler still runs. If it only returns a 400, you can remove it.
- To respond your own way to query strings and form bodies that can't be parsed, handle the new `Hanami::Action::ParamsParsingError` too.

Params contracts now receive params with symbol keys rather than string keys.

See [Malformed requests](//guide/actions/parameters#malformed-requests) for details.

### Update your Minitest support files

> [!NOTE]
> This is only relevant if your app uses hanami-minitest.

The test support files generated by Hanami 3.0 did not apply database cleaning to feature tests. To fix this, make your support files define their own `FeatureTest` and `RequestTest` classes:

```ruby
# test/support/features.rb

class FeatureTest < Hanami::Minitest::FeatureTest
  # Add custom feature test helpers here.
end
```

```ruby
# test/support/requests.rb

class RequestTest < Hanami::Minitest::RequestTest
  # Add custom request test helpers here.
end
```

Then change your feature and request tests to inherit from these classes, such as `class RootTest < RequestTest`.

### Review your error page configuration

> [!NOTE]
> This is only relevant if your app configures better_errors directly.

Hanami's development error page no longer uses better_errors. hanami-webconsole now has its own error page, and no longer depends on the better_errors gem. Remove any code that refers to `BetterErrors`, and use these replacements instead:

- In place of `BetterErrors.editor`, set the `HANAMI_EDITOR` env var. See [Opening files in your editor](//guide/app/error-pages#opening-files-in-your-editor).
- In place of `BetterErrors::Middleware.allow_ip!`, call `Hanami::Webconsole::Middleware.allow_ip!`:

  ```ruby
  # config/app.rb

  if Hanami.bundled?("hanami-webconsole")
    require "hanami/webconsole"
    Hanami::Webconsole::Middleware.allow_ip!("192.168.0.0/16")
  end
  ```

See [Error pages](//guide/app/error-pages) for details.

### Update your custom CLI commands

Hanami CLI now uses Dry CLI 2.0. If your app or gem defines its own commands, follow the [Dry CLI 2.0 upgrade notes](//org_guide/dry/dry-cli/upgrade-notes) first. These cover the main changes, such as using `stdout` and `stderr` in place of `out` and `err`.

Then make these Hanami-specific changes:

- A command's `fs:` is now assigned before `#initialize` runs, along with its I/O streams. Your `#initialize` needs to take only its own arguments, and no longer needs to call `super`:

  ```ruby
  # Before:
  # def initialize(fs:, out:, err:, generator: MyGenerator.new(fs: fs), **opts)
  #   super(fs: fs, out: out, err: err, **opts)
  #   @generator = generator
  # end

  # After:
  def initialize(generator: MyGenerator.new(fs:))
    @generator = generator
  end
  ```

- `Hanami::CLI::SystemCall::Result#out` and `#err` are now `#stdout` and `#stderr`.
- `Hanami::CLI::InteractiveSystemCall` is removed. Pass `stdout:` and `stderr:` to `Hanami::CLI::SystemCall#call` to write a command's output as it arrives.

## Recommended changes

These changes are optional, but recommended.

### Review your log filters

Hanami's default log filters are now broader: `["passw", "secret", "token", "_key", "crypt"]`. Each filters any param whose name contains that text, ignoring case, such as `password_confirmation`, `client_secret` and `api_key`. These defaults first shipped in Hanami 3.0.3, so you may already have them.

If you set `config.logger.filters` in your app, consider appending to the defaults rather than replacing them:

```ruby
config.logger.filters += ["ssn"]
```

See [Log filters](//guide/logger/configuration#log-filters) for details.

## Optional new features

Hanami 3.1 adds several new features. Adopt any of these if you want the capability. Otherwise, you can safely skip them.

- **Settings from YAML files.** Hanami now reads settings from `config/settings/default.yml` and a file for each env, such as `config/settings/production.yml`. Values in `ENV` still take precedence. See [YAML settings files](//guide/app/settings#yaml-settings-files).
- **Collection and member routes.** Use `collection` and `member` blocks inside `resources` to add your own routes to a resource. See [Resource routes](//guide/routing#resource-routes).
- **Response streaming.** Use `response.stream` to send a response in chunks. `send_file` now streams files too, rather than reading them into memory. See [Streaming responses](//guide/actions/request-and-response#streaming-responses).
- **Eager exposures and declared locals.** Use `expose!` for exposures that must run before rendering, and declare your templates' locals to catch mistakes early. See [Eager exposures](//guide/views/input-and-exposures#eager-exposures) and [Declaring locals](//guide/views/templates-and-partials#declaring-locals).
- **Database URLs from separate env vars.** Instead of a single `DATABASE_URL`, you can now give its parts as `DATABASE_HOST`, `DATABASE_NAME` and other env vars. See [Building the URL from separate env vars](//guide/database/configuration#building-the-url-from-separate-env-vars).
- **A custom app file location.** Set `HANAMI_APP_PATH` to load your app class from a file other than `config/app.rb`. See [Using a different app file](//guide/app#using-a-different-app-file).

## Getting help

Thank you for upgrading to Hanami 3.1! We hope the process is a smooth one for you.

If you run into any trouble or have questions along the way, please [reach out to our community](/community). We'd love to help, and your feedback helps us make these upgrades better for everyone.
