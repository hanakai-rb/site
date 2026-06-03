---
title: Converting config to Data
---

### Overview

`Config#to_data` returns a frozen [`Data`](https://docs.ruby-lang.org/en/4.0/Data.html) representation of the config's resolved values. It is intended for performance-sensitive code that reads the same config repeatedly, such as per-request rendering hot paths.

```ruby
class App
  extend Dry::Configurable

  setting :adapter, default: :http
  setting :database do
    setting :dsn, default: "sqlite:memory"
  end
end

App.config.finalize!

data = App.config.to_data
data.adapter          # => :http
data.database.dsn     # => "sqlite:memory"
data.frozen?          # => true
```

Nested settings become nested `Data` instances, so the same dotted-access pattern you use on `config` works on the returned `Data`.

### When to use it

Reading a value through `config.foo` dispatches through `method_missing`. When the same config is read many times (e.g. once per request), going through `Data` accessors is significantly faster. You will only see this speedup if you cache the returned `Data`; calling `#to_data` allocates a fresh object every time.

```ruby
class Renderer
  def initialize(config)
    @config = config.to_data
  end

  attr_reader :config

  def call(template)
    # Reads like `config.adapter` now hit a Data accessor directly
    # ...
  end
end
```

### Comparison with `reader: true`

The `reader: true` option on `setting` is another way to avoid the `method_missing` cost: it defines `attr_reader`-style methods directly on the configured object.

```ruby
class App
  extend Dry::Configurable

  setting :adapter, default: :http, reader: true
end

App.adapter # => :http, no method_missing
```

The tradeoff is that those readers live on the configured object itself. That means:

- The configured class/module/instance grows a method for every reader setting, which can collide with existing methods or clutter its public surface.
- For instance-level configurables, every instance carries the reader methods.
- Readers can only be defined per setting up-front; you cannot opt a whole config block into reader access in one go.

`#to_data` takes the opposite approach: the accessors live on a separate frozen `Data` object that you hold (and cache) yourself. The configured object stays untouched, you get accessors for every setting at every nesting level for free, and reads through the `Data` are typically faster than `reader:` methods because they go through `Data`'s built-in accessors rather than `dry-configurable`'s reader dispatch.

Reach for `reader: true` when ergonomics on the configured object matter most. Reach for `#to_data` when you want a self-contained, frozen snapshot you can pass around (especially in hot paths).

### Finalize before calling

`#to_data` requires the config to be finalized (frozen). Calling it on a mutable config raises `Dry::Configurable::FrozenConfigError`.

```ruby
App.config.to_data
# => raises Dry::Configurable::FrozenConfigError

App.config.finalize!
App.config.to_data
# => #<data App adapter=:http, database=#<data ...>>
```

Finalizing matches the intended use case: once configuration is locked down at boot, the resulting `Data` is a stable, frozen snapshot.

### Value capture semantics

Values are captured by reference. Freezing the `Data` does not deep-freeze the values it holds, so in-place mutation of a captured value remains visible through the `Data`:

```ruby
class App
  extend Dry::Configurable

  setting :tags, default: ["a", "b"]
end

App.config.finalize!
data = App.config.to_data

App.config.tags << "c"
data.tags # => ["a", "b", "c"]
```

If you need an immutable snapshot, freeze (or `dup.freeze`) the values themselves before finalizing.

### Reserved setting names

Because `#to_data` builds a `Data` class whose members are your setting names, a setting cannot share a name with an instance method on `Data` (such as `hash`, `members`, `to_h`, or `with`). Defining one raises `ArgumentError` at setting-definition time:

```ruby
class App
  extend Dry::Configurable

  setting :members
  # => raises ArgumentError: setting name `:members` conflicts with a Data
  #    instance method, which would break Config#to_data
end
```

Pick a different name (e.g. `:member_list`) if you hit this.
