---
title: Introduction
pages:
  - basic-usage
  - how-does-it-work
  - injection-strategies
---

dry-auto_inject provides low-impact dependency injection and resolution support for your classes.

It’s designed to work with a container that holds your application’s dependencies. It works well with [`Dry::Core::Container`](//org_guide/dry/dry-core/container), but supports any container that responds to the `#[]` interface. [Dry System's containers](//org_guide/dry/dry-system/container) are already integrated with dry-auto_inject.

### Why use dry-auto_inject?

Splitting your application’s behavior into smaller, more focused units makes for logic that is easier to understand, test, and refactor. Dependency injection is what then allows you to combine these small units to create more sophisticated behavior.

By using a container and dry-auto_inject, this process becomes easy. You don’t need to worry about building constructors or accessors, and adding extra dependencies is as easy as adding a string to a list.

### Usage example

```ruby
# Set up a custom container
class MyContainer
  def self.[](name)
    case name
    when "users_repository"
      UsersRepository.new
    when "operations.create_user"
      CreateUser.new
    end
  end
end

# Set up your auto-injection mixin
Import = Dry::AutoInject(MyContainer)

class CreateUser
  include Import["users_repository"]

  def call(user_attrs)
    users_repository.create(user_attrs)
  end
end

create_user = MyContainer["operations.create_user"]
create_user.call(name: "Jane")
```
