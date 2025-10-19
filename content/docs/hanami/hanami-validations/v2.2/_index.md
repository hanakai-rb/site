---
title: Introduction & Usage
---

# Hanami::Validations

Internal support gem for `Hanami::Action` params validation.

## Installation

**Hanami::Validations** supports Ruby (MRI) 3.1+

Add this line to your application's Gemfile:

```ruby
gem "hanami-validations"
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install hanami-validations
```

## Usage

Installing hanami-validations enables support for `params` validation in
[hanami-controller][controller]'s `Hanami::Action` classes.

```ruby
class Signup < Hanami::Action
  params do
    required(:first_name)
    required(:last_name)
    required(:email)
  end

  def handle(req, *)
    puts req.params.class            # => Signup::Params
    puts req.params.class.superclass # => Hanami::Action::Params

    puts req.params[:first_name]     # => "Luca"
    puts req.params[:admin]          # => nil
  end
end
```

See [hanami-controller][controller] for more detail on params validation.

[controller]: http://github.com/hanami/controller
