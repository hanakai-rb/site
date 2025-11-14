---
title: "Building a web app"
---

Now that we've [created our app](//getting-started), let's turn it into a web app.

## Adding our first functionality

Let's take a look at Hanami by creating the beginnings of a bookshelf app.

We'll start by creating a home page that displays "Welcome to Bookshelf".

First, let's open our app's routes file at `config/routes.rb`:

```ruby
# config/routes.rb

module Bookshelf
  class Routes < Hanami::Routes
    # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  end
end
```

Let's add a route for our home page that invokes a new action:

```ruby
# config/routes.rb

module Bookshelf
  class Routes < Hanami::Routes
    root to: "home.index"
  end
end
```

Hanami provides an action generator we can use to create this action:

```bash
$ bin/hanami generate action home.index --skip-route --skip-tests
```

We can find this action in our `app` directory at `app/actions/home/index.rb`:

```ruby
# app/actions/home/index.rb

module Bookshelf
  module Actions
    module Home
      class Index < Bookshelf::Action
        def handle(request, response)
        end
      end
    end
  end
end
```

We can find this view's template at `app/templates/home/index.html.erb`. Let's adjust this template to include our desired "Welcome to Bookshelf" text:

```erb
<!-- app/templates/home/index.html.erb -->

<h1>Welcome to Bookshelf</h1>
```

### Seeing your changes

Run the following command to start the server:

```bash
$ bin/hanami dev
```

Visit [http://localhost:2300](http://localhost:2300) and you should see your "Welcome to Bookshelf" heading.
