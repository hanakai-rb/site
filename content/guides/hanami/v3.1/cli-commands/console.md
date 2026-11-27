---
title: Console
---

## hanami console

Starts the Hanami console (REPL).

```shell
$ bundle exec hanami console

bookshelf[development]>
```

This command accepts an `engine` argument that can start the console using IRB or Pry.

```shell
$ bundle exec hanami console --engine=irb # (the default)
$ bundle exec hanami console --engine=pry
```

## Reloading

After you change your code, call `reload` to load your changes into the console:

```ruby
bookshelf[development]> reload
Reloading... done (38ms)
```

In development, this reloads your app in place and keeps your session, including your local variables. When `config.code_reloading` is off, `reload` restarts the console instead. See the [code reloading guide](//guide/app/code-reloading) for more detail.

## Customization

You can permanently change the engine setting in your config:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.console.engine = :pry
  end
end
```

If you would like to install custom helper methods into the console:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.console.include ConsoleHelpers
  end
end
```

You can include as many custom modules as you like, and they will be automatically included into the console context when it starts up.
