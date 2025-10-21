---
title: Announcing dry-view, a functional view rendering system for Ruby
date: 2017-01-30 12:00 UTC
author: Tim Riley
---

Say hello to **dry-view**, the newest member of the dry-rb family!

We’re pleased to announce the release of dry-view 0.2.1 and share its [brand new documentation](/gems/dry-view).

Keen followers of dry-rb will note that dry-view has been around for a little while now, living on quietly as an extension of solnic’s original rodakase experiment.

With today’s release, dry-view sees major feature upgrades and usability improvements, making it ready for integration with your apps.

dry-view is a simple, standalone view rendering system for Ruby. It brings the “functional object” paradigm to the view layer, allowing your views to act as stateless transformations, accepting user input and returning your rendered view.

You should consider dry-view if:

- You want to develop views that will work in any kind of context (dry-view is standalone, it doesn’t require an HTTP request!).
- You’re using a lightweight routing DSL like Roda or Sinatra and you want to keep your routes clean and easy to understand (dry-view handles the integration with your application’s objects, all you need to provide from your routes is the user input data).
- Your application uses dependency injection as its preferred approach to make objects available to each other (dry-view fits perfectly with dry-web and [dry-system](/gems/dry-system)).

dry-view is built around pairings of functional view controllers and view templates. To get started, build a view controller:

```ruby
require "dry-view"
require "slim"

class HelloView < Dry::View::Controller
  configure do |config|
    config.paths = [File.join(__dir__, "templates")]
    config.layout = "application"
    config.template = "hello"
  end

  expose :greeting
end
```

Write a layout (e.g. `templates/layouts/application.html.slim`):

```slim
html
  body
    == yield
```

And your template (e.g. `templates/hello.html.slim`)

```slim
h1 Hello!

p = greeting
```

Then `#call` your view controller to render your view:

```ruby
view = HelloView.new
view.(greeting: "Hello from dry-rb!")
# => "<html><body><h1>Hello!</h1><p>Hello from dry-rb!</p></body></html>
```

That’s the simple example. Here’s what a real working view controller looks like in a dry-web-roda app, complete with auto-injection, multiple exposures, and view object decorators:

```ruby
require "main/import"
require "main/view_controller"
require "main/decorators/public_post"

module Main
  module Views
    module Posts
      class Index < Main::ViewController
        include Main::Import[repo: "persistence.repositories.posts"]

        configure do |config|
          config.template = "posts/index"
        end

        expose :featured_post do
          post = repo.featured_post
          Decorators::PublicPost.decorate(post)
        end

        expose :posts do |input|
          posts = repo.listing(page: input.fetch(:page), per_page: input.fetch(:per_page))
          Decorators::PublicPost.decorate(posts)
        end
      end
    end
  end
end
```

Interested? [Head over to the documentation to learn more](/gems/dry-view). We think you’ll find it both powerful and flexible, but also fun and easy to use.
