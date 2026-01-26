---
title: Container
---

`Dry::Core::Container` is a simple, thread-safe container, intended to be one half of a dependency injection system, possibly in combination with [dry-auto_inject](//org_guide/dry/dry-auto_inject). It used to be a separate gem ([Dry Container](//org_guide/dry/dry_container)) and it powers containers in [Dry System](/learn/dry/dry-system/v1.2/container).

### Brief Example

```ruby
require 'dry/core/container'

container = Dry::Core::Container.new
container.register(:parrot) { |a| puts a }

parrot = container.resolve(:parrot)
parrot.call("Hello World")
# Hello World
# => nil
```

## What are containers and dependency injection?

At its most basic, dependency injection is a simple technique that makes it possible to implement patterns or principles of code design that rely on object composition, such as the [SOLID principles](https://en.wikipedia.org/wiki/SOLID). By being passed its dependencies instead of instantiating them itself, your code can be written to depend on abstractions, with implementations that can vary independently, potentially at runtime or for specific use-cases, such as injecting a double instead of an expensive web service call when running tests. A container offers two main improvements to basic dependency injection: it takes the work out of manually instantiating and composing trees of dependencies, and it makes it trivial to swap out one implementation of a dependency for another.

Note that dependency _injection_, dependency _inversion_, and _inversion of control_ are related, but distinct, concepts that are often confused or conflated. [**Inversion of control**](https://en.wikipedia.org/wiki/Inversion_of_control) is an architectural pattern by which a low-level _system_ passes control to higher-level application code, as opposed to the classical pattern, where higher-level code calls directly into a lower-level dependency. **Dependency inversion** is a principle that encourages thoughtfully designing the interfaces that your classes depend on, instead of tightly coupling to an _external_ dependency's interface. This shouldn't imply that the external dependency itself changes in any way; instead it encourages the use of bridge, facade, or adapter classes to implement the interface that you designed using the third party dependency's public interface. **Dependency injection**, finally, is the practical technique of providing an object with its dependencies, instead of hard-coding them.

`Dry::Core::Container` makes it much easier than with so-called "idiomatic" Ruby to make use of any one or all three of these, as desired.

### Detailed Example

```ruby
require 'dry/core/container'

User = Struct.new(:name, :email)

data_store = Concurrent::Map.new.tap do |ds|
  ds[:users] = Concurrent::Array.new
end

# Initialize container
container = Dry::Core::Container.new

# Register an item with the container to be resolved later
container.register(:data_store, data_store)
container.register(:user_repository, -> { container.resolve(:data_store)[:users] })

# Resolve an item from the container
container.resolve(:user_repository) << User.new('Jack', 'jack@dry-container.com')
# You can also resolve with []
container[:user_repository] << User.new('Jill', 'jill@dry-container.com')
# => [
#      #<struct User name="Jack", email="jack@dry-container.com">,
#      #<struct User name="Jill", email="jill@dry-container.com">
#    ]

# If you wish to register an item that responds to call but don't want it to be
# called when resolved, you can use the options hash
container.register(:proc, -> { :result }, call: false)
container.resolve(:proc)
# => #<Proc:0x007fa75e652c98@(irb):25 (lambda)>

# You can also register using a block
container.register(:item) do
  :result
end
container.resolve(:item)
# => :result

container.register(:block, call: false) do
  :result
end
container.resolve(:block)
# => #<Proc:0x007fa75e6830f0@(irb):36>

# You can also register items under namespaces using the #namespace method
container.namespace('repositories') do
  namespace('checkout') do
    register('orders') { Concurrent::Array.new }
  end
end
container.resolve('repositories.checkout.orders')
# => []

# Or import a namespace
ns = Dry::Core::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users') { Concurrent::Array.new }
  end
end
container.import(ns)
container.resolve('repositories.authentication.users')
# => []

# Also, you can import namespaces in container class
Repositories = Dry::Core::Container::Namespace.new('repositories') do
  namespace('authentication') do
    register('users') { Concurrent::Array.new }
  end
end
# => []
```

## Mixin

You can also get container behaviour at both the class and instance level via the mixin:

```ruby
require 'dry/core/container'

class Container
  extend Dry::Core::Container::Mixin
end
Container.register(:item, :my_item)
Container.resolve(:item)
# => :my_item

class ContainerObject
  include Dry::Core::Container::Mixin
end
container = ContainerObject.new
container.register(:item, :my_item)
container.resolve(:item)
# => :my_item
```

## Registry & Resolver

### Register options

#### `call`

This boolean option determines whether or not the registered item should be invoked when resolved, i.e.

```ruby
container = Dry::Core::Container.new
container.register(:key_1, call: false) { "Integer: #{rand(1000)}" }
container.register(:key_2, call: true)  { "Integer: #{rand(1000)}" }

container.resolve(:key_1) # => <Proc:0x007f98c90454c0@dry_c.rb:23>
container.resolve(:key_1) # => <Proc:0x007f98c90454c0@dry_c.rb:23>

container.resolve(:key_2) # => "Integer: 157"
container.resolve(:key_2) # => "Integer: 713"
```

#### `memoize`

This boolean option determines whether or not the registered item should be memoized on the first invocation, i.e.

```ruby
container = Dry::Core::Container.new
container.register(:key_1, memoize: true)  { "Integer: #{rand(1000)}" }
container.register(:key_2, memoize: false) { "Integer: #{rand(1000)}" }

container.resolve(:key_1) # => "Integer: 734"
container.resolve(:key_1) # => "Integer: 734"

container.resolve(:key_2) # => "Integer: 855"
container.resolve(:key_2) # => "Integer: 282"
```

### Customization

You can configure how items are registered and resolved from the container. Currently, registry can be as simple as a proc
but custom resolver should subclass the default one or have the same public interface.

```ruby
class CustomResolver < Dry::Core::Container::Resolver
  RENAMED_KEYS = { 'old' => 'new' }

  def call(container, key)
    container.fetch(key.to_s) {
      fallback_key = RENAMED_KEYS.fetch(key.to_s) {
        raise Error, "Missing #{ key }"
      }
      container.fetch(fallback_key) {
        raise Error, "Missing #{ key } and #{ fallback_key }"
      }
    }.call
  end
end

class Container
  extend Dry::Core::Container::Mixin

  config.registry = ->(container, key, item, options) { container[key] = item }
  config.resolver = CustomResolver
end

class ContainerObject
  include Dry::Core::Container::Mixin

  config.registry = ->(container, key, item, options) { container[key] = item }
  config.resolver = CustomResolver
end
```

This allows you to customise the behaviour of `Dry::Core::Container`. For example, the default registry (`Dry::Core::Container::Registry`) will raise a `Dry::Core::Container::Error` exception if you try to register under a key that is already used. Should you want to just overwrite the existing value in that scenario, configuration allows you to do so.

## Stubbing in tests

To stub your containers call `#stub` method:

```ruby
container = Dry::Core::Container.new
container.register(:redis) { "Redis instance" }

container[:redis] # => "Redis instance"

require 'dry/container/stub'

# before stub you need to enable stubs for specific container
container.enable_stubs!
container.stub(:redis, "Stubbed redis instance")

container[:redis] # => "Stubbed redis instance"
```

Also, you can unstub container:

```ruby
container = Dry::Core::Container.new
container.register(:redis) { "Redis instance" }
container[:redis] # => "Redis instance"

require 'dry/container/stub'
container.enable_stubs!

container.stub(:redis, "Stubbed redis instance")
container[:redis] # => "Stubbed redis instance"

container.unstub(:redis) # => "Redis instance"
```

To clear all stubs at once, call `#unstub` without any arguments:

```ruby
container = Dry::Core::Container.new
container.register(:redis) { "Redis instance" }
container.register(:db) { "DB instance" }

require 'dry/container/stub'
container.enable_stubs!
container.stub(:redis, "Stubbed redis instance")
container.stub(:db, "Stubbed DB instance")

container.unstub # This will unstub all previously stubbed keys

container[:redis] # => "Redis instance"
container[:db] # => "Redis instance"
```
