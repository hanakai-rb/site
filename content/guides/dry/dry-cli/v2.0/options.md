---
title: Options
layout: gem-single
name: dry-cli
---

An option is a named value given after the command name. For example, when a user types `mycli request --mode=http2`, then `--mode=http2` is an option to the `request` command. A command can take any number of options, in any order.

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    class Request < Dry::CLI::Command
      option :mode, default: "http", values: %w[http http2], aliases: ["-m"], desc: "The request mode"

      def call(mode:)
        puts "Performing a request (mode: #{mode})"
      end
    end

    register "request", Request
  end
end

Dry::CLI.new(MyCLI::Commands).call
```

```shell
$ mycli request
Performing a request (mode: http)

$ mycli request --mode=http2
Performing a request (mode: http2)

$ mycli request -m http2
Performing a request (mode: http2)
```

A value outside `values:` is an error, and so is an option the command doesn't declare:

```shell
$ mycli request --mode=unknown
Error: invalid value "unknown" for --mode; accepted values: http, http2

Usage: mycli request
Run "mycli request --help" for more information.

$ mycli request --unknown 1
Error: unknown option --unknown

Usage: mycli request
Run "mycli request --help" for more information.
```

As with arguments, `values:` can hold non-string values like `[1, 2, 3]`. These are turned into strings, then compared with what the user typed.

## Boolean options

An option with `type: :boolean` is a switch. The user turns it on with `--name` and off with `--no-name`:

```ruby
class Stop < Dry::CLI::Command
  option :graceful, type: :boolean, default: true, desc: "Stop gracefully"

  def call(graceful:)
    puts "stopped - graceful: #{graceful}"
  end
end
```

```shell
$ mycli stop
stopped - graceful: true

$ mycli stop --no-graceful
stopped - graceful: false

$ mycli stop --help
...
Options:
  --[no-]graceful  # Stop gracefully, default: true
  --help, -h       # Print this help
```

## Flag options

An option with `type: :flag` can only be turned on. There's no `--no-` form:

```ruby
class Build < Dry::CLI::Command
  option :verbose, type: :flag, default: false, desc: "Print every step"

  def call(verbose:)
    puts "building - verbose: #{verbose}"
  end
end
```

```shell
$ mycli build --verbose
building - verbose: true

$ mycli build --no-verbose
Error: unknown option --no-verbose

Usage: mycli build
Run "mycli build --help" for more information.
```

## Array options

An option with `type: :array` takes many values. The user can separate them with commas, or repeat the option:

```ruby
class Test < Dry::CLI::Command
  option :tags, type: :array, default: [], aliases: ["-t"], desc: "Only run tests with these tags"

  def call(tags:)
    puts "running tests tagged: #{tags.inspect}"
  end
end
```

```shell
$ mycli test --tags=slow,db
running tests tagged: ["slow", "db"]

$ mycli test --tags slow --tags db
running tests tagged: ["slow", "db"]

$ mycli test -t slow -t db
running tests tagged: ["slow", "db"]
```

An array option with `values:` checks each value against the list.

## Required options

Use `required: true` for an option the user must give:

```ruby
class Server < Dry::CLI::Command
  option :host, required: true, desc: "Host to bind to"
  option :port, required: true, desc: "Port to listen on"

  def call(host:, port:)
    puts "Listening on #{host}:#{port}"
  end
end
```

When a required option is missing, the command doesn't run, and the error identifies the option:

```shell
$ mycli server --host=localhost
Error: missing required option --port

Usage: mycli server --host=VALUE --port=VALUE
Run "mycli server --help" for more information.
```

Required options are marked in the help:

```shell
$ mycli server --help
Command:
  mycli server

Usage:
  mycli server

Options:
  --host=VALUE  # REQUIRED Host to bind to
  --port=VALUE  # REQUIRED Port to listen on
  --help, -h    # Print this help
```

An option with a `default:` always has a value, so `required: true` has no effect on it.

## Casting values

Values come from the command line as strings. Use `cast:` to turn them into something else. Give it anything that responds to `#call`, such as a lambda or a [Dry Types](//org_guide/dry/dry-types) type:

```ruby
Types = Dry.Types()

class Info < Dry::CLI::Command
  option :lines, cast: Types::Coercible::Integer, default: 10, desc: "Number of lines"
  option :sudo, cast: Types::Params::Bool, default: false, desc: "Run as root"
  option :uid, cast: ->(value) { Integer(value) }, desc: "User ID"

  def call(lines:, sudo:, uid: nil)
    puts "lines: #{lines.inspect}, sudo: #{sudo.inspect}, uid: #{uid.inspect}"
  end
end
```

```shell
$ mycli info
lines: 10, sudo: false, uid: nil

$ mycli info --lines 15 --sudo true --uid 16
lines: 15, sudo: true, uid: 16
```

Give the default as the value you want `#call` to receive, like `10` and `false` here.

For an array option, each value is cast on its own:

```ruby
option :ports, type: :array, cast: ->(value) { Integer(value) }
```

```shell
$ mycli wait --ports 80,443
[80, 443]
```

When casting raises an error, the command doesn't run, and the error is printed:

```shell
$ mycli info --sudo maybe
Error: invalid value "maybe" for --sudo: maybe cannot be coerced to false

Usage: mycli info
Run "mycli info --help" for more information.
```
