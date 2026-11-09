---
title: Middleware
---

## hanami middleware

Displays the Rack middleware stack as currently configured.

```shell
$ bundle exec hanami middleware

/    Dry::Monitor::Rack::Middleware (instance)
/    Hanami::Middleware::RenderErrors
/    Hanami::Webconsole::Middleware
/    Rack::MethodOverride
/    Rack::Session::Cookie
```

This command accepts a `--with-arguments` option that will include initialization arguments:

```shell
$ bundle exec hanami middleware --with-arguments

/    Dry::Monitor::Rack::Middleware (instance) args: []
/    Hanami::Middleware::RenderErrors args: [#<Hanami::Config ...>, #<Hanami::Middleware::PublicErrorsApp ...>]
/    Hanami::Webconsole::Middleware args: [#<Hanami::Config ...>]
/    Rack::MethodOverride args: []
/    Rack::Session::Cookie args: [{key: "my_app.session", secret: "secret", expire_after: 31536000}]
```
