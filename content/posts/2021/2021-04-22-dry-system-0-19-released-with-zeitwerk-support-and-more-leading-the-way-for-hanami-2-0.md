---
title: dry-system 0.19 released with Zeitwerk support and more, leading the way for Hanami 2.0
date: 2021-04-22 12:00 UTC
author: Tim Riley
---

We are very pleased to announce the release of dry-system 0.19.0! This release marks a huge step forward for dry-system, bringing support for [Zeitwerk][zw] and other autoloaders, plus clearer configuration and improved consistency around component resolution for both finalized and lazy loading containers.

These changes will also pave the way for a seamless integration of Zeitwerk and dry-system into the new Hanami 2.0 application core. Until then, thanks to dry-rb serving as an independent foundation layer for Hanami, you can already try out these new features!

A dry-system container as of 0.19.0, configured for Zeitwerk, now looks like this:

```ruby
require "dry/system/container"
require "dry/system/loader/autoloading"
require "zeitwerk"

class MyApp::Container < Dry::System::Container
  configure do |config|
    config.root = __dir__

    config.component_dirs.loader = Dry::System::Loader::Autoloading
    config.component_dirs.add_to_load_path = false

    config.component_dirs.add "lib"
  end
end

loader = Zeitwerk::Loader.new
loader.push_dir MyApp::Container.config.root.join("lib").realpath
loader.setup
```

Unlike the default loader, the new `Dry::System::Loader::Autoloading` does not `require` files itself when loading components. Instead, it references their class constants directly, allowing the missing constant resolution to trigger the autoloading behaviour of [Zeitwerk][zw] and other autoloaders. This is all that's required to bring Zeitwerk and dry-system together! Combined with dry-system's [auto-injector](https://dry-rb.org/gems/dry-system/0.17/auto-import/), you now have the best of both worlds: the convenience of auto-loading classes combined with all the loose-coupling benefits of injected dependencies.

The new `component_dirs` setting also allows multiple component dirs to be added (these are where dry-system looks when loading a container's components) and configured independently:

```ruby
class MyApp::Container < Dry::System::Container
  configure do |config|
    config.root = __dir__

    # Defaults for all component dirs can be configured
    config.component_dirs.default_namespace = "my_app"

    # As well as settings for individual dirs
    config.component_dirs.add "lib" do |dir|
      dir.auto_register = proc do |component|
        !component.identifier.start_with?('entities')
      end
    end

    # Multiple component dirs can be added
    config.component_dirs.add "app"
  end
end
```

The `auto_register` and `memoize` component dir settings have been improved as part of this release, now accepting either simple truthy or falsey values, or a proc accepting a `Dry::System::Component` and returning a truthy or falsey value. Using a proc makes it easy to configure fine-grained behavior on a component-per-component basis. Check out also the new `Dry::System::Identifier` class as used above via `component.identifier`: this is a new class that provides namespace-aware methods for querying container component identifiers, which is particularly useful in cases like the above.

Finally, we've given a lot of attention to making sure dry-system containers work consistently regardless of whether they're finalized or lazy loading their components. For example, `# auto_register: false` magic comments are not respected in both cases, where previously they were ignored for a lazy loading container.

There's plenty more to learn about this release, including several breaking changes, so check out the [changelog][changelog] for all the details. And if you want to understand more of the thinking that went into these changes, also check out Tim’s open source status updates for this last [November][tim-oss-nov], [December][tim-oss-dec], [January][tim-oss-jan], and [February][tim-oss-feb] (Yes, this release has been long in the making!).

With many internal improvements also in place for this release, we now see a clear picture of what's left before 1.0, and have filled out the [dry-system 1.0 milestone][milestone-1.0] with issues representing the remaining work. Please take a look and get in touch if you can help.

In the meantime, we hope you enjoy dry-system 0.19.0 and please let us know how you go with all the new features!

[zw]: https://github.com/fxn/zeitwerk
[changelog]: https://github.com/dry-rb/dry-system/releases/tag/v0.19.0
[tim-oss-nov]: https://timriley.info/writing/2020/12/07/open-source-status-update-november-2020
[tim-oss-dec]: https://timriley.info/writing/2021/01/06/open-source-status-update-december-2020
[tim-oss-jan]: https://timriley.info/writing/2021/02/01/open-source-status-update-january-2021
[tim-oss-feb]: https://timriley.info/writing/2021/03/09/open-source-status-update-february-2021/
[milestone-1.0]: https://github.com/dry-rb/dry-system/milestone/1
