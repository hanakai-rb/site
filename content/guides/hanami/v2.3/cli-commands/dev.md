---
title: Dev
---

## hanami dev

Starts Hanami application in development mode.

    $ bundle exec hanami dev

### Procfile.dev

Starting from Hanami 2.1, new apps have a `Procfile.dev`, where developers can manage the processes that should be managed by `hanami dev`.

Those are the default contents:

    web: bundle exec hanami server
    assets: bundle exec hanami assets watch

### bin/dev

By default Hanami 2.1+, installs the `foreman` Ruby gem to run the `Procfile.dev`.

In case you want use a different process manager, edit application’s `bin/dev`.

Example that uses [shoreman](https://github.com/chrismytton/shoreman), instead of `foreman`:

    #!/usr/bin/env sh
    shoreman Procfile.dev

