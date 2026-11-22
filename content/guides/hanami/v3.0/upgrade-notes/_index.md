---
title: Upgrade to 3.0
pages:
  - v2.3
  - v2.2
  - v2.1
---

These notes cover an upgrade from 2.3 to 3.0.

Hanami 3.0 adds first-class mailer and i18n integrations, optional Minitest support, and a range of performance improvements. For a complete overview of everything new in this release, see the [Hanami 3.0 release announcement](#). The notes below focus on the specific steps to upgrade an existing app.

## Required changes

These changes are necessary for a baseline upgrade to 3.0.

### Use a supported Ruby version

Hanami 3.0 requires Ruby 3.3 or newer. Make sure your app is running a supported Ruby before you begin.

### Upgrade your Hanami gems

Hanami 3.0 renames the actions gem from hanami-controller to hanami-action, and retires hanami-validations in favour of depending on dry-validation directly. Update your `Gemfile` accordingly:

```ruby
# Update the versions of your existing Hanami gems to "~> 3.0"
gem "hanami", "~> 3.0"
gem "hanami-assets", "~> 3.0"
gem "hanami-db", "~> 3.0"
gem "hanami-router", "~> 3.0"
gem "hanami-view", "~> 3.0"

# Rename this:
#   gem "hanami-controller", "~> 2.3"
# to:
gem "hanami-action", "~> 3.0"

# Remove this:
#   gem "hanami-validations", "~> 2.3"
# and, if your actions use `params` or `contract` validations, add dry-validation directly:
gem "dry-validation"
```

Also update the versions of any Hanami gems in your `development`, `test` and `cli` groups (such as hanami-webconsole, hanami-reloader and hanami-rspec) to `"~> 3.0"`.

Your `app/action.rb` and other action classes do not need to change. `require "hanami/action"` and `Hanami::Action` continue to work as before, now provided by the renamed hanami-action gem.

### Update your assets dependencies

esbuild is now a peer dependency of hanami-assets (the npm package), so your app must depend on it directly. This lets you update esbuild on your own schedule without waiting for a new hanami-assets release.

Edit `package.json` to bump hanami-assets and add esbuild:

```json
{
  "dependencies": {
    "esbuild": "^0.28.1",
    "hanami-assets": "^3.0.0"
  }
}
```

Then run `npm install`.

### Review your view exposures

Hanami View now defaults to undecorated exposures. If your views rely on exposures being automatically wrapped in their parts, you have two options:

- Decorate individual exposures by replacing `expose` with `decorate`, or adding the `decorate: true` option for `expose`.
- Restore the previous behaviour for a view by setting `config.decorate_exposures = true`.

### Review your action params and contracts

Defining action params by subclassing `Hanami::Action::Params` was a legacy approach that we had preserved until now. As of 3.0 it is no longer supported. Move your params block into a `Dry::Validation::Contract` subclass and pass that contract to `Hanami::Action.params` or `Hanami::Action.contract`:

```ruby
# Before
# class SignupParams < Hanami::Action::Params
#   params do
#     required(:email).filled(:str?)
#   end
# end

# After
class SignupContract < Dry::Validation::Contract
  params do
    required(:email).filled(:str?)
  end
end

class Signup < Hanami::Action
  params SignupContract
end
```

### Review your action formats config

The format config methods deprecated in 2.3 (`Action.format`, `config.format`, `config.formats.add` and `config.formats.values`) have now been removed. If you have not already migrated away from these, see [Formats and media types](//guide/actions/formats-and-media-types) for the current API.

### Review your request body parsing

In Hanami 2.3, request body parsing was provided by middleware enabled at the app level. In 3.0 this functionality has moved into Hanami Action and is now driven by your formats config:

- JSON bodies are parsed when you `config.actions.formats.accept :json`.
- Multipart form bodies are parsed when you `config.actions.formats.accept :html` (or whenever no formats are configured at all).

If your app relies on parsed JSON request bodies, make sure the relevant formats are accepted in your action or app config.

### Review your memoized components

Hanami 3.0 memoizes auto-registered container components by default. Each component is now resolved only once, with the same instance returned on every subsequent resolution. Previously, a new instance was built on each resolution.

For typical components, which are stateless and can function as a long-lived instance already, this is a transparent performance improvement. But if you have a component that holds mutable per-resolution state, or that is otherwise not safe to share as a single long-lived instance, sharing it across the app could now cause subtle bugs. Review any such components and opt them out of memoization.

You can opt components out of memoization in a few ways:

- For an individual component, add a `# memoize: false` magic comment to the top of its source file:

  ```ruby
  # memoize: false
  # frozen_string_literal: true

  module Bookshelf
    class Worker
      # ...
    end
  end
  ```

- For groups of components, set `config.no_memoize` in your app (or slice) class. It accepts an array of key prefixes:

  ```ruby
  module Bookshelf
    class App < Hanami::App
      config.no_memoize = ["workers", "jobs"]
    end
  end
  ```

- Or, for full control, a proc that receives a `Dry::System::Component` and returns `true` for components that should _not_ be memoized:

  ```ruby
  config.no_memoize = ->(component) {
    component.key.start_with?("workers")
  }
  ```

Components are **not** memoized in the test env, so you can continue to use [container stubbing](//org_guide/dry/dry-system/test-mode) where you need.

### Review your redirect routes

If you define redirect routes in `config/routes.rb`, `redirect` now requires an explicit `code:` argument. For the common cases, switch to the new `redirect_permanent` (301) and `redirect_temporary` (302) helpers:

```ruby
# Before:
#   redirect "/legacy", to: "/new"
# After:
redirect_temporary "/legacy", to: "/new"
```

For less common status codes (such as `303`, `307` or `308`), continue to use `redirect` and pass `code:` explicitly.

## Recommended changes

These changes are optional, but recommended to bring your app in line with what we now generate for new 3.0 apps.

### Update your Puma config

New apps no longer include `preload_app!` in `config/puma.rb`. Recent versions of Puma enable preloading by default in cluster mode, so the call is redundant. If you wish to match, you can remove these lines from within the `if puma_cluster_mode` block:

```ruby
# Preload the application before starting the workers. Only in cluster mode.
preload_app!
```

Make sure to upgrade your puma gem to 7.0 or later to take advantage of this change.

### Syntax highlight SQL logs

If you add the rouge gem, Hanami will syntax highlight SQL in your logs. Add it to your `development` and `test` groups:

```ruby
group :development, :test do
  gem "rouge"
end
```

Hanami 3.0 also changes the default log level for SQL (and other database) statements from `:info` to `:debug`. You can adjust this with the new `config.db.log_level` setting.

### Update your operations spec support

If you have a `spec/support/operations.rb`, switch from including the Dry Monads result mixin to loading its RSpec extension. This provides `be_success` and `be_failure` matchers for operation results, along with `Success` and `Failure` constructors for use within your examples:

```ruby
# frozen_string_literal: true

require "dry/monads"

# Load Dry Monads' RSpec extension.
#
# This provides `be_success` and `be_failure` matchers for operation results, along with `Success`
# and `Failure` constructors for use within your examples.
Dry::Monads.load_extensions(:rspec)
```

### Update your database cleaning spec support

In `spec/support/db/cleaning.rb`, change the `:db` setup hook from `config.before` to `config.prepend_before`. This ensures the database cleaning hook runs before any other `before` hooks that might touch the database, preventing factory calls in spec-level `before` blocks from leaking records across tests:

```ruby
config.prepend_before :each, :db do |example|
  # ...
end
```

## Optional new features

Hanami 3.0 adds several new features and integrations. Adopt any of these if you want the capability. Otherwise, you can safely skip them.

### Add i18n support

Hanami 3.0 integrates the i18n gem when it is bundled. To adopt it:

- Add the gem to your `Gemfile`:

  ```ruby
  gem "i18n"
  ```

- Create a `config/i18n/en.yml` (and one in `config/i18n/` for each slice) with your translations:

  ```yaml
  # Add your translations here. See https://hanakai.org/learn/hanami/i18n for details.
  en:
    hello: "Hello"
  ```

Hanami registers an `"i18n"` component in each slice, configurable via `config.i18n` or a dedicated `:i18n` provider. Translations are loaded from `config/i18n/` within each slice, and shared translations from `config/i18n/shared/` at the app level. Translation and localization helpers are made available in views and actions, where relative keys (those with a leading `.`) are prefixed with the current template or action name.

### Add mailer support

Hanami 3.0 integrates the rewritten hanami-mailer gem. To adopt it:

- Add the gem to your `Gemfile`:

  ```ruby
  gem "hanami-mailer", "~> 3.0"
  ```

- Add an `app/mailer.rb` (and a `mailer.rb` in any slices):

  ```ruby
  # auto_register: false
  # frozen_string_literal: true

  require "hanami/mailer"

  module Bookshelf
    class Mailer < Hanami::Mailer
      # Add common mailer behavior here. See https://hanakai.org/learn/hanami/mailers for details.
    end
  end
  ```

- Create an `app/mailers/` directory (and `mailers/` in any slices) with a `.keep` file inside.
- Mailer templates are loaded from `templates/mailers/`.
- Add sample SMTP settings to your `.env`. Hanami registers an SMTP delivery method in the development and production envs when the `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` and `SMTP_AUTHENTICATION` env vars are present, and a test delivery method otherwise (and always in the test env):

  ```shell
  # SMTP delivery for Hanami Mailer (in development and production envs only).
  #
  # See https://hanakai.org/learn/hanami/mailers for details.
  #
  # Set these in `.env.local` or another `.env` file not checked into source control.
  #
  # SMTP_ADDRESS=smtp.example.com
  # SMTP_PORT=587
  # SMTP_USERNAME=mailer@example.com
  # SMTP_PASSWORD=s3cr3t
  # SMTP_AUTHENTICATION=plain
  ```

You can generate new mailers with `hanami generate mailer`.

### Use Minitest instead of RSpec

> [!NOTE]
> This is only relevant if you want to switch your app's test framework from RSpec to Minitest.

Hanami 3.0 introduces the new hanami-minitest gem, giving you a fully integrated Minitest setup as an alternative to RSpec.

Add the gem to your `Gemfile`, replacing hanami-rspec:

```ruby
group :cli, :development, :test do
  gem "hanami-minitest"
end
```

Then run `bundle exec hanami setup`. This generates the files below and appends the necessary test dependencies to your `Gemfile`. If you'd rather add them by hand, here is what `setup` creates.

- Add capybara and rack-test (and, if you use hanami-db, database_cleaner-sequel) to your `test` group:

  ```ruby
  group :test do
    # Database
    gem "database_cleaner-sequel"

    # Web integration
    gem "capybara"
    gem "rack-test"
  end
  ```

- Add the following to your `.gitignore`:

  ```text
  .test_results/
  ```

- Create `test/test_helper.rb`:

  ```ruby
  # frozen_string_literal: true

  require "pathname"
  TEST_ROOT = Pathname(__dir__).realpath.freeze

  ENV["HANAMI_ENV"] ||= "test"
  require "hanami/minitest"
  require "hanami/prepare"

  require_relative "support/minitest"
  TEST_ROOT.glob("support/**/*.rb").each { |f| require f }
  ```

  - Create `test/support/minitest.rb`:

  ```ruby
  # frozen_string_literal: true

  class Hanami::Minitest::Test
    # Add helper methods to be used by all tests here.
  end
  ```

- Create `test/support/features.rb`:

  ```ruby
  # frozen_string_literal: true

  class Hanami::Minitest::FeatureTest
    # Add custom feature test helpers here.
  end
  ```

- Create `test/support/requests.rb`:

  ```ruby
  # frozen_string_literal: true

  class Hanami::Minitest::RequestTest
    # Add custom request test helpers here.
  end
  ```

- Create `test/support/operations.rb`:

  ```ruby
  # frozen_string_literal: true

  require "dry/monads"

  class Hanami::Minitest::Test
    # Provide `Success` and `Failure` for testing operation results.
    include Dry::Monads[:result]
  end
  ```

- Create a starter request test at `test/requests/root_test.rb`:

  ```ruby
  # frozen_string_literal: true

  require "test_helper"

  class RootTest < Hanami::Minitest::RequestTest
    test "not found" do
      get "/"

      # Generate new action via:
      #   `bundle exec hanami generate action home.index --url=/`
      assert_equal 404, last_response.status
    end
  end
  ```

If you use hanami-db, `setup` also creates these database support files:

- Create `test/support/db.rb`:

  ```ruby
  # frozen_string_literal: true

  require_relative "features"
  require_relative "db/cleaning"

  module TestSupport
    module DB
      def self.included(mod)
        mod.include DB::Cleaning
      end

      # Add helper methods to be used by DB tests here.
    end
  end

  class FeatureTest
    include TestSupport::DB
  end
  ```

- Create `test/support/db/cleaning.rb`:

  ```ruby
  # frozen_string_literal: true

  require "database_cleaner/sequel"

  module TestSupport
    module DB
      module Cleaning
        def self.included(base)
          base.extend(ClassMethods)
        end

        module ClassMethods
          def db_cleaning_with_truncation!
            @db_cleaning_with_truncation = true
          end

          def js! = db_cleaning_with_truncation!
        end

        def setup
          # Clean all databases before the first test
          Cleaning.once do
            Cleaning.all_databases.each do |db|
              DatabaseCleaner[:sequel, db: db].clean_with :truncation, except: ["schema_migrations"]
            end
          end

          use_truncation = self.class.instance_variable_get(:@db_cleaning_with_truncation)
          strategy = use_truncation ? :truncation : :transaction

          Cleaning.all_databases.each do |db|
            DatabaseCleaner[:sequel, db: db].strategy = strategy
            DatabaseCleaner[:sequel, db: db].start
          end

          super
        end

        def teardown
          Cleaning.all_databases.each do |db|
            DatabaseCleaner[:sequel, db: db].clean
          end

          super
        end

        class << self
          def once
            @cleaned_once ||= false
            return if @cleaned_once

            yield

            @cleaned_once = true
          end

          def all_databases
            @all_databases ||= begin
              slices = [Hanami.app] + Hanami.app.slices.with_nested

              slices.each_with_object([]) { |slice, dbs|
                next unless slice.key?("db.rom")

                dbs.concat slice["db.rom"].gateways.values.map(&:connection)
              }.uniq
            end
          end
        end
      end
    end
  end
  ```

Database cleaning is wired into feature tests automatically. For other tests that need database access, include the `TestSupport::DB` module in the test class.

The test support files use compact class notation to re-open Hanami's Minitest classes (such as `class Hanami::Minitest::Test`). If these cause RuboCop issues in your app, exclude these files from the `Style/ClassAndModuleChildren` in your RuboCop config:

```yaml
Style/ClassAndModuleChildren:
  Exclude:
    - "test/support/**/*"
```

Once your Minitest setup is in place, and your RSpec-based tests ported over, you can remove hanami-rspec along with your `spec/` directory and `.rspec` file.

## Getting help

Thank you for upgrading to Hanami 3.0! We hope the process is a smooth one for you.

If you run into any trouble or have questions along the way, please [reach out to our community](/community). We'd love to help, and your feedback helps us make these upgrades better for everyone.
