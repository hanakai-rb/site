---
title: Filtering sensitive data
---

Your logs should not contain passwords, API keys, card numbers, or other sensitive data. Dry Logger's filters remove these values from your log payloads before they're written.

## Basic filtering

Use the `filters` option to list the keys to filter:

```ruby
logger = Dry.Logger(:my_app, filters: [:password, :api_key])

logger.info("User signup",
  email: "user@example.com",
  password: "secret123",
  api_key: "sk_live_1234567890"
)
# User signup email="user@example.com" password="[FILTERED]" api_key="[FILTERED]"
```

Filtered values are replaced with the string `"[FILTERED]"`.

## How filters match

Filters match when they appear anywhere in a key, regardless of case. Here, `:password` also filters `password_confirmation`, and `:token` filters both `auth_token` and `X-CSRF-Token`:

```ruby
logger = Dry.Logger(:my_app, filters: [:password, :token])

logger.info("Signup",
  password: "secret",
  password_confirmation: "secret",
  auth_token: "abc123",
  "X-CSRF-Token" => "def456"
)
# Signup password="[FILTERED]" password_confirmation="[FILTERED]" auth_token="[FILTERED]" X-CSRF-Token="[FILTERED]"
```

This means one filter can cover a whole family of keys. You don't need to list each variation.

Filters can be strings or symbols. Both are matched as plain text only. To match a pattern, use a [regexp filter](#regexp-filters).

## Nested data

Filters also apply to keys inside nested hashes:

```ruby
logger = Dry.Logger(:my_app, filters: [:password])

logger.info("User updated", user: {email: "user@example.com", password: "secret"})
# User updated user={email: "user@example.com", password: "[FILTERED]"}
```

To filter a key only when it's inside a given parent, join the keys with dots:

```ruby
logger = Dry.Logger(:my_app, filters: ["user.token"])

logger.info("Tokens",
  user: {token: "abc"},
  admin: {user: {token_hash: "def"}},
  token: "ghi"
)
# Tokens user={token: "[FILTERED]"} admin={user: {token_hash: "[FILTERED]"}} token="ghi"
```

A dotted filter is matched against each key's full dotted path, such as `admin.user.token_hash`. The top-level `token` is not filtered above because its path doesn't contain `user.token`.

### Filtering a whole hash

When a filter matches a key that holds a hash or an array, every value inside it is filtered. Their nested keys stay in place, so you can still see the shape of the data:

```ruby
logger = Dry.Logger(:my_app, filters: [:credentials])

logger.info("Connecting",
  credentials: {username: "jane", password: "secret", scopes: ["read", "write"]}
)
# Connecting credentials={username: "[FILTERED]", password: "[FILTERED]", scopes: ["[FILTERED]", "[FILTERED]"]}
```

## Arrays

Filters apply to hashes inside arrays:

```ruby
logger = Dry.Logger(:my_app, filters: [:password])

logger.info("Users imported", users: [
  {name: "Alice", password: "secret"},
  {name: "Bob", password: "hunter2"}
])
# Users imported users=[{name: "Alice", password: "[FILTERED]"}, {name: "Bob", password: "[FILTERED]"}]
```

The keys of these hashes use the array's key in their dotted path, with no index. This means `"users.password"` matches the `password` keys in the example above.

## Regexp filters

Because filters match parts of keys, a short filter can match more than you expect. For example, `:pin` also matches `shipping_address` and `pinned`:

```ruby
logger = Dry.Logger(:my_app, filters: [:pin])

logger.info("Order placed", pin: "1234", shipping_address: "1 Main St", pinned: true)
# Order placed pin="[FILTERED]" shipping_address="[FILTERED]" pinned="[FILTERED]"
```

For more control, use a `Regexp` filter. Add anchors to match a key exactly:

```ruby
logger = Dry.Logger(:my_app, filters: [/\Apin\z/])

logger.info("Order placed", pin: "1234", shipping_address: "1 Main St", pinned: true)
# Order placed pin="[FILTERED]" shipping_address="1 Main St" pinned=true
```

A regexp filter is matched against each key and against its full dotted path. In the example above, `/\Apin\z/` also matches a nested `user.pin` key. To match one exact path, anchor the full path, such as `/\Acard\.number\z/`. This matches `card.number`, but not `payment.card.number`.

Regexp filters ignore case, just like string filters. To make a regexp case-sensitive, use Ruby's inline `(?-i)` modifier:

```ruby
logger = Dry.Logger(:my_app, filters: [/(?-i)\APin\z/])

logger.info("Codes", "Pin" => "1234", "pin" => "5678")
# Codes Pin="[FILTERED]" pin="5678"
```

You can mix string, symbol, and regexp filters in the same list:

```ruby
logger = Dry.Logger(:my_app, filters: [:password, "user.email", /\Apin\z/])
```

## Per-backend filtering

Different backends can have different filters:

```ruby
logger = Dry.Logger(:my_app) do |setup|
  # Development logs: minimal filtering
  setup.add_backend(
    stream: $stdout,
    filters: [:password, :api_key]
  )

  # Production logs: aggressive filtering
  setup.add_backend(
    stream: "logs/production.log",
    formatter: :json,
    filters: [
      :password, :api_key, :token, :secret,
      :email, :phone, :address,
      :card, :cvv
    ]
  )
end
```

## Limitations

### Filters work on structured data only

Filters apply to the keys and values in your log payload. They don't apply to log messages, or to an exception's message and backtrace. Keep sensitive data out of these:

```ruby
# Don't do this: the password appears in the logs
raise "Failed to authenticate with password: #{password}"

# Do this instead: the password is filtered from the payload
logger.error("Failed to authenticate", password: password, error: "auth_failed")
```

### Filters apply inside hashes and arrays only

Filters look inside hashes and arrays, but not inside other objects, even ones that act like hashes. Convert these objects to hashes before you log them:

```ruby
Credentials = Struct.new(:username, :password)
credentials = Credentials.new("jane", "secret")

logger = Dry.Logger(:my_app, filters: [:password])

logger.info("Login", credentials: credentials)
# Login credentials=#<struct Credentials username="jane", password="secret">

logger.info("Login", credentials: credentials.to_h)
# Login credentials={username: "jane", password: "[FILTERED]"}
```
