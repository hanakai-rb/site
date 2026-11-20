---
title: Invoking commands
layout: gem-single
name: dry-cli
---

Use `invoke` to run one command from inside another. Give it the command class, and the keyword arguments for its `#call`:

```ruby
class Migrate < MyApp::Command
  option :env, default: "development", desc: "Environment"

  def call(env:)
    invoke(Create, env:)
    logger.info "migrating"
  end
end
```

The other command is built with the same streams as the command invoking it, so its output goes to the same place. It also shares any [standard dependencies](//page/dependencies#standard-dependencies) from your base command class, like the `logger` here.

The other command receives only the keyword arguments its `#call` accepts. So you can pass along all of your command's options, and let it take the ones it needs:

```ruby
class Migrate < MyApp::Command
  option :env, default: "development", desc: "Environment"
  option :target, desc: "Version to migrate to"

  def call(**options)
    invoke(Create, **options)
    logger.info "migrating"
  end
end
```

If `Create#call` declares only `env:`, it receives `env:`, but not `target:`.

## Default values

The other command's option defaults apply to any options you don't give, or give as `nil`.

When you pass along all of your command's options, its own defaults are passed along too. These replace the other command's defaults for any options they share.

## Difference from the command line

When you invoke a command, it doesn't go through the same steps as when a user runs it:

- Values are not cast with `cast:`, or checked against `required:` or `values:`. Give values of the type the command expects.
- No `before` or `after` [callbacks](//page/callbacks) registered for the other command are run.
