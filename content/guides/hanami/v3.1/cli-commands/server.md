---
title: Server
---

## hanami server

Launches Hanami's development server for developing against your application locally.

<!-- TODO: Update the output below to show more recent versions -->

```shell
$ bundle exec hanami server

Puma starting in single mode...
* Puma version: 6.4.0 (ruby 3.2.3-p53) ("The Eagle of Durango")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 93401
* Listening on http://0.0.0.0:2300
* Starting control server on http://127.0.0.1:9293
* Starting control server on http://[::1]:9293
Use Ctrl-C to stop
```

**This server is for local development only**. In production, use the following to start your application serving web requests with Puma:

```shell
$ bundle exec puma -C config/puma.rb
```

<!-- TODO: Confirm how debuggers interact with reloading and document any gotchas here. -->

### Code reloading

In development, the server reloads your app whenever you change its code. The reload happens in place on the next request, so the server keeps running and you don't need to restart it after each change.

This feature is provided by the hanami-reloader gem. See the [code reloading guide](//guide/app/code-reloading) for more detail.

To disable code reloading, start the server with the `--no-code-reloading` option:

```shell
$ bundle exec hanami server --no-code-reloading
```

If you want to disable code reloading permanently, remove the gem from your app's `Gemfile`.
