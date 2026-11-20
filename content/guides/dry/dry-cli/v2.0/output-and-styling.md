---
title: Output and styling
layout: gem-single
name: dry-cli
---

Your commands write output to streams, and you can style that output with color and weight. Users see your styles when they run your CLI in a terminal. When the output goes anywhere else, like a file, Dry CLI removes the styles for you.

## Streams

Every command has three streams: `stdout`, `stderr` and `stdin`. Write normal output to `stdout`, and errors and progress to `stderr`:

```ruby
class Deploy < Dry::CLI::Command
  def call
    stderr.puts "Deploying..."
    stdout.puts "Deployed"
  end
end
```

Inside a command, a plain `puts` or `print` writes to `stdout`, so `puts "Deployed"` does the same thing as `stdout.puts "Deployed"`.

By default, the streams are Ruby's own `$stdout`, `$stderr` and `$stdin`. You can give the CLI other streams, which is most useful for [testing](//page/testing):

```ruby
Dry::CLI.new(MyCLI::Commands).call(stdout: my_stdout, stderr: my_stderr)
```

`stdout` and `stderr` are `Dry::CLI::Stream` objects. They wrap the real IO, and know how to write styled text to it. They have the usual `puts`, `print`, `printf`, `write` and `<<` methods. When you need the underlying IO itself, use `stdout.raw`.

## Styling text

Build a style by chaining style names onto `style`, then apply it to text by calling it with `[]`:

```ruby
class Deploy < Dry::CLI::Command
  def call
    stdout.puts style.green["Deployed"]
    stderr.puts style.bold.red["Something went wrong"]
  end
end
```

A style is a value, so you can build it once, give it a name, and use it wherever you need it:

```ruby
class Deploy < Dry::CLI::Command
  ERROR = style.bold.red

  def call
    stderr.puts ERROR["Something went wrong"]
  end
end
```

`style` is available at both the class and instance level in a command. Outside a command, use `Dry::CLI::Style` directly:

```ruby
ERROR = Dry::CLI::Style.bold.red
```

`ERROR["Boom"]` and `ERROR.call("Boom")` do the same thing. A style can also be converted to a proc:

```ruby
errors.map(&ERROR).each { |line| stderr.puts line }
```

## Available styles

Weights and decorations: `bold`, `dim`, `italic`, `underline`, `blink`, `reverse`, `invisible`.

Foreground colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`, and a `bright_` version of each, like `bright_red`.

Background colors: `on_black`, `on_red`, and so on, including `on_bright_` versions like `on_bright_red`.

Chain as many as you like, in any order:

```ruby
style.bold.yellow.on_blue["Look at me"]
```

### Any color

You can also give a color as RGB, hex, or an index in the 256-color palette:

```ruby
style.rgb(255, 136, 0)
style.hex("#ff8800")
style.ansi256(208)

style.on_rgb(0, 0, 51)
style.on_hex("#003")
style.on_ansi256(17)
```

Not every terminal can show every color, however. Dry CLI changes each color to the nearest one the terminal supports, so you can use any color you like.

## Naming your styles

Consider giving your styles names that say what they mean, not what they look like. Your commands then read in terms of intent, and you can restyle everything from one place:

```ruby
module MyCLI
  module Styles
    extend Dry::CLI::StyleMixin

    ERROR = style.bold.red
    WARNING = style.yellow
    SUCCESS = style.green
    MUTED = style.dim
  end
end
```

`Dry::CLI::StyleMixin` gives a module or class its `style` method. Include or extend it anywhere you want to build styles outside a command.

```ruby
class Deploy < Dry::CLI::Command
  include MyCLI::Styles

  def call
    stdout.puts SUCCESS["Deployed"]
  end
end
```

## Working with styled text

Applying a style gives you a styled text object, not a `String` of escape sequences. It converts to escape sequences only when you write it to a stream, because that's when we know where it's going, and what that can show. Most of what you'd do with a `String` still works.

### Joining

Join more text to styled text with `+`:

```ruby
stdout.puts ERROR["failed"] + ": " + reason
```

### Formatting

Styled text has a `#%` method that works like `String#%`, and keeps the styling:

```ruby
WAITING = style.dim["Waiting for "] + style.bold["%d"] + style.dim[" seconds"]

stdout.puts WAITING % 5
```

### Nesting

When you style text that already has styled parts, the outer style picks up again after each one:

```ruby
name = style.bold["config.yml"]

stdout.puts style.red["Couldn't read #{name}, check the path"]
```

Everything after `config.yml` is still red.

### Aligning

Styled text knows its length without its escape sequences, so `#ljust`, `#rjust` and `#length` count only what will be seen:

```ruby
commands.each do |name, description|
  stdout.puts style.bold[name].ljust(20) + description
end
```

### Rendering early

Some things want a `String` straight away: a plain `String` on the left of `+`, interpolation, and `format`. In these cases, the styled text is turned into escape sequences immediately, before it reaches a stream:

```ruby
stdout.puts "failed: " + ERROR[reason]
stdout.puts "read #{ERROR[path]} and gave up"
```

Text rendered early is done so based on the capabilities of Ruby's own `$stdout`. This is fine most of the time, and matters only when your stream capabilities differ. For example, if a user redirects `stdout` to a file while `stderr` is still their terminal, text rendered early and written to `stderr` arrives plain. The other way around is safe too: if `stderr` goes to a file, the stream removes the escape sequences before writing. So the worst that can happen is lost color.

To keep text unrendered until it's written, start with styled text. `style` on its own styles nothing, so you can use it to begin a line:

```ruby
stdout.puts style["read "] + ERROR[path] + " and gave up"
```

## Turning styling on and off

Each stream decides for itself whether to show styling. By default, styling is on when the stream is a terminal. So when a user pipes your output to a file or another program, they get plain text.

Since `stdout` and `stderr` decide separately, redirecting one doesn't change the other. When you capture a command's output in a test, it's not a terminal, so it's plain too.

Users can control styling with environment variables:

- [`NO_COLOR`](https://no-color.org) turns styling off.
- `FORCE_COLOR` turns styling on, even when the stream isn't a terminal.

To decide for yourself, set `Dry::CLI::Style.enabled`. For example, to support `--color` and `--no-color` options:

```ruby
class Deploy < Dry::CLI::Command
  ERROR = style.bold.red

  option :color, type: :boolean, desc: "Colorize output"

  def call(color: nil)
    Dry::CLI::Style.enabled = color

    stderr.puts ERROR["Something went wrong"]
  end
end
```

When the user gives neither option, `color` is `nil`, which means "decide automatically". Set `Dry::CLI::Style.enabled` back to `nil` at any time to return to deciding automatically.

Dry CLI also detects how many colors the terminal supports. To choose for yourself, set `Dry::CLI::Style.color_level` to `:truecolor`, `:ansi256`, `:ansi16` or `:ansi8`. Set it to `:none` to keep weights and decorations like `bold`, but drop all color. Set it back to `nil` to detect it again.

## Removing styling

Use `unstyle` to take the escape sequences out of text you didn't style yourself, like the output of another program:

```ruby
class Deploy < Dry::CLI::Command
  def call
    stdout.puts unstyle(`kubectl rollout status deploy/api`)
  end
end
```

Outside a command, use `Dry::CLI::Style.unstyle`.

You don't need `unstyle` for your own styled text. Streams that can't show styling already write it plain.
