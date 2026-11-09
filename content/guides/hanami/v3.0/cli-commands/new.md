---
title: New
---

## hanami new

Generates a Hanami application with the given APP name, in a new directory from the current location.

```shell
$ hanami new bookshelf # generates a new Bookshelf application in ./bookshelf
$ hanami new my_app # generates a new MyApp application in ./my_app
```

On the application generation, Hanami performs gem bundling, NPM bundling, and general application setup.

### Specify a database

Provide `--database=DATABASE` to specify the database type for your app. Available options are `sqlite` (default), `mysql`, and `postgres`.

### Specifying a gem source

Provide a `--gem-source` to specify the gem source for your app's `Gemfile`.

```shell
$ hanami new bookshelf --gem-source=gem.coop

# Generates a Gemfile with:
# source "https://gem.coop"
```

### Choosing a test framework

Provide `--test=TEST` to choose your app's test framework. Available options are `rspec` (default) and `minitest`.

### Choosing a template engine

Provide `--template-engine=ENGINE` to choose the default template engine used by generators. Available options are `erb` (default), `haml`, and `slim`.

### Naming the app

Provide `--name=NAME` to use a different name for the app's module namespace than the one derived from the directory name.

### Skipping features

Skip the installation of certain Hanami features by passing `--skip-assets`, `--skip-view`, `--skip-db`, or `--skip-mailer`.

Pass `--skip-install` to skip installation steps such as bundling gems and installing third-party Hanami plugins.

### Using Hanami HEAD

If you're interested in testing the latest code or debugging an issue, you can generate an application that uses the HEAD version of Hanami, directly from the `main` branches of the GitHub repositories.

```shell
$ hanami new bookshelf --head
```
