---
title: Announcing Hanami v2.0.0.beta1
date: 2022-07-20 07:54:53 UTC
tags: announcements
author: Luca Guidi
image: true
org: hanami
excerpt: >
  Hanami 2 first beta: app-centric revolution & CLI. What to expect in 2.0 and 2.1.
---

Hello Hanami community! We’re thrilled to announce the release of Hanami 2.0.0.beta1!

## App-centric revolution

With this release, we’ve revolutionized the Hanami app structure: the **`app/` directory is the primary home for your code**, and **slices are now optional**.

“What's a slice?,” you may ask! Think of slices as distinct modules of your application. A typical case is to use slices to separate your business domains (e.g. billing, accounting, admin). For our earlier 2.0 alpha releases, slices were the only way to build Hanami apps, which presupposed you wanted a full modular monolith composed of multiple domains.

With this change, you can just as easily build small services with Hanami, with minimal ceremony.

Let’s dissect a newly generated application (this one being named “Bookshelf”):

- `app/` is home for your application code
- `app/actions/` holds your actions and `app/action.rb`, with `Bookshelf::Action` as their superclass
- `config/app.rb` defines your application (`Bookshelf::App`) and its configuration
- `config/settings.rb` defines your app’s settings, such as the database URL
- `config/routes.rb` defines your app’s HTTP routes
- `lib/` is the home for any general purpose code used by your application code
- `lib/bookshelf/types.rb` defines your custom Ruby data types (using the dry-types gem)
- `lib/tasks/` is there for any custom Rake tasks
- `spec/` holds your tests (using RSpec)
- `spec/requests/` holds your HTTP integration tests (using the rack-test gem)

```
⚡ tree .
.
├── Gemfile
├── Gemfile.lock
├── README.md
├── Rakefile
├── app
│   ├── action.rb
│   └── actions
├── config
│   ├── app.rb
│   ├── routes.rb
│   └── settings.rb
├── config.ru
├── lib
│   ├── bookshelf
│   │   └── types.rb
│   └── tasks
└── spec
    ├── requests
    │   └── root_spec.rb
    ├── spec_helper.rb
    └── support
        ├── requests.rb
        └── rspec.rb

9 directories, 14 files
```

**Simple. In the spirit of Hanami.**

## CLI

This first beta comes with new CLI commands:

- `hanami new` to generate a new application
- `hanami server` to start the HTTP server (Puma)
- `hanami routes` to print application routes

Remember, `hanami --help`, is also your friend 😉.

## Hanami 2.0 & 2.1

Some of you may have noticed in the previous section we didn't mention views. Where have the views gone?

We want to release Hanami 2 stable as soon as possible, so we decided to split the remaining scope across Hanami 2.0 and 2.1 releases.

### Hanami 2.0

The roadmap until 2.0 is straightforward: solidify the app structure as presented above. We plan to add more commands to CLI code generators, support code reloading, and write documentation.

That's it!

This way you can learn Hanami 2 by building apps (hint: this would be great for API apps, the router is _really_ fast).

### Hanami 2.1

For this release, things will look complete from a full stack web framework perspective. Hanami apps will support views, helpers, assets, and persistence (based on [rom-rb](https://hanakai.org/rom)).

## What’s included?

Today we’re releasing the following gems:

- `hanami` v2.0.0.beta1
- `hanami-rspec` v3.11.0.beta1 (it follows RSpec’s versioning)
- `hanami-cli` v2.0.0.beta1
- `hanami-controller` v2.0.0.beta1
- `hanami-router` v2.0.0.beta1
- `hanami-validations` v2.0.0.beta1
- `hanami-utils` v2.0.0.beta1

For specific changes from the last alpha release, please see each gem’s own CHANGELOG.

## How can I try it?

```
⚡ gem install hanami --pre
⚡ hanami new bookshelf
⚡ cd bookshelf
⚡ bundle exec hanami --help
```

## Contributors

Thank you to these fine people for contributing to this release!

- [Andrew Croome](https://github.com/andrewcroome)
- [Benjamin Klotz](https://github.com/tak1n)
- [Luca Guidi](https://github.com/jodosha)
- [Marc Busqué](https://github.com/waiting-for-dev)
- [Narinda Reeders](https://github.com/narinda)
- [Peter Solnica](https://github.com/solnic)
- [Tim Riley](https://github.com/timriley)

## Thank you

Thank you as always for supporting Hanami!

We can’t wait to hear from you about this release, and we’re looking forward to checking in with you again soon. 🌸
