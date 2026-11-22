---
title: Upgrade notes
layout: gem-single
name: dry-cli
---

> [!NOTE]
> These notes cover an upgrade from Dry CLI 1.x to 2.0.

Dry CLI 2.0 adds namespaces, value casting, styled text, spinners, exit codes, and much more. The notes below focus on the steps to upgrade an existing CLI.

## Required changes

These changes are needed for a baseline upgrade to 2.0. Some of them apply only if your commands use a particular feature.

### Use a supported Ruby version

Dry CLI 2.0 requires Ruby 3.3 or newer.

### Upgrade the gem

Update your `Gemfile`:

```ruby
gem "dry-cli", "~> 2.0"
```

### Rename `out` and `err` to `stdout` and `stderr`

Commands now write to `stdout` and `stderr`, instead of `out` and `err`:

```ruby
# Before
def call
  out.puts "Deployed"
  err.puts "Warning: no changes"
end

# After
def call
  stdout.puts "Deployed"
  stderr.puts "Warning: no changes"
end
```

`Dry::CLI#call` takes the same new names:

```ruby
# Before
cli.call(arguments: ["deploy"], out: my_out, err: my_err)

# After
cli.call(arguments: ["deploy"], stdout: my_out, stderr: my_err)
```

Inside a command, `puts` and `print` now write to the command's `stdout`, rather than Ruby's own `$stdout`. These are the same unless you give the CLI other streams. See [Output and styling](//page/output-and-styling).

### Check your required options

`required: true` on an option is now enforced. Before, it was accepted but did nothing. Now, if a user leaves out a required option, the command doesn't run, and Dry CLI prints an error:

```shell
$ mycli server --host=localhost
Error: missing required option --port

Usage: mycli server --host=VALUE --port=VALUE
Run "mycli server --help" for more information.
```

Look for options with `required: true` and no `default:`. Remove `required: true` from any that users should be able to leave out. An option with a `default:` always has a value, so it's never treated as required.

### Check the order of your arguments

Dry CLI now raises `Dry::CLI::CommandDefinitionError` for arguments that can't work:

- An argument with both `required: true` and a `default:`. Remove one of them.
- A required argument declared after an optional one.
- Any argument declared after an array argument.

Since arguments are matched by position, these commands could never be called correctly. See [Declaring arguments in order](//page/arguments#declaring-arguments-in-order).

### Update any tests that match error messages

Error messages for invalid input have changed. They now give more detail about what's wrong, such as which option or argument has the problem, and which values are accepted. They also end with the command's usage, and how to get help:

```shell
$ mycli server --unknown 1234
# Before
ERROR: "mycli server" was called with arguments "--unknown 1234"
# After
Error: unknown option --unknown

Usage: mycli server
Run "mycli server --help" for more information.

$ mycli db rollback 4
# Before
ERROR: "mycli db rollback" was called with arguments "4"
# After
Error: invalid value "4" for STEPS; accepted values: 1, 2, 3

Usage: mycli db rollback [STEPS]
Run "mycli db rollback --help" for more information.
```

Accepted values in help output are now separated by commas, like the error messages:

```text
# Before
--engine=VALUE  # Engine: (irb/pry)
# After
--engine=VALUE  # Engine: (irb, pry)
```

### Check commands that read array arguments or `args`

These bug fixes may change the values your commands receive:

- An array argument is now always an array. Before, it was missing when the user gave no values for it.
- A required array argument no longer has its values repeated in `args`.
- An option with both `type: :array` and `values:` now gives an array, even for a single value. Before, it gave a string.
- An optional argument with `values:` can now be left out. Before, leaving it out was an error.

## Recommended changes

These changes are not needed, but they make your commands simpler and easier to test.

### Give each example separately

`example` now takes one example and its description, and you call it once per example:

```ruby
# Before
example [
  "--port=4000    # Listen on port 4000",
  "--host=0.0.0.0 # Bind to all interfaces"
]

# After
example "--port=4000", "Listen on port 4000"
example "--host=0.0.0.0", "Bind to all interfaces"
```

Giving `example` an array, as before, still works, but prints a deprecation warning. It will stop working in Dry CLI 3.0.

### Stop the CLI with `throw :exit` or `Dry::CLI::ExitError`

If your commands call `exit` to stop early, change them to throw `:exit` or raise `Dry::CLI::ExitError`:

```ruby
# Before
err.puts "config.yml not found"
exit 1

# After
throw :exit, 1 # after printing to stderr
# or
raise Dry::CLI::ExitError, "config.yml not found"
```

Calling `exit` still works, but it ends the process straight away. Throwing `:exit` or raising `Dry::CLI::ExitError` goes through the `exit:` you give to `Dry::CLI#call`, so you can check exit codes in tests. See [Errors and exit codes](//page/errors-and-exit-codes) and [Testing](//page/testing).

### Remove `**` from `#call`

Commands and callbacks now receive only the keyword arguments they declare. You no longer need a `**` catch-all to accept options you don't use, or options added by other gems:

```ruby
# Before
def call(name:, **)

# After
def call(name:)
```

Since commands don't need `**` any more, `def call(*)` for commands with no arguments or options can become `def call`.

### Use namespaces for groups of commands

If you registered commands under a shared prefix only to group them, consider a [namespace](//page/subcommands#namespaces). It gives the group a description and its own help.
