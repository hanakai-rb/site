---
title: Callbacks
layout: gem-single
name: dry-cli
---

Callbacks let you run code before or after a command. They're how other gems can add functionality to a command they don't own.

## Registering callbacks

Here, the `mycli` gem has a `hello` command:

```ruby
#!/usr/bin/env ruby
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    class Hello < Dry::CLI::Command
      argument :name, required: true

      def call(name:)
        puts "hello #{name}"
      end
    end
  end
end

MyCLI::Commands.register "hello", MyCLI::Commands::Hello

Dry::CLI.new(MyCLI::Commands).call
```

The `mycli-extras` gem adds callbacks to the `hello` command with `before` and `after`:

```ruby
MyCLI::Commands.before("hello") { |args| puts "debug: #{args.inspect}" }
MyCLI::Commands.after("hello") { |name:| puts "bye, #{name}" }
```

```shell
$ mycli hello Anton
debug: {name: "Anton"}
hello Anton
bye, Anton
```

A callback receives the command's arguments and options in the same way as the command's `#call`. Like `#call`, it gets only the keyword arguments it declares. A callback with a positional parameter, like `args` above, receives all of them as a hash.

A block callback runs with the command as `self`, so `puts`, `stdout` and `stderr` write to the same streams as the command.

A callback can also be an object that responds to `#call`, or a class. Dry CLI builds an instance of the class once, when you register it:

```ruby
module MyCLIExtras
  class Goodbye
    def call(name:)
      puts "bye, #{name}"
    end
  end
end

MyCLI::Commands.after "hello", MyCLIExtras::Goodbye
```

A callback can stop the CLI with an exit code, just like a command. See [Errors and exit codes](//page/errors-and-exit-codes).

## Adding options to a command

A callback may need an option that the command doesn't declare. Use `option` on the registry to add it:

```ruby
module MyCLITests
  class GenerateTest
    def call(name:, skip_tests:)
      puts "generated test for #{name}" unless skip_tests
    end
  end
end

MyCLI::Commands.option "generate action", :skip_tests, type: :flag, default: false, desc: "Skip test generation"
MyCLI::Commands.after "generate action", MyCLITests::GenerateTest
```

The option works and appears in help like any other:

```shell
$ mycli generate action home
generated action home
generated test for home

$ mycli generate action home --skip-tests
generated action home

$ mycli generate action --help
...
Options:
  --skip-tests  # Skip test generation, default: false
  --help, -h    # Print this help
```

The command itself doesn't need to change. Since its `#call` gets only the keyword arguments it declares, it doesn't receive `skip_tests:`.

`option` takes the same settings as `option` in a command. More than one gem can add the same option, as long as they agree on `:type`, `:required`, `:values` and `:default`. When they don't, Dry CLI raises an error:

```ruby
MyCLI::Commands.option "generate action", :skip_tests, type: :boolean
# => Dry::CLI::CommandDefinitionError: `skip_tests' is already declared for command `generate action' with a different type
```

There's no way to add arguments in this way. Arguments are matched by position, so the meaning of an added argument would depend on the order the gems were loaded.

`option` adds the option to the command class itself, not just its registration. If the same class is registered under other names, the option appears there too.

A subclass copies its parent's options when the subclass is defined. So if another command subclasses this command class, it gets the new option only if it's defined after you call `option`.
