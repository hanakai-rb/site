---
title: Introducing dry-effects
date: 2019-10-03 12:00 UTC
author: Nikita Shilnikov
---

Today we're introducing another gem and supercharging our toolset: say hello to dry-effects!

dry-effects is an implementation of algebraic effects in Ruby. Sound scary? Fear not! After a few examples, it'll feel very natural and compelling.

## Struggling with side effects

Writing purely functional code can be an attractive idea; it makes your code robust, testable, ... and useless! Indeed, if code doesn't perform any side effects, such as reading/writing data to the disc or network communications, the only thing it actually does is heating the CPU. On the other hand, side effects remove determinism from the code, making testing challenging. Here come algebraic effects, the underlying theory powering dry-effects.

## Understanding effects

There are two main parts to effects and effectful systems:

1. Replace side effects with effects. These two are not the same, they are not even similar. Side effects are by definition not expected by the calling code. One cannot say if there are side effects judging by the interface. On the contrary, effects are explicitly included in interfaces; they _are expected_.
1. Running code with effects requires handling. This must be done explicitly, so that effects don't propagate straight to the outside world.

These two things combined give you full control over effects in your application.

## Taming effects with dry-effects

dry-effects uses mixins for making (or introducing) and handling (or eliminating) effects.

For example, this code uses the effect of getting the current time:

```ruby
class CreateSubscription
  include Dry::Effects.CurrentTime

  def call(values)
    subscription_repo.create(values.merge(start_at: current_time))
  end
end
```

To run it, there must be a handler:

```ruby
# Rack middleware is a perfect example of a place
# where effects can be handled.

class WithCurrentTime
  include Dry::Effects::Handler.CurrentTime

  def initialize(app)
    @app = app
  end

  def call(env)
    with_current_time { @app.(env) }
  end
end
```

So how is this better than `Time.now`? You get testable code for free. An RSpec example:

```ruby
include Dry::Effects::Handler.CurrentTime

subject(:create_subscription) { CreateSubscription.new }

example "creating subscription on New Year's Eve" do
  with_current_time(proc { Time.new(2019, 12, 31, 12) }) do
    create_subscription.(...)
  end
end
```

Why would you use dry-effects for this instead of specialized solutions? Because it provides a universal interface to all effects, it's not limited to Ruby. For instance, getting the current time in React would look very similar:

```javascript
const CurrentTime = () => {
  const currentTime = useCurrentTime();

  return (
    <div className="current-time">
      {currentTime.getHours()}:{currentTime.getMinutes()}
    </div>
  );
};
```

Yes, React relies on algebraic effects under the hood; maybe you already use them!

## What else?

dry-effects v0.1 is already out and comes with quite a few effects supported out of the box. Some of them are “classic” and some are experimental, 17 in total.

Here are some:

- Accessing current time
- Providing context
- Sharing state
- Providing environment (as opposed to accessing and manipulating `ENV`)
- Caching
- Locking
- Deferred and parallel code execution

One of the most compelling examples is dependency injection:

```ruby
class CreateUser
  include Dry::Effects.Resolve(:user_repo)

  def call(values)
    user_repo.create(values)
  end
end
```

Here `CreateUser` is not linked to a dependency resolution implementation in any way. To provide the dependency, add a handler:

```ruby
include Dry::Effects::Handler.Resolve

subject(:create_user) { CreateUser.new }

let(:user_repo) { double(:user_repo, create: ...) }

example 'creating a user' do
  provide(user_repo: user_repo) do
    create_user.(...)
  end
end
```

You can provide multiple dependencies:

```ruby
provide(user_repo: user_repo, post_repo: post_repo) { ... }
```

Handlers are also composable, you can nest them:

```ruby
provide(user_repo: user_repo) { provide(post_repo: post_repo) { ... } }
```

This is not limited to handlers of the same type:

```ruby
provide(user_repo: user_repo) { with_current_time { ... } }
```

Generally, effects and handlers work just the way you would expect; this is the most appealing thing about them (judging from experience!).

## Why dry-effects?

These are early days for algebraic effects. We believe they have a prominent future. The concept comes from the functional world and, since dry-rb heavily leans toward functional programming, it perfectly fits our ecosystem. There is no existing production-ready library for Ruby, that's why we've built our own.

This post has mostly demonstrated using effects in application code, but they can be as easily used in libraries, providing a new level of flexibility to the users. This part is yet to be explored.

## With infinite power comes infinite responsibility

Algebraic effects are quite new, and as a community we have zero to little experience in using them. They may help you with writing clean, decoupled, and testable code, but they can also turn your app into unmaintainable mess, drop your database, and burn your house, so please be careful!

As we gather experience, together we'll figure out what's good and what's bad. So please try it, and share what you learn with others!

## Dive in!

The first version of dry-effects is already on [RubyGems.org](https://rubygems.org/gems/dry-effects), go grab it. We have [docs](https://dry-rb.org/gems/dry-effects/0.1) for most effects and specs for all of them. As always, share your experience and ask your questions in our [chat](https://dry-rb.zulipchat.com) and at our [forum](https://discourse.dry-rb.org/).
