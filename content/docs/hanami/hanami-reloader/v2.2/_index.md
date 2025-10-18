---
title: Introduction & Usage
---

# Hanami::Reloader

Reloader and testing support for [full-stack Hanami applications](//doc/hanami).

## Status

[![Gem Version](https://badge.fury.io/rb/hanami-reloader.svg)](https://badge.fury.io/rb/hanami-rspec)
[![CI](https://github.com/hanami/reloader/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/hanami/rspec/actions?query=workflow%3Aci+branch%3Amain)
[![Depfu](https://badges.depfu.com/badges/a8545fb67cf32a2c75b6227bc0821027/overview.svg)](https://depfu.com/github/hanami/reloader?project=Bundler)

## Version

Versioning of this gem follows Reloader.

## Contact

- [Home page](https://hanakai.org/)
- [Mailing List](http://hanamirb.org/mailing-list)
- [Bugs/Issues](https://github.com/hanami/reloader/issues)
- [Chat](https://discord.gg/KFCxDmk3JQ)

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hanami/reloader. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hanami/rspec/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the `Hanami::Reloader` project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hanami/reloader/blob/main/CODE_OF_CONDUCT.md).

## Copyright

Copyright © 2014–2024 Hanami Team – Released under MIT License
