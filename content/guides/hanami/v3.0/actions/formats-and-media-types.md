---
title: Formats and media types
---

Hanami maps [over 50 of the most common media types][built-in-formats] to simple **format** names for you to use when configuring your actions.

[built-in-formats]: https://github.com/hanami/controller/blob/dc5bb2a1db48b0ccf3faf52aac20eaef0fd135a3/lib/hanami/action/mime.rb#L15-L69

Accepting one or more formats from your actions will:

- Ensure the actions accept only appropriate requests based on their `Accept` or `Content-Type` headers.
- Set an appropriate `Content-Type` header on responses.

## Accepting a format for all actions

To accept a format for all actions, use `config.actions.format.accept` in your app class.

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.formats.accept :json
  end
end
```

You can also configure actions to accept multiple formats:

```ruby
config.actions.formats.accept :json, :html
```

## Accepting a format for particular actions

You can also accept formats on any individual action class. `config.formats` in an action class is
analogous to `config.actions.formats` in your app class.

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        config.formats.accept :json

        def handle(request, response)
          # ...
        end
      end
    end
  end
end
```

If you accept a format on a base action class, then it will be inherited by all its subclasses.

```ruby
# app/action.rb

module Bookshelf
  class Action < Hanami::Action
    config.formats.accept :json
  end
end
```

## Request acceptance

Once you accept a format, your actions will reject requests that do not match the format.

The following kinds of requests will be accepted:

- No `Accept` or `Content-Type` headers
- `Accept` header that includes the format's media type
- No `Accept` header, but a `Content-Type` header that matches the format's media type

Whereas these kinds of requests will be rejected:

- `Accept` does not include the format's media type, rejected as `406 Not acceptable`
- No `Accept` header, but a `Content-Type` header is present and does not match the format's media type, rejected as `415 Unsupported media type`

For example, if you configure `formats.accept :json`, then requests with these headers will be accepted:

- `Accept: application/json`
- `Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"` (courtesy of the `*/*`)
- `Content-Type: application/json`

While requests with these headers will be rejected:

- `Accept: text/html`
- `Accept: text/html,application/xhtml+xml,application/xml;q=0.9`
- `Content-Type: application/x-www-form-urlencoded`

## Response format

Actions set a default `Content-Type` response header based on your accepted formats along with the media type and charset of the incoming request.

For example, if a request's `Accept` header is `"text/html,application/xhtml+xml,application/xml;q=0.9"`, the action will return a content type of `"text/html; charset=utf-8"`, assuming that the action accepts the `:html` format.

You can also assign a particular format directly on the response inside your action.

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        def handle(request, response)
          response.format = :json # or response.format = "application/json"
          response.body = {result: "OK"}.to_json
        end
      end
    end
  end
end
```

## Responding to multiple formats

When an action accepts more than one format, the response format is negotiated from the request's `Accept` header before `#handle` runs, and made available on `response.format`. Inside your action, you can branch on it with a `case` expression to prepare a response appropriate to the negotiated format.

```ruby
# app/actions/users/show.rb

module Bookshelf
  module Actions
    module Users
      class Show < Bookshelf::Action
        config.formats.accept :json, :html

        def handle(request, response)
          user = users.get(request.params[:id])

          case response.format
          when :json then response.body = user.to_json
          when :html then response.render(view, user: user)
          end
        end
      end
    end
  end
end
```

Because your action has already rejected anything it doesn't accept, `response.format` is guaranteed to be one of your accepted formats. Your `case` expression only needs to handle those.

## Default character set

Alongside its media type, your response's `Content-Type` header includes a character set, which defaults to `utf-8`:

```text
Content-Type: application/json; charset=utf-8
```

You can configure this app-wide or on a per-action basis.

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.default_charset = "koi8-r"
  end
end
```

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        config.default_charset = "koi8-r"
      end
    end
  end
end
```

## Registering additional formats and media types

If you need your actions to work with additional media types, you can configure these like so:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.formats.register :custom, "application/custom"
  end
end
```

This will register the `:custom` format for the `"application/custom"` media type. Your actions can then accept this format, either at the app-level, or within specific action classes:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.formats.register :custom, "application/custom"
    config.actions.formats.accept :custom
  end
end
```

```ruby
# app/action.rb

module Bookshelf
  class Action < Hanami::Action
    config.formats.accept :custom
  end
end
```

You can also configure a format to map to multiple media types, via the `accept_types:` and `content_types:` options. These determine the media types matched against the request's `Accept` and `Content-Type` headers respectively:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.formats.register(
      :json,
      "application/json",
      accept_types: ["application/json", "application/json+scim"],
      content_types: ["application/json", "application/json+scim"]
    )
  end
end
```

In this case, requests for both these media types will be accepted.

## Parsing request bodies

When an action accepts a format, it parses matching request bodies for you, merging the data into the request's params alongside any route and query string params. A body is parsed only when its `Content-Type` matches one of the formats the action accepts, so to have JSON bodies parsed, for example, your action must accept `:json`.

Hanami includes two body parsers out of the box:

- **JSON**, for the `application/json` and `application/vnd.api+json` media types.
- **Multipart forms**, for the `multipart/form-data` media type (used for file uploads).

For example, an action that accepts `:json` will parse a JSON request body and expose its data via `request.params`:

```ruby
# app/actions/books/create.rb

module Bookshelf
  module Actions
    module Books
      class Create < Bookshelf::Action
        config.formats.accept :json

        def handle(request, response)
          # For a request body of {"title": "Hanami"}
          request.params[:title] # => "Hanami"

          response.status = 201
        end
      end
    end
  end
end
```

String keys in the parsed body are symbolized, so you access them as symbols in your params. When the parsed body is not a hash (such as a top-level JSON array), it is made available under the `:_` key:

```ruby
# For a request body of [1, 2, 3]
request.params[:_] # => [1, 2, 3]
```

### Form submissions

Ordinary `application/x-www-form-urlencoded` form submissions are handled by Rack itself, so their params are always available regardless of your accepted formats.

`multipart/form-data` bodies (used for file uploads) are parsed automatically when an action accepts no formats, as a sensible default. Once an action accepts one or more formats, however, you must accept `:html` for multipart bodies to be parsed.

### Registering custom parsers

You can register a parser for any media type by passing a `parser:` to `formats.register` (see [Registering additional formats and media types](#registering-additional-formats-and-media-types) above). A parser is any callable that receives the request body (a string) and the Rack env, and returns the parsed data:

```ruby
# config/app.rb

module Bookshelf
  class App < Hanami::App
    config.actions.formats.register(
      :xml,
      "application/xml",
      parser: ->(body, env) { MyXMLParser.parse(body) }
    )
    config.actions.formats.accept :xml
  end
end
```

As with the built-in formats, your actions must accept the format for their request bodies to be parsed.

Your parser does not need to symbolize the keys in the data it returns. They're symbolized for you when the action builds the request's `params`.

If a parser cannot parse a body, it should raise `Hanami::Action::BodyParsingError`. You can handle this like any other exception in your actions:

```ruby
config.handle_exception Hanami::Action::BodyParsingError => :handle_bad_request

def handle_bad_request(request, response, exception)
  response.status = 400
  response.body = "Invalid request body"
end
```
