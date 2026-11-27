---
title: New
---

## hanami new

Generates a Hanami app with the given name, in a new directory from the current location.

```shell
$ hanami new bookshelf # generates a new Bookshelf application in ./bookshelf
$ hanami new my_app # generates a new MyApp application in ./my_app
```

Hanami then installs your app's gems and npm packages, and finishes setting it up. When it's done, it shows you how to start your app:

```shell
$ hanami new bookshelf

Creating bookshelf/
  create  .gitignore
  create  .env
  create  README.md
  create  Gemfile
  ...

Installing
  ✓ bundle install in 14.2s
  ✓ npm install in 6.8s
  ✓ hanami install in 2.1s
  ✓ bundle binstubs hanami-cli rake in 0.4s
  ✓ git init

🌸 Your new Hanami app is ready! (24.6s)

  cd bookshelf
  bin/setup
  bin/dev

View your app at http://localhost:2300

📚 Learn more   https://hanakai.org/learn/hanami
💬 Join us      https://hanakai.org/community
```

### Specify a database

Provide `--database=DATABASE` to specify the database type for your app. Available options are `sqlite` (default), `mysql`, and `postgres`.

### Specifying a gem source

Provide a `--gem-source` to specify the gem source for your app's `Gemfile`.

```shell
$ hanami new bookshelf --gem-source=gem.coop

# Generates a Gemfile with:
# source "https://gem.coop"
```

### Skipping features

Skip the installation of certain Hanami features by passing `--skip-assets`, `--skip-view`, `--skip-db`, or `--skip-mailer`.

### Skipping git

By default, Hanami initializes a git repository for your app and generates a `.gitignore`. Pass `--skip-git` to skip both:

```shell
$ hanami new bookshelf --skip-git
```

### Using Hanami HEAD

If you're interested in testing the latest code or debugging an issue, you can generate an application that uses the HEAD version of Hanami, directly from the `main` branches of the GitHub repositories.

```shell
$ hanami new bookshelf --head
```
