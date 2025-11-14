---
title: Getting Started
pages:
  - building-a-web-app
  - building-an-api
---

Hello. If you're reading this page, it's likely you want to learn more about Hanami. This is great, and we're excited to have you here!

If you're looking for new ways to build maintainable, secure, faster and testable Ruby apps, you're in for a treat. **Hanami is built for people like you.**

Whether you're a total beginner or an experienced developer, **this learning process may still be hard**. Over time, we become used to certain things, and it can be painful to change. **But without change, there is no challenge** and without challenge, there is no growth.

In this guide we'll set up our first Hanami project and build a simple web app. We'll touch on all the major components of the Hanami framework, guided by tests at each stage.

**If you feel alone or frustrated, don't give up, jump into our [forum](https://discourse.hanamirb.org) and ask for help.** We and the rest of our community are putting in our best efforts to make Hanami better every day.

## Getting started

Hanami is a Ruby framework designed to create software that is well-architected, maintainable and a pleasure to work on.

These guides aim to introduce you to the Hanami framework and demonstrate how its components fit together to produce a coherent app.

Ideally, you already have some familiarity with web apps and the [Ruby language](https://www.ruby-lang.org/en/).

## Creating a Hanami app

### Prerequisites

To create a Hanami app, you will need Ruby 3.1 or greater. Check your ruby version:

```shell
$ ruby --version
```

If you need to install or upgrade Ruby, follow the instructions on [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

You also need Node.js installed, for front end assets. To confirm this, check that `npm` is available:

```shell
$ npm --version
```

If you need to install or upgrade Node.js, follow the instructions on [nodejs.org](https://nodejs.org/en/download).

### Installing the gem

In order to use Hanami, you need to install its gem:

```shell
$ gem install hanami
```

### Generating a new app

To generate a new Hanami app, use `hanami new`, followed by the name of your app:

```shell
$ hanami new bookshelf
```

This generates a new `bookshelf` directory containing a fresh Hanami app.

```shell
$ cd bookshelf
```

## Running your app

### Using hanami dev

Hanami provides a command for starting all necessary processes to run your app in development mode.

Start the development server:

```shell
$ bundle exec hanami dev
```

This starts a web server on port 2300. Visit it at [http://localhost:2300](http://localhost:2300).

You should see a welcome page confirming your app is running.

## Project structure

Here's a high level view of the structure of your new app:

```
bookshelf/
  app/
  config/
  lib/
  public/
  spec/
  Gemfile
  Rakefile
  config.ru
  package.json
```

- **app/** contains your app-specific code, including actions, views and templates.
- **config/** contains configuration for the Hanami framework and your app's components.
- **lib/** contains code you want to load before Hanami boots, like modules and classes that you want to share between multiple Hanami apps.
- **public/** is for static files to be served directly by your web server.
- **spec/** is for RSpec tests.
- **Gemfile** declares your Ruby gem dependencies (managed by Bundler).
- **Rakefile** describes Rake tasks for your app.
- **config.ru** is for Rack servers to start your app.
- **package.json** describes JavaScript package dependencies (managed by npm).

## What's next?

Now we're ready to build something with Hanami. Choose your path:

- [Building a web app](//page/building-a-web-app/)
- [Building an API](//page/building-an-api/)
