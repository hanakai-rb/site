---
title: Commands
layout: gem-single
name: dry-cli
---

A command is a subclass of `Dry::CLI::Command` with a `#call` method. You register each command under a name in a registry, then give the registry to `Dry::CLI`:

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    class Hello < Dry::CLI::Command
      def call
        puts "Hello!"
      end
    end
  end
end

class Version < Dry::CLI::Command
  def call
    puts "1.0.0"
  end
end

MyCLI::Commands.register "hi", MyCLI::Commands::Hello
MyCLI::Commands.register "v", Version

Dry::CLI.new(MyCLI::Commands).call
```

There's no convention linking a command's name to its class name. Registering the command is what gives it a name.

Inside a command, `puts` and `print` write to the command's own `stdout`. See [Output and styling](//page/output-and-styling) for more.

## Arguments to `#call`

`#call` receives the command's [arguments](//page/arguments) and [options](//page/options) as keyword arguments. Declare only the ones you use:

```ruby
class Greet < Dry::CLI::Command
  argument :name, required: true
  option :shout, type: :boolean, default: false

  def call(name:, shout:)
    greeting = "Hello, #{name}"
    puts shout ? greeting.upcase : greeting
  end
end
```

Dry CLI passes `#call` only the keyword arguments it declares. If another gem adds an option to your command (see [Callbacks](//page/callbacks)), your `#call` keeps working without changes. To receive everything, declare a `**` keyword splat:

```ruby
def call(**options)
  puts options.inspect
end
```

## Descriptions and examples

Use `desc` to describe a command, and `example` to show how to use it. Call `example` once per example, giving the arguments and a description:

```ruby
class Server < Dry::CLI::Command
  desc "Start the server"

  option :port, default: "2300", desc: "Port to listen on"
  option :host, default: "localhost", desc: "Host to bind to"

  example "--port=4000", "Listen on port 4000"
  example "--host=0.0.0.0", "Bind to all interfaces"

  def call(port:, host:)
    puts "Listening on #{host}:#{port}"
  end
end
```

The description appears in the list of commands, and both appear in the command's help:

```shell
$ mycli server -h
Command:
  mycli server

Usage:
  mycli server

Description:
  Start the server

Options:
  --port=VALUE                 # Port to listen on, default: "2300"
  --host=VALUE                 # Host to bind to, default: "localhost"
  --help, -h                   # Print this help

Examples:
  mycli server --port=4000     # Listen on port 4000
  mycli server --host=0.0.0.0  # Bind to all interfaces
```

### Long descriptions

Use `long_desc` to give a longer description. It's shown for `--help`, while `-h` keeps showing the short one:

```ruby
class Server < Dry::CLI::Command
  desc "Start the server"

  long_desc <<~DESC
    Starts the development server.

    The server reloads your code when files change.
  DESC
end
```

```shell
$ mycli server --help
Command:
  mycli server

Usage:
  mycli server

Description:
  Starts the development server.

  The server reloads your code when files change.

...
```

Without a `long_desc`, `--help` and `-h` both show the description from `desc`.

## Aliases

Give a command other names with `aliases:` when you register it:

```ruby
register "server", Server, aliases: ["s"]
register "version", Version, aliases: ["v", "-v", "--version"]
```

```shell
$ mycli s --port=4000
Listening on localhost:4000

$ mycli --version
1.0.0
```

## Hidden commands

Hide a command from the list of commands with `hidden: true`. You can still run it:

```ruby
register "completion", Completion, hidden: true
```

```shell
$ mycli
Commands:
  mycli server              # Start the server
  mycli version             # Print version

$ mycli completion
complete -F _mycli mycli
```

## Unknown commands

When a user gives a command that doesn't exist, Dry CLI suggests similar names, lists the commands, and exits with status 1:

```shell
$ mycli serve
I don't know how to 'serve'. Did you mean: 'server' ?

Commands:
  mycli server              # Start the server
  mycli version             # Print version
```

## Wrapping `#call`

You might wrap a command's `#call` to add behavior around it, such as with a prepended module. Such a wrapper usually declares a `**` keyword splat, so Dry CLI passes it every argument and option (see [Arguments to `#call`](#arguments-to-call)). The command's own `#call` may not accept all of them, so use `Dry::CLI.accepted_kwargs` to pass along only the ones it does:

```ruby
module Timed
  def call(**kwargs)
    started = Time.now
    super(**Dry::CLI.accepted_kwargs(method(:call).super_method, kwargs))
  ensure
    puts "took #{(Time.now - started).round(2)}s"
  end
end

class Deploy < Dry::CLI::Command
  prepend Timed

  argument :target, required: true
  option :verbose, type: :flag

  def call(target:)
    puts "deploying #{target}"
  end
end
```

```shell
$ mycli deploy production --verbose
deploying production
took 0.0s
```

Without `accepted_kwargs`, `Deploy#call` would receive `verbose:` and `args:` too, and raise an `ArgumentError`.

`accepted_kwargs` works with any method or proc.
