---
title: Subcommands
layout: gem-single
name: dry-cli
---

A subcommand is a command registered under a nested name, with a space between each part:

```ruby
#!/usr/bin/env ruby
require "bundler/setup"
require "dry/cli"

module MyCLI
  module Commands
    extend Dry::CLI::Registry

    module Generate
      class Config < Dry::CLI::Command
        desc "Generate configuration"

        def call
          puts "generated configuration"
        end
      end

      class Test < Dry::CLI::Command
        desc "Generate tests"

        def call
          puts "generated tests"
        end
      end
    end

    register "generate config", Generate::Config
    register "generate test", Generate::Test
  end
end

Dry::CLI.new(MyCLI::Commands).call
```

Run the first part of the name on its own to list its subcommands:

```shell
$ mycli generate
Commands:
  mycli generate config            # Generate configuration
  mycli generate test              # Generate tests

$ mycli generate config
generated configuration
```

## Registering with a block

To register many subcommands under one prefix, pass a block to `register`. You can give the prefix aliases too:

```ruby
register "generate", aliases: ["g"] do |prefix|
  prefix.register "config", Generate::Config
  prefix.register "test", Generate::Test
end
```

```shell
$ mycli g config
generated configuration
```

## Namespaces

A namespace groups subcommands under a name, and gives that group its own description and help. Subclass `Dry::CLI::Namespace`, then register it under the name of the group:

```ruby
class DB < Dry::CLI::Namespace
  desc "Manage the database"

  long_desc <<~DESC
    Manage the database.

    These commands read connection details from DATABASE_URL.
  DESC

  class Migrate < Dry::CLI::Command
    desc "Run pending migrations"

    def call
      puts "migrated"
    end
  end

  class Rollback < Dry::CLI::Command
    desc "Roll back the last migration"

    def call
      puts "rolled back"
    end
  end
end

register "db", DB
register "db migrate", DB::Migrate
register "db rollback", DB::Rollback
```

A namespace is not a command itself. It's listed with its description:

```shell
$ mycli
Commands:
  mycli db [SUBCOMMAND]                     # Manage the database
  mycli generate [SUBCOMMAND]
```

Running it lists its subcommands:

```shell
$ mycli db
Commands:
  mycli db migrate           # Run pending migrations
  mycli db rollback          # Roll back the last migration
```

And it has its own help:

```shell
$ mycli db --help
Namespace:
  mycli db

Usage:
  mycli db SUBCOMMAND

Description:
  Manage the database.

  These commands read connection details from DATABASE_URL.

Subcommands:
  migrate                           # Run pending migrations
  rollback                          # Roll back the last migration

Options:
  --help, -h  # Print this help
```

As with commands, `-h` shows the short description from `desc`, and `--help` shows the `long_desc`.

If you want the parent name to be a command that runs, rather than a group, use a [parent command](#parent-commands).

## Parent commands

A command can have subcommands of its own, while still running when called on its own. Register the parent command under a name, then register each subcommand under a longer name that starts with it:

```ruby
class Account < Dry::CLI::Command
  desc "Information about account"

  argument :format, default: "short", values: %w[long short], desc: "Output format"

  def call(format:)
    puts "Information about account in #{format} format."
  end

  class Users < Dry::CLI::Command
    desc "Information about account users"

    def call
      puts "Information about account users."
    end
  end
end

register "account", Account
register "account users", Account::Users
```

Both the parent and its subcommands can declare arguments and options. The parent command's help shows both ways to call it:

```shell
$ mycli account -h
Command:
  mycli account

Usage:
  mycli account [FORMAT] | mycli account SUBCOMMAND

Description:
  Information about account

Subcommands:
  users                             # Information about account users

Arguments:
  FORMAT      # Output format: (long, short)

Options:
  --help, -h  # Print this help
```

```shell
$ mycli account
Information about account in short format.

$ mycli account long
Information about account in long format.

$ mycli account users
Information about account users.
```

> [!NOTE]
> If you call a parent command with an argument equal to the name of one of its subcommands, Dry CLI calls the subcommand instead of the parent command.
