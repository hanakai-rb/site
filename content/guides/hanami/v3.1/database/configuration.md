---
title: Configuration
---

New Hanami apps come with a database, set up and ready to go.

Hanami supports SQLite, PostgreSQL and MySQL (including MariaDB). New apps use SQLite by default. To choose a different database, use the `--database` option when you create your app:

```console
hanami new bookshelf --database=sqlite # default
hanami new bookshelf --database=postgres
hanami new bookshelf --database=mysql
```

To create an app without a database, use `--skip-db`:

```console
hanami new bookshelf --skip-db
```

Your database connection comes from the `db` provider. Hanami turns it on when your app or a slice has a `config/db/` directory. By default, your app and all its slices share one database configuration, but each slice can have its own. See [Slice configuration](#slice-configuration).

## DATABASE_URL

The primary point of configuration for your database connection is the DATABASE_URL environment variable.

You can set this in your `.env` file using the dotenv gem (which is only loaded for `development` and `test` environments).

Note that the value you set is the **development** database URL, and the _test_ database URL is **automatically derived** from it, ending with `_test`.

For example:

```
DATABASE_URL=sqlite://db/bookshelf.sqlite
DATABASE_URL=postgres://localhost/bookshelf_development
DATABASE_URL=mysql2://user:password@localhost/bookshelf_dev
```

For more detail on the syntax of the URLs, see [ROM SQL: Connecting to a Database](//org_guide/rom/sql#connecting-to-a-database)

### Building the URL from separate env vars

If it suits your setup better, you can give the parts of your database connection as separate env vars, instead of a single URL. When `DATABASE_URL` isn't set, Hanami builds the URL from these:

| Env var             | Value                                                                       |
| ------------------- | --------------------------------------------------------------------------- |
| `DATABASE_SCHEME`   | The URL scheme, such as `postgres`, `mysql2`, `sqlite` or `jdbc:postgresql` |
| `DATABASE_USER`     | The user name                                                               |
| `DATABASE_PASSWORD` | The password                                                                |
| `DATABASE_HOST`     | The host (defaults to `localhost`)                                          |
| `DATABASE_PORT`     | The port (defaults to the database driver's default port)                   |
| `DATABASE_NAME`     | The database name                                                           |

For example:

```
DATABASE_SCHEME=postgres
DATABASE_USER=bookshelf
DATABASE_PASSWORD=s3cret
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=bookshelf_development
```

This gives a URL of `postgres://bookshelf:s3cret@localhost:5432/bookshelf_development`. Hanami escapes the user, password and database name for you.

`DATABASE_SCHEME` is required. You can leave out any of the other env vars that your database doesn't need.

For SQLite, give the path to the database file as `DATABASE_NAME`. Hanami ignores the other env vars:

```
DATABASE_SCHEME=sqlite
DATABASE_NAME=db/bookshelf.sqlite
```

If you set `DATABASE_URL`, it always takes precedence, and Hanami ignores these separate env vars.

### JRuby

On JRuby, use a JDBC database URL. Hanami supports these JDBC URLs:

```
DATABASE_URL=jdbc:sqlite:db/bookshelf.sqlite
DATABASE_URL=jdbc:postgresql://localhost/bookshelf_development
DATABASE_URL=jdbc:mysql://localhost/bookshelf_dev
```

Each of these needs its matching JDBC gem in your `Gemfile`: jdbc-sqlite3, jdbc-postgres or jdbc-mysql.

## Advanced Configuration

If all you need to do is define `DATABASE_URL`, you don’t need to create any further configuration. However, there are cases where you may want to add Sequel or ROM plugins to your configuration.

This is achieved by creating `config/providers/db.rb`

```ruby
Hanami.app.configure_provider :db do
  config.gateway :default do |gw|
    # In addition to putting it in the DATABASE_URL env
    # variable, it can also be set in code here
    gw.database_url = "postgres://localhost:5432/mydb"

    # The default PostgreSQL configuration would look like this
    gw.adapter :sql do |sql|
      # ROM plugins are organized under the applicable component type
      # this plugin is named 'instrumentation' and applies to ROM::Relation
      sql.plugin relations: :instrumentation do |plugin|
        # If the plugin defines a config object with more options
        # you can yield it here and set the values
        plugin.notifications = slice["notifications"]
      end

      # Not every plugin requires extra configuration
      sql.plugin relations: :auto_restrictions

      # Sequel extensions are registered with a single symbolic name
      # sql.extension supports multiple arguments, and you can call it
      # multiple times. We split these up into two simply for readability.
      sql.extension :caller_logging, :error_sql, :sql_comments
      sql.extension :pg_array, :pg_enum, :pg_json, :pg_range
    end
  end
end
```

By default you are adding to the defaults above, but you can tell Hanami to skip them if you wish.

```ruby
gw.adapter :sql do |sql|
  # Skip everything
  sql.skip_defaults

  # Skip ROM plugins
  sql.skip_defaults :plugins

  # Skip Sequel extensions
  sql.skip_defaults :extensions

  # Skip SQLite pragmas
  sql.skip_defaults :connect_sqls
end
```

More on [Sequel Extensions](http://sequel.jeremyevans.net/rdoc/files/doc/extensions_rdoc.html)

## SQLite

For apps using SQLite, Hanami applies these [pragmas](https://www.sqlite.org/pragma.html) to every new database connection:

| Pragma               | Value              |
| -------------------- | ------------------ |
| `journal_mode`       | `wal`              |
| `synchronous`        | `normal`           |
| `mmap_size`          | 128MiB (134217728) |
| `journal_size_limit` | 64MiB (67108864)   |
| `cache_size`         | `2000`             |

These settings give SQLite better performance and concurrency in a web app. They need SQLite 3.30 or newer.

In WAL (write-ahead logging) mode, SQLite keeps `-wal` and `-shm` files next to your database file. New apps ignore these in their `.gitignore`, and `hanami db drop` cleans them up too.

To change a pragma or add your own, give `connect_sqls` in the gateway's connection options. These run after Hanami's pragmas, so your values take precedence:

```ruby
# config/providers/db.rb
Hanami.app.configure_provider :db do
  config.gateway :default do |gw|
    gw.connection_options connect_sqls: ["PRAGMA cache_size = 10000"]
  end
end
```

To turn off Hanami's pragmas, call `skip_defaults :connect_sqls` in your SQL adapter config:

```ruby
# config/providers/db.rb
Hanami.app.configure_provider :db do
  config.adapter :sql do |sql|
    sql.skip_defaults :connect_sqls
  end
end
```

A read-only connection cannot write to the database file, so for a gateway with `connection_options readonly: true`, Hanami does not apply the `journal_mode` pragma. This works only when you give `readonly: true` in the connection options, not as a param in the database URL.

## Query logging

Hanami logs every SQL query your app runs. Query logging has its own log level, `config.db.log_level` (defaulting to `:debug`), which is separate from the rest of your app's logging. For the full details — including the separate log level, SQL syntax highlighting, and customizing the highlighting theme — see [Database logging](//guide/logger/database-logging) in the logger guide.

## Slice Configuration

As Slices are designed to provide modular isolation of business domains, it’s likely that database isolation will also be desirable in some cases.

When configuring your slice database, instead of `DATABASE_URL`, you will use the `SLICE_NAME__DATABASE_URL` convention.

So, given the following slice definition:

```ruby
module Main
  class Slice < Hanami::Slice
  end
end
```

You would define a `MAIN__DATABASE_URL` environment variable and a `slices/main/config/db` directory.

The [separate database env vars](#building-the-url-from-separate-env-vars) take the same slice prefix, such as `MAIN__DATABASE_HOST` or `MAIN__DATABASE_NAME`. For each part of the URL, Hanami uses the slice's env var if you set it, and the app's env var if you don't. This way, a slice can share the database server with the app and give only its own database name.

Slice configuration is hierarchical, so if you have database configuration in the parent it will be inherited by all child slices by default. You can opt out of this via the configure_from_parent setting.

```ruby
module Main
  class Slice < Hanami::Slice
    config.db.configure_from_parent = false   # default: true
  end
end
```

If you prefer to define the relations for the entire app including all slices centrally in `app/relations/`, you can use the import_from_parent setting.

```ruby
module Main
  class Slice < Hanami::Slice
    config.db.import_from_parent = true   # default: false
  end
end
```

## Gateway Configuration

Isolating database connections per-slice is not a requirement. You may want to have multiple connections within a single slice, especially if you’re connecting to different kinds of datastores. ROM configurations have **gateways** that define independent database connections.

Consider the case of a database migration from MySQL to PostgreSQL. Doing this in a single step is highly risky, so it would be desirable to have connections to both for a period of time.

The simplest configuration may be done using the `DATABASE_URL__GATEWAY` format:

```
DATABASE_URL=postgres://localhost:5432/bookshelf_development
DATABASE_URL__LEGACY=mysql://localhost:3306/legacy
```

This works in concert with Slice configuration, as well:

```
MAIN__DATABASE_URL__LEGACY=mysql://localhost:3306/legacy
```

The separate database env vars take the same gateway suffix. Hanami adds a gateway for each suffix it finds, and for each part of the URL, uses the gateway's env var if you set it, and the default gateway's env var if you don't. For example, this adds an `:extra` gateway with its own database on the same server as the default gateway:

```
DATABASE_SCHEME=postgres
DATABASE_HOST=localhost
DATABASE_NAME=bookshelf_development
DATABASE_NAME__EXTRA=extra_development
```

Sometimes you will want additional connection options used when opening the connection. These may be added as query parameters on the DATABASE_URL:

```
DATABASE_URL__LEGACY=mysql://localhost:3306/legacy?max_connections=4
```

But as with Slice configuration, you can do more advanced things in code as well:

```ruby
Hanami.app.configure_provider :db do
  config.gateway :default do |gw|
    gw.connection_options search_path: ['public', 'alt']

    gw.adapter :sql do |sql|
      sql.extension :my_custom_ext
    end
  end

  config.gateway :legacy do |gw|
    gw.connection_options max_connections: 4
    gw.adapter :sql
  end
end
```

More on [Sequel connection options](http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html)

Relations are assigned to the default gateway automatically, so if you are defining a Relation for an alternate, you need to configure that explicitly:

```ruby
class Users < Hanami::DB::Relation
  gateway :legacy
  schema infer: true
end
```

## Container Keys

Hanami exposes your database configuration through a series of container keys.

| Key                   | Value                          |
| --------------------- | ------------------------------ |
| `db.config`           | Final ROM Configuration object |
| `db.rom`              | ROM instance for this slice    |
| `db.gateway`          | Default DB Gateway             |
| `db.gateways.default` | Explicitly-named gateway       |

Any additional gateways that you have defined will be registered under the `db.gateways` namespace.
