---
title: Parameters
---

The parameters associated with an incoming request are available via `request.params` within the action's `#handle` method.

```ruby
module Bookshelf
  module Actions
    module Books
      class Show < Bookshelf::Action
        def handle(request, response)
          request.params[:id]
        end
      end
    end
  end
end
```

## Parameter sources

Parameters for a request come from a number of sources:

- [path variables](//guide/routing) as specified in the route that has matched the request (e.g. `/books/:id`)
- the request's query string (e.g. `/books?page=2&per_page=10`)
- the request's body (for example the JSON-formatted body of a `POST` request with an `application/json` content type).

```ruby
def handle(request, response)
  # GET /books/1
  request.params[:id] # => "1"

  # GET /books?category=history&page=2
  request.params[:category] # => "history"
  request.params[:page] # => "2"

  # POST /books '{"title": "request body", "author":"json"}', Content-Type application/json
  request.params[:title] # => "request body"
  request.params[:author] #=> "json"
end
```

## Accessing parameters

Request parameters are referenced by symbols.

```ruby
request.params[:q]
request.params[:book][:title]
```

Nested parameters can be safely accessed via the `#dig` method on the `params` object. This method accepts a list of symbols, where each symbol represents a level in our nested structure. If the `:book` param above is missing from the request, using `#dig` avoids a `NoMethodError` when attempting to access `:title`.

```ruby
request.params.dig(:book, :title)             # => "Hanami"
request.params.dig(:deeply, :nested, :param)  # => nil instead of NoMethodError
```

## Malformed requests

If Hanami can't read a request's params, your action returns `400 Bad Request` and doesn't call your `#handle` method. This happens when:

- a JSON body isn't valid JSON
- a multipart body can't be read
- a query string or form body has conflicting param types, such as `?a=1&a[b]=2`
- a query string or form body has invalid percent-encoding
- the params are over Rack's limits: too many, nested too deeply, or too large
- a param name isn't valid UTF-8 (only for actions without a params schema or contract)

In these cases, Hanami raises `Hanami::Action::BodyParsingError` or `Hanami::Action::ParamsParsingError`. To send a different response, handle both exceptions with `handle_exception`:

```ruby
# app/action.rb

module Bookshelf
  class Action < Hanami::Action
    handle_exception(
      Hanami::Action::BodyParsingError => :handle_bad_request,
      Hanami::Action::ParamsParsingError => :handle_bad_request
    )

    private

    def handle_bad_request(request, response, exception)
      response.status = 400
      response.format = :json
      response.body = {error: "We couldn't read your request"}.to_json
    end
  end
end
```

See [Exception handling](//page/exception-handling) for more on `handle_exception`.

## Parameter validation

The parameters associated with a web request are untrusted input.

In Hanami actions, params can be validated using a schema specified using a `params` block.

This validation serves several purposes, including allowlisting (ensuring that only allowable params are extracted from a request) and coercion (converting string parameters to boolean, integer, time and other types).

Let's take a look at a books index action that accepts two parameters, `page` and `per_page`.

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        params do
          optional(:page).value(:integer)
          optional(:per_page).value(:integer)
        end

        def handle(request, response)
          request.params[:page]
          request.params[:per_page]
        end
      end
    end
  end
end
```

The schema in the params block specifies the following:

- `page` and `per_page` are both optional parameters
- if `page` is present, it must be an integer
- if `per_page` is present, it must be an integer

With this schema in place, a request with a query string of `/books?page=1&per_page=10` will result in:

```ruby
request.params[:page] # => 1
request.params[:per_page] # => 10
```

Notice that thanks to the defined params schema with types, `"1"` and `"10"` are coerced to their integer representations `1` and `10`.

Additional rules can be added to apply further constraints. The following params block specifies that, when present, `page` and `per_page` must be greater than or equal to 1, and also that `per_page` must be less than or equal to 100.

```ruby
params do
  optional(:page).value(:integer, gteq?: 1)
  optional(:per_page).value(:integer, gteq?: 1, lteq?: 100)
end
```

Importantly, now that our params schema is doing more than just type coercion, we need to explicitly check for and handle our parameters being invalid.

The `#valid?` method on the params allows the action to check the parameters in order halt and return a `422 Unprocessable` response.

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        params do
          optional(:page).value(:integer, gteq?: 1)
          optional(:per_page).value(:integer, gteq?: 1, lteq?: 100)
        end

        def handle(request, response)
          halt 422 unless request.params.valid?

          # At this point, we know the params are valid
          request.params[:page]
          request.params[:per_page]
        end
      end
    end
  end
end
```

Here's a further example, this time for an action to create a user.

```ruby
# app/actions/users/create.rb

module Bookshelf
  module Actions
    module Users
      class Create < Bookshelf::Action
        params do
          required(:email).filled(:string)
          required(:password).filled(:string)

          required(:address).hash do
            required(:street).filled(:string)
            required(:country).filled(:string)
          end
        end

        def handle(request, response)
          halt 422 unless request.params.valid?

          request.params[:email]             # => "alice@example.org"
          request.params[:password]          # => "secret"
          request.params[:address][:country] # => "Italy"

          request.params[:admin]             # => nil
        end
      end
    end
  end
end
```

The `params` block in this action specifies that:

- `email`, `password` and `address` parameters are required to be present.
- `address` has `street` and `country` as nested parameters, which are also required.
- `email`, `password`, `street` and `country` must be filled (non-blank) strings.

The errors associated with a failed parameter validation are available via `request.params.errors`.

Assuming that the users create action was part of a JSON API, we could render these errors by passing a body when calling `halt`:

```ruby
halt 422, {errors: request.params.errors}.to_json unless request.params.valid?
```

For an empty `POST` request with an empty address object, this action would render:

```json
{
  "errors": {
    "email": ["is missing"],
    "password": ["is missing"],
    "address": {
      "street": ["is missing"],
      "country": ["is missing"]
    }
  }
}
```

Action validations use the [dry-validation](//org_guide/dry/dry-validation) gem, which provides a powerful DSL for defining schemas.

Consult the [dry-validation](//org_guide/dry/dry-validation) and [dry-schema](//org_guide/dry/dry-schema) gems for further documentation.

## Translating validation messages

If your app bundles the i18n gem, Hanami translates your validation error messages using your slice's translations. Add your messages under the `dry_validation.errors` key in your translation files.

Hanami validates params before your action's `before` callbacks run. If you set the locale for each request, set it before the action is called, such as in a [Rack middleware](//page/rack-integration#rack-middleware).

See [Translating validation messages](//guide/i18n#translating-validation-messages) for details.

## Using concrete classes

In addition to specifying parameter validations "inline" in a `params` block, actions can also hand over their validation responsibilities to a separate class.

This makes action validations reusable and easier to test independently of the action.

To do this, define a `Dry::Validation::Contract` with a `params` block:

```ruby
# app/actions/users/create_contract.rb

module Bookshelf
  module Actions
    module Users
      class CreateContract < Dry::Validation::Contract
        params do
          required(:email).filled(:string)
          required(:password).filled(:string)

          required(:address).hash do
            required(:street).filled(:string)
            required(:country).filled(:string)
          end
        end
      end
    end
  end
end
```

Then pass the contract class to `params`:

```ruby
# app/actions/users/create.rb

module Bookshelf
  module Actions
    module Users
      class Create < Bookshelf::Action
        params CreateContract

        def handle(request, response)
          # ...
        end
      end
    end
  end
end
```

## Validations at the HTTP layer

Validating parameters in actions is useful for validating parameter structure, performing parameter coercion and type validations.

More complex domain-specific validations, or validations concerned with things such as uniqueness, however, are usually better performed at layers deeper than your HTTP actions.

For example, verifying that an email address has been provided is something an action parameter validation should reasonably do, but checking that a user with that email address doesn't already exist is unlikely to be a good responsibility for an HTTP action to have. That validation might instead be performed by a create user operation, which can perform a check against a user store.

## Body parsers

Hanami automatically parses request bodies for requests with the following content types:

- `multipart/form-data` (form submissions with file attachments)
- `application/json` (JSON requests)
- `application/vnd.api+json` (JSON API requests)

If you need to parse different body types, you can declare a new body parser:

```ruby
# lib/foo_parser.rb
class FooParser
  def self.media_types = ["application/foo"]

  def parse(body)
    # Your parsing logic here
  end
end
```

Register that body parser directly and it will parse its own declared media types:

```ruby
# config/app.rb

class App < Hanami::App
  config.middleware.use :body_parser, FooParser
end
```

You can also register a body parser to work on additional media types:

```ruby
config.middleware.use :body_parser, [FooParser: ["application/x-foo"]]
```

This is particularly useful if you need to activate Hanami's standard JSON parsing for additional content types:

```ruby
config.middleware.use :body_parser, [json: ["application/scim+json"]]
```
