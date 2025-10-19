---
title: Introduction & Usage
---

# Hanami :cherry_blossom:

**A flexible framework for maintainable Ruby apps.**

Hanami is a **full-stack** Ruby web framework. It's made up of smaller, single-purpose libraries.

This repository is for the full-stack framework, which provides the glue that ties all the parts together:

- [**Hanami::Router**](//doc/hanami-router) - Rack compatible HTTP router for Ruby
- [**Hanami::Controller**](//doc/hanami-controller) - Full featured, fast and testable actions for Rack
- [**Hanami::View**](//doc/hanami-view) - Presentation with a separation between views and templates
- [**Hanami::DB**](//doc/hanami-db) - Database integration, complete with migrations, repositories, relations, and structs
- [**Hanami::Assets**](//doc/hanami-assets) - Assets management for Ruby

These components are designed to be used independently or together in a Hanami application.

## Installation

Hanami supports Ruby (MRI) 3.1+.

```shell
gem install hanami
```

## Usage

```shell
hanami new bookshelf
cd bookshelf && bundle
bundle exec hanami dev
# Now visit http://localhost:2300
```

Please follow along with the [Getting Started guide](https://hanakai.org/guides/hanami/getting-started).

## Donations

You can give back to Open Source, by supporting Hanami development via [GitHub Sponsors](https://github.com/sponsors/hanami).

## Community

We care about building a friendly, inclusive and helpful community. We welcome people of all backgrounds, genders and experience levels, and respect you all equally.

We do not tolerate nazis, transphobes, racists, or any kind of bigotry. See our [code of conduct](/conduct) for more.
### Tests

To run all test suite:

```shell
$ bundle exec rake
```

To run all the unit tests:

```shell
$ bundle exec rspec spec/unit
```

To run all the integration tests:

```shell
$ bundle exec rspec spec/integration
```

To run a single test:

```shell
$ bundle exec rspec path/to/spec.rb
```

### Development Requirements

- Ruby >= 3.1
- Bundler
- Node.js
