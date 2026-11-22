---
title: Errors and exit codes
layout: gem-single
name: dry-cli
---

When a command finishes normally, the CLI exits with status 0. To stop early with a different exit code, a command can throw `:exit`, or raise `Dry::CLI::ExitError`.

## Throwing `:exit`

Throw `:exit` with an exit code to stop the CLI and exit with that code:

```ruby
class Deploy < Dry::CLI::Command
  def call
    unless File.exist?("config.yml")
      stderr.puts "config.yml not found"
      throw :exit, 1
    end

    puts "deployed"
  end
end
```

```shell
$ mycli deploy
config.yml not found

$ echo $?
1
```

A bare `throw :exit` exits with 0. Use it to stop early when there's nothing more to do:

```ruby
def call
  if up_to_date?
    puts "Already up to date"
    throw :exit
  end

  # ...
end
```

## Raising `Dry::CLI::ExitError`

Raise `Dry::CLI::ExitError` for an error the user is meant to see. The CLI prints its message to `stderr`, with no backtrace, then exits with its exit code. The exit code is 1 unless you give one:

```ruby
raise Dry::CLI::ExitError, "no releases on Sundays"
raise Dry::CLI::ExitError.new("deploy failed", exit_code: 2)
```

```shell
$ mycli release
no releases on Sundays

$ echo $?
1
```

You can raise it from anywhere your command runs, including deep inside other objects. For errors you raise often, make a subclass:

```ruby
class DeployFailed < Dry::CLI::ExitError
  def initialize(target)
    super("deploy to #{target} failed", exit_code: 2)
  end
end

raise DeployFailed.new("production")
```

Other errors are not rescued. They keep their backtrace, so you can find the bug:

```shell
$ mycli release
mycli:38:in 'MyCLI::Commands::Release#call': boom (RuntimeError)
        ...
```

## Callbacks

[Callbacks](//page/callbacks) can throw `:exit` or raise `Dry::CLI::ExitError` too. When a `before` callback does, the command doesn't run.

## Exit codes from Dry CLI

Dry CLI uses these exit codes itself:

| When                                        | Exit code |
| ------------------------------------------- | --------- |
| The user asks for help with `--help`        | 0         |
| An argument or option is invalid or missing | 1         |
| The command is unknown                      | 1         |

## Avoid `Kernel#exit`

You can still call `exit` in a command, but it ends the Ruby process straight away, so it skips the `exit:` you give to `Dry::CLI#call`. That makes your command harder to test. Throw `:exit` or raise `Dry::CLI::ExitError` instead. See [Testing](//page/testing).
