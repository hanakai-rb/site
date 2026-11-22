---
title: Container and components
---

In Hanami, the application code you add to your `app` directory is automatically organised into a **container**, which forms the basis of a **component management system**.

The **components** within that system are the objects you create to get things done within your application. For example, a HTTP action for responding to requests, a validation contract for verifying data, an operation for writing to the database, or a client that calls an external API.

Ideally, each component in your application has a single responsibility. Very often, one component will need to use other components to achieve its work. When this happens, we call the latter components **dependencies**.

Hanami is designed to make it easy to create applications that are systems of well-formed components with clear dependencies.

Let's take a look at how this works in practice!

Imagine we want our Bookshelf application to add new books to its catalog. Our task is to create an operation that saves a book to the database, generating a URL slug from its title along the way so we can build tidy links like `/books/the-pragmatic-programmer`.

To achieve this, we first add two new components to our application: an _add book operation_, and a _slugifier_ for turning a title into a slug.

On the file system, this looks like:

```shell
app
├── books
│   └── create.rb
└── slugifier.rb
```

Sketching out an add book operation component:

```ruby
# app/books/create.rb

module Bookshelf
  module Books
    class Create
      def call(title:, author:)
        # Add the book to the catalog here...
      end
    end
  end
end
```

And a slugifier component:

```ruby
# app/slugifier.rb

module Bookshelf
  class Slugifier
    def call(title)
      title.downcase.gsub(/\s+/, "-")
    end
  end
end
```

When our application boots, Hanami will automatically register these classes as components in its **app container**, each under a **key** based on their Ruby class name.

This means that an instance of the `Bookshelf::Books::Create` class is available in the container under the key `"books.create"`, while an instance of `Bookshelf::Slugifier` is available under the key `"slugifier"`.

We can see this in the Hanami console if we boot our application and ask what keys are registered with the app container:

```ruby
bundle exec hanami console

bookshelf[development]> Hanami.app.boot
=> Bookshelf::App

bookshelf[development]> Hanami.app.keys
=> [
  # ...standard components omitted...
  "books.create",
  "repos.book_repo",
  "slugifier"
]
```

Alongside our two new components, you'll also notice a `"repos.book_repo"` component: a book repository for persistence, like the one from the [database guide](//guide/database). We'll put it to use shortly.

To fetch our add book operation from the container, we can ask for it by its `"books.create"` key:

```ruby
bookshelf[development]> Hanami.app["books.create"]
=> #<Bookshelf::Books::Create:0x00000001055dadd0>
```

Similarly we can fetch and call the slugifier via the `"slugifier"` key:

```ruby
bookshelf[development]> Hanami.app["slugifier"]
=> #<Bookshelf::Slugifier:0x000000010577afc8>

bookshelf[development]> Hanami.app["slugifier"].call("The Pragmatic Programmer")
=> "the-pragmatic-programmer"
```

Most of the time however, you won't work with components directly through the container via `Hanami.app`. Instead, you'll work with components through the convenient **dependency injection** system that having your components in a container supports. Let's see how that works!

## Dependency injection

Dependency injection is a software pattern where, rather than a component knowing how to instantiate its dependencies, those dependencies are instead provided to it. This means the dependencies can be abstract rather than hard coded, making the component more flexible, reusable and easier to test.

To illustrate, here's an example of an add book operation which **doesn't** use dependency injection:

```ruby
# app/books/create.rb

module Bookshelf
  module Books
    class Create
      def call(title:, author:)
        book_repo = Repos::BookRepo.new

        slugifier = Slugifier.new

        book_repo.create(
          title: title,
          author: author,
          slug: slugifier.call(title)
        )
      end
    end
  end
end
```

This component has two dependencies, each of which is a "hard coded" reference to a concrete Ruby class:

- `Repos::BookRepo`, used to persist the book to the database.
- `Slugifier`, used to generate the book's URL slug.

To make this add book operation more reusable and easier to test, we could instead _inject_ its dependencies when we initialize it:

```ruby
# app/books/create.rb

module Bookshelf
  module Books
    class Create
      attr_reader :book_repo
      attr_reader :slugifier

      def initialize(book_repo:, slugifier:)
        @book_repo = book_repo
        @slugifier = slugifier
      end

      def call(title:, author:)
        book_repo.create(
          title: title,
          author: author,
          slug: slugifier.call(title)
        )
      end
    end
  end
end
```

As a result of injection, this component no longer has rigid dependencies - it's able to use any book repository and slugifier it's provided.

Hanami makes this style of dependency injection simple through its `Deps` mixin. Built into the component management system, and invoked through the use of `include Deps["key"]`, the `Deps` mixin allows a component to use any other component in its container as a dependency, while removing the need for any attr_reader or initializer boilerplate:

```ruby
# app/books/create.rb

module Bookshelf
  module Books
    class Create
      include Deps[
        "repos.book_repo",
        "slugifier"
      ]

      def call(title:, author:)
        book_repo.create(
          title: title,
          author: author,
          slug: slugifier.call(title)
        )
      end
    end
  end
end
```

## Injecting dependencies via `Deps`

In the above example, the `Deps` mixin takes each given key and makes the relevant component from the app container available within the current component via an instance method.

i.e. this code:

```ruby
include Deps[
  "repos.book_repo",
  "slugifier"
]
```

makes the `"repos.book_repo"` component from the container available via a `#book_repo` method, and the `"slugifier"` component available via `#slugifier`.

By default, dependencies are made available under a method named after the last segment of their key. So `include Deps["repos.book_repo"]` allows us to call `#book_repo` anywhere in our `Create` class to access the book repository.

We can see `Deps` in action in the console if we instantiate an instance of our add book operation:

```ruby
bookshelf[development]> Bookshelf::Books::Create.new
=> #<Bookshelf::Books::Create:0x0000000112a93090
 @book_repo=#<Bookshelf::Repos::BookRepo:0x0000000112aa82d8>,
 @slugifier=#<Bookshelf::Slugifier:0x0000000112a931d0>>
```

We can choose to provide different dependencies during initialization:

```ruby
bookshelf[development]> Bookshelf::Books::Create.new(slugifier: ->(title) { title.downcase })
=> #<Bookshelf::Books::Create:0x0000000112aba8c0
 @book_repo=#<Bookshelf::Repos::BookRepo:0x0000000112aba9b0>,
 @slugifier=#<Proc:0x0000000112abac90 (lambda)>>
```

This behaviour is particularly useful when testing, as you can substitute one or more components to test behaviour.

In this unit test, we substitute each of the operation's dependencies in order to unit test its behaviour:

```ruby
# spec/unit/books/create_spec.rb

RSpec.describe Bookshelf::Books::Create, "#call" do
  subject(:create) {
    described_class.new(book_repo: book_repo, slugifier: slugifier)
  }

  let(:book_repo) { double(:book_repo) }
  let(:slugifier) { double(:slugifier) }

  before do
    allow(slugifier).to receive(:call).and_return("the-pragmatic-programmer")
  end

  it "saves the book with a slug" do
    expect(book_repo).to receive(:create).with(
      title: "The Pragmatic Programmer",
      author: "Hunt and Thomas",
      slug: "the-pragmatic-programmer"
    )

    create.call(title: "The Pragmatic Programmer", author: "Hunt and Thomas")
  end
end
```

Exactly which dependency to stub using RSpec mocks is up to you - if a dependency is left out of the constructor within the spec, then the real dependency is resolved from the container. This means that every test can decide exactly which dependencies to replace.

## Renaming dependencies

Sometimes you want to use a dependency under another name, either because two dependencies end with the same suffix, or just because it makes things clearer in a different context.

For example, inside our `Books::Create` operation the `book_` prefix on `#book_repo` is redundant - we already know we're working with books. We can shorten it to `#repo` by using the `Deps` mixin like so:

```ruby title="app/books/create.rb"
module Bookshelf
  module Books
    class Create
      include Deps[
        "slugifier",
        repo: "repos.book_repo"
      ]

      def call(title:, author:)
        repo.create(
          title: title,
          author: author,
          slug: slugifier.call(title)
        )
      end
    end
  end
end
```

Above, the book repository is now available via the `#repo` method, rather than via `#book_repo`. When testing, it can now be substituted by providing `repo` to the constructor:

```ruby
subject(:create) {
  described_class.new(repo: mock_repo, slugifier: mock_slugifier)
}
```

## Memoization

By default, every component auto-registered in your container is memoized: it is instantiated only once, and the same instance is returned on every subsequent resolution, whether you resolve it from the container directly or inject it via `Deps`.

We can see this in the console:

```ruby
c1 = Hanami.app["books.create"]
c2 = Hanami.app["books.create"]
c1.equal?(c2) # => true
```

Memoization is what makes Hanami containers efficient. Since components are typically stateless objects that are safe to share, instantiating each just once avoids redundant work as your app goes about its job, rather than rebuilding components every time they're resolved as dependencies.

> [!NOTE]
> A **stateless** object holds no data that changes from one use to the next. Our `Slugifier` is a good example: it remembers nothing between calls, taking a title as its argument and returning a fresh slug each time. An object like this behaves identically however many times, and from wherever, it's used, which is what makes a single shared instance safe.

> [!NOTE]
> In the test environment, components are **not** memoized. This allows you to stub a component in one test without that stubbed instance leaking into others.

### Opting out of memoization

Occasionally a component is not safe or sensible to memoize, and instead needs a fresh instance every time it's resolved.

To opt a single component out of memoization, add a `# memoize: false` magic comment at the top of its source file:

```ruby
# memoize: false

module Bookshelf
  module Workers
    class Mailer
      # ...
    end
  end
end
```

This component will now be instantiated anew on every resolution, while all your other components remain memoized.

To opt out groups of components, use the `no_memoize` setting in your app config. It accepts an array of key prefixes:

```ruby
# config/app.rb

require "hanami"

module Bookshelf
  class App < Hanami::App
    config.no_memoize = ["workers", "jobs"]
  end
end
```

With this configuration, any component whose key begins with `"workers"` or `"jobs"` (such as `"workers.mailer"` or `"jobs.import"`) will not be memoized. Every other component continues to be memoized.

For full control, you can instead provide a proc. It receives the component and should return `true` for any component that should _not_ be memoized:

```ruby
config.no_memoize = ->(component) {
  component.key.start_with?("workers")
}
```

Like other configuration, `no_memoize` can be set per slice. A slice inherits the app's setting unless it defines its own:

```ruby
# config/slices/admin.rb

module Admin
  class Slice < Hanami::Slice
    config.no_memoize = ["jobs"]
  end
end
```

A `# memoize: false` (or `# memoize: true`) magic comment on an individual component always takes precedence over the `no_memoize` setting.

## Opting out of the container

Sometimes it doesn’t make sense for something to be put in the container. For example, Hanami provides a base action class at `app/action.rb` from which all actions inherit. This type of class will never be used as a dependency by anything, and so registering it in the container doesn’t make sense.

For once-off exclusions like this Hanami supports a magic comment, much like the `# memoize: false` comment we saw above: `# auto_register: false`

```ruby
# auto_register: false
require "hanami/action"

module Bookshelf
  class Action < Hanami::Action
  end
end
```

If you have a whole class of objects that shouldn't be placed in your container, you can configure your Hanami application to exclude an entire directory from auto registration by adjusting its `no_auto_register_paths` configuration.

Here for example, the `app/structs` directory is excluded, meaning nothing in the `app/structs` directory will be registered with the container:

```ruby
# config/app.rb

require "hanami"

module Bookshelf
  class App < Hanami::App
    config.no_auto_register_paths << "structs"
  end
end
```

A third alternative for classes you do not want to be registered in your container is to place them in the `lib` directory at the root of your project.

For example, this `SlackNotifier` class can be used anywhere in your application, and is not registered in the container:

```ruby
# lib/bookshelf/slack_notifier.rb

module Bookshelf
  class SlackNotifier
    def self.notify(message)
      # ...
    end
  end
end
```

```ruby
# app/books/create.rb

module Bookshelf
  module Books
    class Create
      include Deps[
        "repos.book_repo",
        "slugifier"
      ]

      def call(title:, author:)
        book_repo.create(
          title: title,
          author: author,
          slug: slugifier.call(title)
        )

        SlackNotifier.notify("Added #{title} to the catalog")
      end
    end
  end
end
```

### Autoloading and the lib directory

[Zeitwerk](https://github.com/fxn/zeitwerk) autoloading is in place for code you put in `lib/<app_name>`, meaning that you do not need to use a `require` statement before using it.

Code that you place in other directories under `lib` needs to be explicitly required before use.

| Constant location               | Usage                                                 |
| ------------------------------- | ----------------------------------------------------- |
| lib/bookshelf/slack_notifier.rb | Bookshelf::SlackNotifier                              |
| lib/my_redis/client.rb          | require "my_redis/client"<br /><br /> MyRedis::Client |

## Container component loading

Hanami applications support a **prepared** state and a **booted** state.

Whether your app is prepared or booted determines whether components in your app container are _lazily_ loaded on demand, or _eagerly_ loaded up front.

### Hanami.prepare

When you call `Hanami.prepare` (or use `require "hanami/prepare"`) Hanami will make its app available, but components within the app container will be **lazily loaded**.

This is useful for minimizing load time. It's the default mode in the Hanami console and when running tests.

### Hanami.boot

When you call `Hanami.boot` (or use `require "hanami/boot"`) Hanami will go one step further and **eagerly load** all components up front.

This is useful in contexts where you want to incur initialization costs at boot time, such as when preparing your application to serve web requests. It's the default when running via Hanami's puma setup (see `config.ru`).

## Standard components

Hanami provides several standard app components for you to use.

### `"settings"`

These are your settings defined in `config/settings.rb`. See the [settings guide](//page/settings) for more detail.

### `"logger"`

The app's standard logger. See the [logger guide](//guide/logger/usage) for more detail.

### `"inflector"`

The app's inflector. See the [inflector guide](//page/inflector) for more detail.

### `"routes"`

An object providing URL helpers for your named routes. See the [routing guide](//guide/routing#named-routes) for more detail.
