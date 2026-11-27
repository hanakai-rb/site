---
title: Request and response
---

When a Hanami action is called, the incoming HTTP request and outgoing HTTP response are represented by the `request` and `response` objects provided to the action's `#handle` method.

```ruby
module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        def handle(request, response)
        end
      end
    end
  end
end
```

## Request

The `request` object provides details about the incoming request. Use it to query information about the request, such as params and headers.

The object inherits from [Rack::Request](https://www.rubydoc.info/gems/rack/Rack/Request), which provides a range of methods like `#path_info`, `#content_type` and `#get_header`.

Here are some of the methods you can call on `request`:

```ruby
# app/actions/books/index.rb

module Bookshelf
  module Actions
    module Books
      class Index < Bookshelf::Action
        def handle(request, response)
          request.path_info                        # => "/books"
          request.subdomain                        # => "www"   (for a 1-element TLD)
          request.subdomains                       # => ["www"] (for a 1-element TLD)
          request.subdomain(2)                     # => "www"   (for a 2-element TLD)
          request.subdomains(2)                    # => ["www"] (for a 2-element TLD)
          request.request_method                   # => "GET"
          request.get?                             # => true
          request.post?                            # => false
          request.xhr?                             # => false
          request.referer                          # => "http://example.com/"
          request.user_agent                       # => "Mozilla/5.0 Macintosh; ..."
          request.ip                               # => "127.0.0.1"
          request.get_header("HTTP_AUTHORIZATION") # => "Basic abc123"
          request.env["HTTP_AUTHORIZATION"]        # => "Basic abc123"
        end
      end
    end
  end
end
```

You can also configure your app's TLD length (for accurate `#subdomains`) in your app class:

```ruby
config.actions.default_tld_length = 2 # for ".org.au" or similar
```

## Response

The `response` object represents your action's outgoing HTTP response.

Use it to control how your action responds to a request by setting an outgoing status, body or headers. You can also [stream a response](#streaming-responses) or [send a file](#sending-files).

```ruby
# app/actions/books/create.rb

module Bookshelf
  module Actions
    module Books
      class Create < Bookshelf::Action
        def handle(request, response)
          response.status = 201
          response.body = "Your resource has been created"
          response.headers["My-Header"] = "value"
          response.format = :json
        end
      end
    end
  end
end
```

The `response` object inherits from [Rack::Response](https://www.rubydoc.info/gems/rack/Rack/Response).

### Response status

By default, the response status is `200`. Setting the response status via `response.status` is useful when setting statuses like `200 OK`, `201 Created` and `404 Not Found`.

You may use the canonical symbolic name for a status instead of the integer, as defined in
`Hanami::Http::Status::SYMBOLS`. See [Status Codes](//page/status-codes) for the complete list.

In situations where you want an action to halt, for example to return a `401 Unauthorized` response, use the action's `halt` method. To return a redirect, use `response.redirect_to("/path")`. See [Control flow](//page/control-flow) for details.

### Response format

The value set using `response.format` can either be a format name (`:json`) or a content type string (`"application/json"`). Consult [Formats and media types](//page/formats-and-media-types) for more information about setting response formats.

### Response body

Set `response.body` to a string to send a buffered response. Any other object is turned into a string with `#to_s`.

Collections such as arrays and enumerators can't be buffered this way. Assigning an object that responds to `#each` raises a `Hanami::Action::InvalidBodyError`. To send a collection of string chunks, [stream it](#streaming-responses) instead.

### Streaming responses

To send a response in chunks instead of building it all in memory, use `response.stream`. Hanami passes the stream to the web server, which writes each chunk as it arrives.

Give `response.stream` a block. The block receives a writer, and you send each chunk with `<<` (or `#write`):

```ruby
# app/actions/books/export.rb

module Bookshelf
  module Actions
    module Books
      class Export < Bookshelf::Action
        include Deps["repos.book_repo"]

        def handle(request, response)
          response.format = :csv

          response.stream do |out|
            out << "title,author\n"

            book_repo.all_by_title.each do |book|
              out << "#{book.title},#{book.author}\n"
            end
          end
        end
      end
    end
  end
end
```

The block runs after your action returns, once the web server is ready to send the body. By this point the status and headers are already sent, so set them before you call `response.stream`.

You can also give `response.stream` an enumerable of chunks:

```ruby
response.stream(books.lazy.map { |book| "#{book.title}\n" })
```

If the enumerable responds to `#close` (such as a file or a database cursor), it's closed once the response is fully sent.

Every chunk must be a `String`. Turn your own objects into strings before you stream them.

By default, a streamed response has no `Content-Length` header, and the web server sends it with chunked transfer encoding. If you know the size of the response in bytes, give it as `length:`:

```ruby
response.stream(chunks, length: total_bytes)
```

`response.stream` makes a `Hanami::Action::Stream` and assigns it as the body. You can also make a stream yourself and assign it to `response.body`:

```ruby
response.body = Hanami::Action::Stream.new(chunks)
```

Once the body is a stream, you can't add to it with `response.write`. This raises a `Hanami::Action::InvalidBodyError`.

When you test an action that streams, read its body by iterating over the stream:

```ruby
response = action.call({})
response.body.each.to_a.join # => "title,author\n..."
```

### Sending files

To send a file as the response, use `response.send_file` with a path relative to your app's `public/` directory. Hanami sets the `Content-Type` and `Content-Length` headers, and responds with `404 Not Found` if the file doesn't exist. It also supports conditional `GET` requests (via `If-Modified-Since`) and range requests.

```ruby
def handle(request, response)
  response.send_file("reports/annual.pdf")
end
```

To send a file from anywhere on the file system, use `response.unsafe_send_file`. Relative paths resolve from your app's root. Take care never to pass it a path built from user input.

```ruby
response.unsafe_send_file("/var/data/exports/books.csv")
```

Both methods stream the file to the client, rather than reading the whole file into memory.
