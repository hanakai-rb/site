---
title: Dependencies
layout: gem-single
name: dry-cli
---

A command often needs other objects to do its work. Give them to the command through its `#initialize`, like any other Ruby class:

```ruby
class Generate < Dry::CLI::Command
  argument :name, required: true

  def initialize(generator: Generator.new)
    @generator = generator
  end

  def call(name:)
    puts "created #{@generator.generate(name)}"
  end
end
```

You don't need to call `super` from your `#initialize`. `Dry::CLI::Command.new` sets up the command's standard streams before your `#initialize` runs, so you can still use `stdout`, `stderr` and `stdin` inside it.

To pass a dependency in yourself, register the command as an instance instead of a class:

```ruby
register "generate", Generate.new(generator: MyGenerator.new)
```

In a test, you can build the command with whatever you need. See [Testing](//page/testing).

## Using streams in a command registered as an instance

A command registered as an instance is built before the CLI runs, so before Dry CLI knows which streams to use. When the CLI runs, Dry CLI gives the command its streams, replacing any it had.

So avoid building objects from the streams inside `#initialize`. Build them when you first use them instead:

```ruby
def logger
  @logger ||= Logger.new(stderr)
end
```

## Standard dependencies

Some dependencies are needed by every command in your CLI, like a logger. You can give each command class its own `#initialize` for these, but that repeats the same code, and it's easy to forget.

Instead, make a base class for your commands, and give it an `#auto_initialize` method:

```ruby
module MyApp
  class Command < Dry::CLI::Command
    private def auto_initialize(logger: nil, **kwargs)
      super(**kwargs)
      @logger = logger
    end

    def logger
      @logger ||= Logger.new(stderr)
    end
  end
end
```

Each keyword that `#auto_initialize` declares can now be given to `.new` for any command:

```ruby
MyApp::Commands::Generate.new(logger: my_logger)
```

Dry CLI gives these keywords to `#auto_initialize` before calling `#initialize`, which receives only the keywords that are left over. So each command's `#initialize` stays focused on its own dependencies, without needing to take `**kwargs` and call `super(**kwargs)`:

```ruby
class Generate < MyApp::Command
  argument :name, required: true

  def initialize(generator: Generator.new)
    @generator = generator
  end

  def call(name:)
    logger.info "generating #{name}"
    puts "created #{@generator.generate(name)}"
  end
end
```

When you write an `#auto_initialize`:

- Take `**kwargs` and call `super(**kwargs)` first. This is how Dry CLI sets up the command's streams, which are auto-initialized keywords too.
- Give each keyword a reader method of the same name, like `logger` above. [Invoking commands](//page/invoking-commands) uses these readers to share dependencies between commands.
- Use it sparingly, ideally only in your base command classes. Dry CLI takes each of its keywords before `#initialize` runs, so no command below it can use that keyword for a dependency of its own.

## Auto-injected dependencies

Commands work with [Dry AutoInject](//org_guide/dry/dry-auto_inject), and with Hanami's `Deps` mixin, which is built on it. Include it in a command, and the command's dependencies come from your container:

```ruby
Deps = Dry::AutoInject(MyApp::Container)

class Generate < MyApp::Command
  include Deps["generator"]

  argument :name, required: true

  def call(name:)
    logger.info "generating #{name}"
    puts "created #{generator.generate(name)}"
  end
end
```

Dry AutoInject still builds the command through `Dry::CLI::Command.new`. So the standard streams, and any keywords from your `#auto_initialize`, like `logger:` above, work together with the injected dependencies. You can give any of them to `.new`, for example in a test:

```ruby
Generate.new(generator: FakeGenerator.new, logger: my_logger)
```
