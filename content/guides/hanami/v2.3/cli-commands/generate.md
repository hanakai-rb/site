---
title: Generate
---

## hanami generate

Hanami 2.3 provides a few generators:

```shell
$ bin/hanami generate --help
Commands:
  hanami generate action NAME
  hanami generate component NAME
  hanami generate migration NAME
  hanami generate operation NAME
  hanami generate part NAME
  hanami generate relation NAME
  hanami generate repo NAME
  hanami generate slice NAME
  hanami generate struct NAME
  hanami generate view NAME
```

If your app has slices, pass `--slice=SLICE` to specify where to generate the file. You can also run `hanami generate` from inside a slice directory and the generator will target that slice automatically.

### hanami generate action

Generates an [action](//guide/actions/overview):

```shell
$ bundle exec hanami generate action books.show
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate action --help
```

### hanami generate component

Generates a [component](//guide/app/container-and-components):

```shell
$ bundle exec hanami generate component isbn_decode
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate component --help
```

### hanami generate migration

Generates a [migration](//guide/database/migrations):

```shell
$ bundle exec hanami generate migration create_posts
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate migration --help
```

### hanami generate operation

Generates an [operation](//guide/operations/overview/):

```shell
$ bundle exec hanami generate operation books.add
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate operation --help
```

### hanami generate part

Generates a view [part](//guide/views/parts/):

```shell
$ bundle exec hanami generate part book
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate part --help
```

### hanami generate relation

Generates a [relation](//guide/database/relations/):

```shell
$ bundle exec hanami generate relation books
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate relation --help
```

### hanami generate repo

Generates a [repo](//guide/database/overview/#repositories):

```shell
$ bundle exec hanami generate repo books
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate repo --help
```

### hanami generate slice

Generates a [slice](//guide/app/slices/):

```shell
$ bundle exec hanami generate slice admin
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate slice --help
```

### hanami generate struct

Generates a [struct](//guide/database/overview/#structs):

```shell
$ bundle exec hanami generate struct book
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate struct --help
```

### hanami generate view

Generates a [view](//guide/views/overview/):

```shell
$ bundle exec hanami generate view books.create
```

Use the `--help` option to access all accepted options:

```shell
$ bundle exec hanami generate view --help
```
