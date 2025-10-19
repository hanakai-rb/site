---
title: Introduction & Usage
---

# Hanami::Webconsole

[Hanami](//doc/hanami) development web console.

## Installation

**Hanami::Webconsole** supports Ruby (MRI) 3.1+.

Add this line to your Hanami project's `Gemfile`:

```ruby
group :development do
  gem "hanami-webconsole"
end
```

And then execute:

```shell
$ bundle install
```

**NOTE:** You need a version of `hanami` `2.0.0+`.

## Usage

When an exception is raised during your local development in-browser, you'll see the web console.

### Code reloading

This gem in **not compatible** with `hanami` code reloading.

In order to use this gem, you have two alternatives:

1. Start the server without code reloading: `bundle exec hanami server --no-code-reloading`
1. Use [`hanami-reloader`](https://rubygems.org/gems/hanami-reloader) gem and start the server as usual: `bundle exec hanami server`

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

To run all the test, use `script/ci`.

## Acknowledgements

This gem is based on the great work of [`better_errors`](https://rubygems.org/gems/better_errors) and [`binding_of_caller`](https://rubygems.org/gems/binding_of_caller) gems. Thank you!
