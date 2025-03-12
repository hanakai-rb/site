---
title: Introducing dry-files
date: 2021-05-04 12:00 UTC
author: Luca Guidi
---

We talked several times about the union of [dry-rb][dry] + [ROM][rom] + [Hanami][hanami], well today we can share good news on that front: introducing `dry-files`.

It's a gem that abstracts low level file manipulations.

The code was originally created for `hanami-utils`, as a way to power Hanami command line.
Then it was moved to `dry-cli`, when it was extracted from the Hanami code base.
Today it finally made its own debut as a standalone gem.

`dry-cli` is a powerful framework to build Ruby command line interfaces.
We use it as the main engine for the Hanami CLI, which also needs _code generators_.
The initial idea was to have this optional `dry-cli` library to support _code generators_ via file manipulations.
But then we reached the point at which this library had more lines of code than `dry-cli` itself, so we decided to **extract** this library.

Here's a simple example:

```ruby
# frozen_string_literal: true

require "dry/files"

files = Dry::Files.new
files.write("path/to/file", "Hello, World!") # intermediate directories are created, if missing
```

`dry-files` is shipped with an extensive API to touch, (re)write, read, and remove files/directories, inject/remove/append Ruby code lines and blocks, and so on.

Because of this abstraction we had the chance to introduce swappable adapters.
One adapter (the default one) is for **real file manipulations**. It's meant to be used in **production and integration tests**.
The other adapter is an **in-memory file system**. It's for **very fast unit tests** that cleanup by themselves.

```ruby
# frozen_string_literal: true

require "dry/files"

files = Dry::Files.new(memory: true)
files.write("path/to/file", "Hello, World!") # create an in-memory file
```

Checkout the [docs][docs] and the [CHANGELOG][changelog] to know more. Enjoy!

[dry]: https://dry-rb.org
[rom]: https://rom-rb.org
[hanami]: https://hanamirb.org
[docs]: https://dry-rb.org/gems/dry-files
[changelog]: https://github.com/dry-rb/dry-files/releases/tag/v0.1.0
