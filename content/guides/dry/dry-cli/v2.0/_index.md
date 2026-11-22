---
title: Introduction
pages:
  - commands
  - arguments
  - options
  - subcommands
  - callbacks
  - output-and-styling
  - spinners
  - errors-and-exit-codes
  - dependencies
  - invoking-commands
  - testing
  - upgrade-notes
---

Dry CLI is a general-purpose framework for building command line interface (CLI) applications. Each command is a class. You register your commands under names, and Dry CLI parses the command line, finds the right command, and calls it with its arguments and options.

It also gives you help output, errors for invalid input, styled text, spinners, and ways to test your commands without running a real process.

## Installation

Add the gem to your `Gemfile`:

```ruby
gem "dry-cli", "~> 2.0"
```

## Usage

Here's a small CLI, called `mycli`, with three commands:

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    class Version < Dry::CLI::Command
      desc "Print version"

      def call
        puts "1.0.0"
      end
    end

    class Echo < Dry::CLI::Command
      desc "Print input"

      argument :input, desc: "Input to print"

      example "", "Prints '(nothing to echo)'"
      example "hello, folks", "Prints 'hello, folks'"

      def call(input: nil)
        puts input || "(nothing to echo)"
      end
    end

    class Start < Dry::CLI::Command
      desc "Start the server"

      argument :root, required: true, desc: "Root directory"
      option :port, default: 2300, cast: ->(value) { Integer(value) }, desc: "Port to listen on"

      def call(root:, port:)
        puts "started - root: #{root}, port: #{port}"
      end
    end

    register "version", Version, aliases: ["v", "-v", "--version"]
    register "echo", Echo
    register "start", Start
  end
end

Dry::CLI.new(MyCLI::Commands).call
```

Run `mycli` with no arguments to see the available commands:

```shell
$ mycli
Commands:
  mycli echo [INPUT]           # Print input
  mycli start ROOT             # Start the server
  mycli version                # Print version
```

Every command gets a `--help` option:

```shell
$ mycli echo --help
Command:
  mycli echo

Usage:
  mycli echo [INPUT]

Description:
  Print input

Arguments:
  INPUT                    # Input to print

Options:
  --help, -h               # Print this help

Examples:
  mycli echo               # Prints '(nothing to echo)'
  mycli echo hello, folks  # Prints 'hello, folks'
```

Each command's `#call` receives its arguments and options as keyword arguments:

```shell
$ mycli echo
(nothing to echo)

$ mycli echo hello
hello

$ mycli start . --port 3000
started - root: ., port: 3000

$ mycli v
1.0.0
```

When the input is wrong, Dry CLI prints an error and exits with status 1, without calling the command:

```shell
$ mycli start
Error: missing required argument ROOT

Usage: mycli start ROOT
Run "mycli start --help" for more information.

$ mycli start . --port nope
Error: invalid value "nope" for --port: invalid value for Integer(): "nope"

Usage: mycli start ROOT
Run "mycli start --help" for more information.
```

From here, see [Commands](//page/commands) to learn how to write and register commands, then [Arguments](//page/arguments) and [Options](//page/options) for the input they take.

If you're upgrading from Dry CLI 1.x, see the [upgrade notes](//page/upgrade-notes).
