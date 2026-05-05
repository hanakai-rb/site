---
title: Inheritance
---

Subclassing preserves all definitions being made inside a superclass.

```ruby
require 'dry-initializer'

class User
  extend Dry::Initializer

  param :name
end

class Employee < User
  param :position
end

employee = Employee.new('John', 'supercargo')
employee.name     # => 'John'
employee.position # => 'supercargo'

employee = Employee.new # => fails with 'wrong number of arguments (given 0, expected 2+)'
```

You can override params and options.
Overriding leaves the initial order of positional params unchanged:

```ruby
class Employee < User
  # Caution! defining :position before :name does not change the order of positional params
  param :position, default: proc { 'Manager' }
  param :name,     default: proc { 'Jerry' }
end

# Employee initializer still expects :name as the first positional argument
employee = Employee.new('John', 'supercargo')
employee.name     # => 'John'
employee.position # => 'supercargo'

user = User.new # => Boom! because User#name is still required
```
