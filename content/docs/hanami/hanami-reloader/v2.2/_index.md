---
title: Introduction & Usage
---

# Hanami::Reloader

Reloader and testing support for [full-stack Hanami applications](//doc/hanami).

## Version

Versioning of this gem follows Reloader.

## Installation

**Hanami::Reloader** supports Ruby (MRI) 3.1+

Add this line to your application's Gemfile:

```ruby
group :cli, :development do
  gem "hanami-reloader"
end
```

And then execute:

    $ bundle install
    $ bundle exec hanami setup

## Usage

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `Hanami::Reloader` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hanami/reloader/blob/main/CODE_OF_CONDUCT.md).
