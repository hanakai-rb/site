---
title: Testing
layout: gem-single
name: dry-cli
---

You can test your commands without running a real process. Give them streams you can read back, like `StringIO`, and catch the exit code with a proc.

The examples here use RSpec, but the same approach works with any test framework.

## Testing a command on its own

Build the command with `stdout:` and `stderr:`, then call it with the keyword arguments for its `#call`:

```ruby
RSpec.describe MyCLI::Commands::Deploy do
  subject(:command) { described_class.new(stdout:, stderr:) }

  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }

  it "deploys" do
    command.call(target: "staging", force: false)

    expect(stdout.string).to eq "deployed to staging\n"
  end
end
```

`.new` also takes `stdin:`, and any keywords for the command's own `#initialize`. This lets you give it test versions of its [dependencies](//page/dependencies):

```ruby
described_class.new(stdout:, deployer: fake_deployer)
```

Calling `#call` directly skips parsing the command line. Arguments and options are not cast or checked, and their defaults don't apply, so give every value the command needs.

## Testing through the CLI

To test the full path, from the command line to your command, call `Dry::CLI#call` with `arguments:` and your streams. Give `exit:` a proc to receive the exit code, instead of letting the CLI exit the process:

```ruby
RSpec.describe "mycli deploy" do
  subject(:cli) { Dry::CLI.new(MyCLI::Commands) }

  let(:stdout) { StringIO.new }
  let(:stderr) { StringIO.new }
  let(:exit_codes) { [] }

  def run_cli(*arguments)
    cli.call(arguments:, stdout:, stderr:, exit: ->(code) { exit_codes << code })
  end

  it "deploys to staging" do
    run_cli("deploy", "staging")

    expect(stdout.string).to eq "deployed to staging\n"
    expect(exit_codes).to be_empty
  end

  it "needs --force for production" do
    run_cli("deploy", "production")

    expect(stderr.string).to eq "deploys to production need --force\n"
    expect(exit_codes).to eq [1]
  end

  it "rejects unknown targets" do
    run_cli("deploy", "mars")

    expect(stderr.string).to include 'invalid argument "mars" for "target"'
    expect(exit_codes).to eq [1]
  end
end
```

The `exit:` proc is called only when the CLI exits early: when a command throws `:exit` or raises `Dry::CLI::ExitError`, when the input is invalid, or when the user asks for help. When a command finishes normally, it isn't called.

This works only for commands that use `throw :exit` or `Dry::CLI::ExitError` to stop. A command that calls `Kernel#exit` itself still ends the process. See [Errors and exit codes](//page/errors-and-exit-codes).

Some error messages include the program name, which comes from `$0`. In a test, this is the name of your test runner, like `rspec`.

## Styled output

A `StringIO` is not a terminal, so styled text written to it arrives plain. Your tests can check for the plain text, without escape sequences.

To test the styling itself, turn styling on and set a color level, so the result doesn't depend on the terminal your tests run in. Set both back to `nil` afterwards:

```ruby
around do |example|
  Dry::CLI::Style.enabled = true
  Dry::CLI::Style.color_level = :ansi16
  example.run
ensure
  Dry::CLI::Style.enabled = nil
  Dry::CLI::Style.color_level = nil
end
```

Then check the output for the escape sequences you expect, like `"\e[31m"` for red. See [Output and styling](//page/output-and-styling#turning-styling-on-and-off) for more.
