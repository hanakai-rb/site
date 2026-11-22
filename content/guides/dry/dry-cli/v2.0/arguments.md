---
title: Arguments
layout: gem-single
name: dry-cli
---

An argument is a value given after the command name. For example, when a user types `mycli greet Quinn`, then `Quinn` is an argument to the `greet` command. Arguments are matched by position, in the order you declare them.

A command can take any number of arguments, and each one can be required or optional:

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    class Greet < Dry::CLI::Command
      argument :name, required: true, desc: "The name of the person to greet"
      argument :age, desc: "The age of the person to greet"

      def call(name:, age: nil)
        result = "Hello, #{name}."
        result = "#{result} You are #{age} years old." unless age.nil?

        puts result
      end
    end

    register "greet", Greet
  end
end

Dry::CLI.new(MyCLI::Commands).call
```

```shell
$ mycli greet Quinn
Hello, Quinn.

$ mycli greet Quinn 42
Hello, Quinn. You are 42 years old.
```

When a required argument is missing, the command doesn't run:

```shell
$ mycli greet
Error: missing required argument NAME

Usage: mycli greet NAME [AGE]
Run "mycli greet --help" for more information.
```

## Default values

Use `default:` to give an optional argument a value for when it's left out:

```ruby
argument :lines, default: "10", desc: "Number of lines"
```

A required argument can't have a default, since the user always has to give it. Declaring both raises an error:

```ruby
argument :env, required: true, default: "development"
# => Dry::CLI::CommandDefinitionError: argument `env' can't be both required and have a default
```

## Accepted values

Use `values:` to limit an argument to a list of values:

```ruby
class Deploy < Dry::CLI::Command
  argument :env, required: true, values: %w[staging production], desc: "Where to deploy"
  argument :speed, values: %w[fast slow], desc: "How fast to deploy"

  def call(env:, speed: "slow")
    puts "Deploying to #{env} (#{speed})"
  end
end
```

The accepted values are shown in the help:

```shell
$ mycli deploy --help
Command:
  mycli deploy

Usage:
  mycli deploy ENV [SPEED]

Arguments:
  ENV         # REQUIRED Where to deploy: (staging, production)
  SPEED       # How fast to deploy: (fast, slow)

Options:
  --help, -h  # Print this help
```

Any other value is an error. An optional argument with `values:` can still be left out:

```shell
$ mycli deploy production fast
Deploying to production (fast)

$ mycli deploy staging
Deploying to staging (slow)

$ mycli deploy dev
Error: invalid value "dev" for ENV; accepted values: staging, production

Usage: mycli deploy ENV [SPEED]
Run "mycli deploy --help" for more information.
```

The values don't have to be strings. Values like `[1, 2, 3]` are turned into strings, then compared with what the user typed. To receive them as something other than strings, use `cast:` (see [Casting values](#casting-values)).

## Array arguments

An argument with `type: :array` takes all the remaining values:

```ruby
class Exec < Dry::CLI::Command
  argument :task, required: true, desc: "Task to run"
  argument :dirs, type: :array, desc: "Directories to run it in"

  def call(task:, dirs:)
    puts "exec - task: #{task}, dirs: #{dirs.inspect}"
  end
end
```

```shell
$ mycli exec test
exec - task: test, dirs: []

$ mycli exec test lib spec
exec - task: test, dirs: ["lib", "spec"]
```

An array argument is always given to `#call` as an array, even when the user gives no values for it.

## Passing arguments through

Sometimes a command needs to pass extra arguments along to another program, like `ssh`, `docker` or `cat`.

The user can give `--` (a double dash) to mark the end of the arguments and [options](//page/options) for your command. Everything after it is collected, unparsed, and given to `#call` as the `args:` keyword argument:

```ruby
class Runner < Dry::CLI::Command
  argument :image, required: true, desc: "Docker image"

  def call(image:, args: [])
    puts "docker run -it --rm #{image} #{args.join(" ")}"
  end
end

register "run", Runner
```

```shell
$ mycli run ruby:latest -- ruby -v
docker run -it --rm ruby:latest ruby -v
```

Here, `ruby:latest` is the `image` argument, and `ruby -v` is collected in `args`, ready to give to Docker. A real command might run it with `system("docker", "run", "-it", "--rm", image, *args)`. Since `-v` comes after `--`, Dry CLI doesn't try to read it as an option for `mycli run`.

As with all keyword arguments, `#call` receives `args:` only if it declares it.

## Casting values

Values come from the command line as strings. Use `cast:` to turn them into something else. Give it anything that responds to `#call`, such as a lambda:

```ruby
class Sum < Dry::CLI::Command
  argument :numbers, type: :array, cast: ->(value) { Integer(value) }, desc: "Numbers to add"

  def call(numbers:)
    puts numbers.sum
  end
end
```

For an array argument, each value is cast on its own:

```shell
$ mycli sum 1 2 3
6
```

[Dry Types](//org_guide/dry/dry-types) works well here too:

```ruby
Types = Dry.Types()

class Tail < Dry::CLI::Command
  argument :file, required: true, desc: "File to read"
  argument :lines, default: 10, cast: Types::Coercible::Integer, desc: "Number of lines"

  def call(file:, lines:)
    puts "#{lines.inspect} lines of #{file}"
  end
end
```

```shell
$ mycli tail log.txt 20
20 lines of log.txt
```

Give the default as the value you want `#call` to receive, like `10` here.

When casting raises an error, the command doesn't run, and the error is printed:

```shell
$ mycli tail log.txt lots
Error: invalid value "lots" for LINES: invalid value for Integer(): "lots"

Usage: mycli tail FILE [LINES]
Run "mycli tail --help" for more information.
```

## Declaring arguments in order

Since arguments are matched by position, some orders can never work. Dry CLI raises an error when you declare them:

- **A required argument after an optional one.** The user couldn't give the required argument without also giving the optional one before it.

  ```ruby
  argument :env
  argument :name, required: true
  # => Dry::CLI::CommandDefinitionError: required argument `name' can't be declared after optional argument `env'
  ```

- **Any argument after an array argument.** The array argument takes all the remaining values, so none would be left for the arguments after it.

  ```ruby
  argument :files, type: :array
  argument :dest
  # => Dry::CLI::CommandDefinitionError: argument `dest' can't be declared after array argument `files'
  ```

If you redeclare an argument in a subclass, for example to change its `desc`, it keeps its original position.
