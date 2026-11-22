---
title: Spinners
layout: gem-single
name: dry-cli
---

A spinner shows the user that a long-running task is still working. Wrap the task in a block, and the spinner will animate while it runs and clear itself when it finishes:

```ruby
class Install < Dry::CLI::Command
  def call
    Dry::CLI::Spinner::Dot.run("%{spinner} Installing gems...", stream: stderr) do
      install_gems
    end

    puts "Installed"
  end
end
```

`%{spinner}` in the message is where the spinner's frame is drawn.

`run` returns the value of the block:

```ruby
gems = Dry::CLI::Spinner::Dot.run("%{spinner} Resolving...", stream: stderr) do
  resolve_gems
end
```

## Where spinners are drawn

Spinners are drawn to `$stderr` by default. Inside a command, give `stream: stderr` so the spinner goes to the command's own stream.

When the stream isn't a terminal, such as when output is redirected to a file, nothing is drawn, but the block still runs.

## Spinner styles

Dry CLI has four spinners:

| Spinner                       | Frames                |
| ----------------------------- | --------------------- |
| `Dry::CLI::Spinner::Dot`      | `⣷ ⣯ ⣟ ⡿ ⢿ ⣻ ⣽ ⣾`     |
| `Dry::CLI::Spinner::Ellipsis` | `.`, `..`, `...`      |
| `Dry::CLI::Spinner::Line`     | `\| / - \`            |
| `Dry::CLI::Spinner::MiniDot`  | `⠏ ⠇ ⠧ ⠦ ⠴ ⠼ ⠸ ⠹ ⠙ ⠋` |

To make your own, give the frames and how many to show each second:

```ruby
Arrows = Dry::CLI::Spinner.new(frames: %w[← ↖ ↑ ↗ → ↘ ↓ ↙], fps: 8)

Arrows.run("%{spinner} Working...") { work }
```

You can also change the speed for one run with `fps:`:

```ruby
Dry::CLI::Spinner::Dot.run("%{spinner} Working...", fps: 20) { work }
```

## Styling the message

The message can be [styled text](//page/output-and-styling):

```ruby
class Install < Dry::CLI::Command
  SPINNER = style.bold.green
  MUTED = style.dim

  def call
    message = SPINNER["%{spinner}"] + MUTED[" Installing gems..."]

    Dry::CLI::Spinner::Dot.run(message, stream: stderr) do
      install_gems
    end
  end
end
```

## Changing the message on each tick

To change the message while the spinner runs, give `run` a block that takes one parameter. Use it to register `before_tick` and `after_tick` hooks, and give your work to `run`:

```ruby
class Wait < Dry::CLI::Command
  SPINNER = style.bold.green
  MUTED = style.dim

  def call
    message = SPINNER["%{spinner}"] + MUTED[" waiting "] + style.bold["%{seconds}"] + MUTED[" seconds"]
    trailer = Dry::CLI::Spinner::Ellipsis.frames.cycle
    start = Time.now

    Dry::CLI::Spinner::MiniDot.run(message, stream: stderr) do |s|
      s.before_tick do |_stream, data|
        data[:seconds] = (Time.now - start).ceil
      end

      s.after_tick do |stream|
        stream << MUTED[trailer.next]
      end

      s.run { sleep 6 }
    end
  end
end
```

- `before_tick` runs before each frame is drawn. It gets the stream and a hash of the values for the message. Add your own values to the hash, and use them in the message with `%{name}`.
- `after_tick` runs after each frame is drawn. It gets the stream, so you can write more text after the message.

The hooks run in a separate thread. Don't `throw :exit` or raise `Dry::CLI::ExitError` from them. Do that from the `run` block instead.

Inside the block given to `run`, and inside its own hook blocks, `self` is still your command. You can use your command's methods (like `style` and `stderr`) and its instance variables, just as you would outside the block.
