---
title: Overview
---

## Routing

Hanami provides a fast, simple [router](https://github.com/hanami/router) for handling HTTP requests.

Your application's routes are defined within the `Routes` class in `config/routes.rb`

```ruby
module Bookshelf
  class Routes < Hanami::Routes
    root { "Hello from Hanami" }
  end
end
```

## Defining routes

<!-- TODO: Add `query` to this list once a released Rack defines Rack::QUERY. -->

Each route in Hanami's router is comprised of:

- a HTTP method (i.e. `get`, `post`, `put`, `patch`, `delete`, `options` or `trace`)
- a path
- an endpoint to be invoked.

Endpoints are usually actions within your application, but they can also be a block, a [Rack](https://github.com/rack/rack) application, or anything that responds to `#call`.

```ruby
get "/books", to: "books.index"  # Invokes the Bookshelf::Actions:Books::Index action
post "/books", to: "books.create" # Invokes the Bookshelf::Actions:Books::Create action
get "/rack-app", to: RackApp.new
get "/my-lambda", to: ->(env) { [200, {}, ["A Rack compatible response"]] }
```

## Resource routes

To define a full set of RESTful routes for a resource, use the `resources` or `resource` methods.

Use `resources` (plural) to generate a full set of RESTful routes for a collection resource:

```ruby
resources :books
```

This generates the following routes:

```
GET     /books          books.index
GET     /books/:id      books.show
GET     /books/new      books.new
POST    /books          books.create
GET     /books/:id/edit books.edit
PATCH   /books/:id      books.update
DELETE  /books/:id      books.destroy
```

Use `resource` (singular) for singleton resources that don't have an index action or ID:

```ruby
resource :profile
```

This generates the following routes:

```
GET     /profile        profile.show
GET     /profile/new    profile.new
POST    /profile        profile.create
GET     /profile/edit   profile.edit
PATCH   /profile        profile.update
DELETE  /profile        profile.destroy
```

To generate only specific actions, use the `only` option:

```ruby
resources :books, only: [:index, :show]
```

To exclude specific actions, use the `except` option:

```ruby
resources :books, except: [:destroy]
```

Customize the URL path using the `path` option:

```ruby
resources :comments, path: "reviews"
# Routes will use /reviews instead of /comments
```

Override the action namespace using the `to` option:

```ruby
resources :books, to: "library.books"
# Routes will invoke actions under library.books namespace
```

Customize route names using the `as` option:

```ruby
resources :books, as: :publications
```

Like the resource name, the `as` option goes through your app's inflector. The index and create routes use its plural form, and all other routes use its singular form:

```
GET     /books          books.index    as :publications
GET     /books/:id      books.show     as :publication
GET     /books/new      books.new      as :new_publication
GET     /books/:id/edit books.edit     as :edit_publication
```

If a resource name is uncountable (such as `news`), its plural and singular forms are the same. In this case, the index and create routes get an `_index` suffix, so that their name is different from the show route's name: `resources :news` gives `news_index` and `news`. To change how a name is inflected, add a custom inflection with `config.inflections` in your app.

Resources can be nested (to any level) to represent hierarchical relationships:

```ruby
resources :books do
  resources :reviews
end
```

This generates nested routes like `/books/:book_id/reviews`, with names like `book_reviews`.

The actions for nested resources are namespaced by any parent resources. In the above example, the reviews index route will have a `to:` of `"books.reviews.index"`.

The parent's ID param is named after the resource name (or its `as` option), not its `path`. For example, `resources :posts, path: "articles"` with nested `resources :comments` gives `/articles/:post_id/comments`.

Resources nested under a singular `resource` use its name as given. For example, `resource :settings` with nested `resources :items` gives route names like `settings_items`.

Basic routes can also be nested within resources. These routes apply to a single member of the resource, so their paths include the resource's ID as `:<name>_id`:

```ruby
resources :books do
  get "/preview", to: "books.preview"
end
```

This generates a route at `"/books/:book_id/preview"`.

To add routes for the resource's whole collection, use a `collection` block:

```ruby
resources :books do
  collection do
    get "/latest", to: "books.latest", as: :latest
  end
end
```

This generates a route at `"/books/latest"`, named `books_latest`.

To add routes for actions on a single member of the resource, use a `member` block. These routes receive the resource's ID as `:id`, the same as the resource's own `show` route:

```ruby
resources :books do
  member do
    post "/publish", to: "books.publish", as: :publish
  end
end
```

This generates a route at `"/books/:id/publish"`, named `book_publish`.

Use `member` for actions on the resource itself, such as publishing a book. For child resources with their own actions, such as a book's reviews, use `resources` or `resource` directly inside the `resources` block, so their actions receive the parent's ID as `:book_id`.

Route names in `collection` and `member` blocks start with the resource name. To put the route's own name first, like the `new_book` and `edit_book` routes, give `nil` as the second element of an `as` array:

```ruby
resources :books do
  member do
    post "/publish", to: "books.publish", as: [:publish, nil] # Named :publish_book
  end
end
```

You can use `collection` and `member` only directly inside a `resources` block.

## Root request routing

A `root` method allows you to define a root route for handling `GET` requests to `"/"`. In a newly generated application, the root path calls a block which returns "Hello from Hanami". You can instead choose to invoke an action by specifying `root to: "my_action"`. For example, with the following configuration, the router will invoke the `home` action:

```ruby
module Bookshelf
  class Routes < Hanami::Routes
    root to: "home"
  end
end
```

## Path matching

The path component of a route supports matching on fixed paths, as well as matching with dynamic path variables.

These variables can be accessed in Hanami actions via `request.params[:name]`, where `:name` matches the segment's name specified in the path.

## Fixed paths

The following fixed path route matches `GET` requests for `"/books"` exactly:

```ruby
get "/books", to: "books.index"
```

## Paths with variables

Path variables can be used for serving dynamic content. Path variables are defined with a colon followed by a name (for example `:id` or `:slug`). These variables can be accessed in Hanami actions via `request.params[:name]`.

The path `"/books/:id"` matches requests like `"/books/1"`:

```ruby
get "/books/:id", to: "books.show"

# GET /books/1
# request.params[:id] # => 1
```

Paths support multiple dynamic variables. For example, the path `"/books/:book_id/reviews/:id"` matches requests like `"/books/17/reviews/6"`:

```ruby
get "/books/:book_id/reviews/:id", to: "book_reviews.show"

# GET /books/17/reviews/6
# request.params[:book_id] # => 17
# request.params[:id] # => 6
```

Accessing these variables in a Hanami action looks like:

```ruby title="app/actions/book_reviews/show.rb"
# Request: GET /books/17/reviews/6

module Bookshelf
  module Actions
    module BookReviews
      class Show < Bookshelf::Action
        def handle(request, response)
          request.params[:book_id] # 17
          request.params[:id] # 6
        end
      end
    end
  end
end
```

## Constraints

Constraints can be added when matching variables. These are regular expressions that must match in order for the route to match. They can be useful for ensuring that ids are digits:

```ruby
get "/books/:id", id: /\d+/, to: "books.show"

# GET /books/2 # matches
# GET /books/two # does not match

get "/books/award-winners/:year", year: /\d{4}/, to: "books.award_winners.index"

# GET /books/award-winners/2022 # matches
# GET /books/award-winners/2 # does not match
# GET /books/award-winners/two-thousand # does not match
```

## Globbing and catch all routes

Catch all routes can be added using globbing. These routes can be used to handle requests that do not match any preceeding routes.

For example, in the absence of an earlier matching route, `"/pages/*match"` will match requests for paths like `"/pages/2022/my-page"`:

```ruby
get "/pages/*path", to: "page_catch_all"

# GET /pages/2022/my-page will invoke the Bookshelf::Actions::PageCatchAll action
# request.params[:path] # # => 2022/my-page
```

To create a catch all to handle all unmatched `GET` requests using a custom `"unmatched"` action, configure this route last:

```ruby
get "/*path", to: "unmatched"
```

## Named routes

Routes can be named using the `as` option.

```
get "/books", to: "books.index", as: :books
get "/books/:id", to: "books.show", as: :book
```

This enables `path` and `url` helpers, which can be accessed via the routes helper registered under `"routes"` within your application.

```ruby
Hanami.app["routes"].path(:books)
=> "/books"

Hanami.app["routes"].url(:books)
=> #<URI::HTTP http://0.0.0.0:2300/books>
```

When a route requires variables, they can be passed to the helper:

```ruby
Hanami.app["routes"].path(:book, id: 1)
=> "/books/1"
```

To set a base URL for the `url` helper, configure it in `config/app.rb`:

```ruby title="config/app.rb"
require "hanami"

module Bookshelf
  class App < Hanami::App
    config.base_url = "https://bookshelf.example.com"
  end
end
```

```ruby
Hanami.app["routes"].url(:book, id: 1)
=> #<URI::HTTP https://bookshelf.example.com/books/1>
```

## Scopes

To nest a series of routes under a particular namespace, you can use a scope:

```ruby
module Bookshelf
  class Routes < Hanami::Routes
    scope "about" do
      get "/contact-us", to: "content.contact", as: :contact # => /about/contact-us
      get "/faq", to: "content.faq", as: :faq # => /about/faq
    end
  end
end
```

Scopes supply a prefix to the names of their enclosed routes. The routes above are accessible as `path(:about_contact)` and `path(:about_faq)`.

Scopes can also include all the elements of regular routes. In this case, you can supply a friendlier name prefix with `as:`:

```ruby
module Bookshelf
  class Routes < Hanami::Routes
    scope "authors/:author_id", as: :author do
      resources :books, only: [:index, :show], to: "authors.books"
      get "/news", to: "authors.news", as: :news
    end
  end
end
```

This creates the following routes:

```
GET  /authors/:author_id/books      authors.books.index  :author_books
GET  /authors/:author_id/books/:id  authors.books.show   :author_book
GET  /authors/:author_id/news       authors.news         :author_news
```

If you need to create a route name with a prefix that _precedes_ a scope prefix, provide an array to `as:`. The scope prefix will be inserted after the first element.

```ruby
scope "authors/:author_id", as: :author do
  get "send-feedback", to: "authors.send_feedback", as: [:send, :feedback]
  # Will be named :send_author_feedback
end
```

## Redirects

Redirects can be added using `redirect_permanent`, which uses a `301` status code:

```ruby
redirect_permanent "/old", to: "/new"
```

For a temporary redirect with a `302` status code, use `redirect_temporary`:

```ruby
redirect_temporary "/old", to: "/temporary-new"
```

For any other redirect status code, use `redirect` and give the code via the `code` option:

```ruby
redirect "/old", to: "/new", code: 308
```

Redirects can be made to absolute URLs as well:

```ruby
redirect_permanent "/external", to: "https://hanamirb.org"
```

Non-HTTP protocols are also supported thanks to the URI class:

```ruby
redirect_permanent "/custom", to: URI("xmpp://myapp.net")
```

If you have many redirects or need to implement custom logic, you might consider using a Rack middleware.

## Inspecting routes

Hanami provides a `hanami routes` command to inspect your application's routes. Run `bundle exec hanami routes` on the command line to view current routes:

```shell
$ bundle exec hanami routes

GET     /                             home                          as :root
GET     /books                        books.index
GET     /books/:id                    books.show
GET     /books/new                    books.new
POST    /books                        books.create
GET     /books/:id/edit               books.edit
PATCH   /books/:id                    books.update
DELETE  /books/:id                    books.destroy
```

You can also read the routes in your own code. Call `#routes` on a slice's router to get a frozen array of its routes, in the order they were defined. This includes the `HEAD` route that Hanami adds for each `GET` route:

```ruby
routes = Hanami.app.router.routes

routes.first.http_method # => "GET"
routes.first.path # => "/"
```

To render the routes as text, give them to one of Hanami Router's formatters, `Hanami::Router::Formatter::HumanFriendly` or `Hanami::Router::Formatter::CSV`. The `hanami routes` command uses these same formatters:

```ruby
Hanami::Router::Formatter::HumanFriendly.new.call(Hanami.app.router.routes)
```
