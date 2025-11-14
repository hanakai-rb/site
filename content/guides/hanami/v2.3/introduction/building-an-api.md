---
title: "Building an API"
---

Now that we've [created our app](//page), let's turn it into an API.

## Adding our first functionality

Let's take a look at Hanami by creating the beginnings of a bookshelf app.

We'll start by creating a home endpoint that returns "Welcome to Bookshelf".

First, let's look at our app's routes file at `config/routes.rb`:

```ruby
# config/routes.rb

module Bookshelf
  class Routes < Hanami::Routes
    # Add your routes here. See https://guides.hanamirb.org/routing/overview/ for details.
  end
end
```

Let's add a route for our home endpoint that invokes a new action:

```ruby
# config/routes.rb

module Bookshelf
  class Routes < Hanami::Routes
    root to: "home.index"
  end
end
```

We can use Hanami's action generator to create this action:

```bash
$ bundle exec hanami generate action home.index --skip-view --skip-route --skip-tests
```

Let's adjust our home action to return our "Welcome to Bookshelf" message:

```ruby
# app/actions/home/index.rb

module Bookshelf
  module Actions
    module Home
      class Index < Bookshelf::Action
        def handle(request, response)
          response.body = "Welcome to Bookshelf"
        end
      end
    end
  end
end
```

### Testing your API

Run the development server:

```bash
$ bin/hanami dev
```

Test the endpoint:

```bash
$ curl http://localhost:2300
Welcome to Bookshelf
```
