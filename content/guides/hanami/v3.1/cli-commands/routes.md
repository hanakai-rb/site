---
title: Routes
---

## hanami routes

Displays your application's routes.

```shell
$ bundle exec hanami routes

GET     /                             home.index                    as :root
GET     /books                        books.index
GET     /books/:id                    books.show
POST    /books                        books.create
```

By default, routes are displayed in "human friendly" format. Routes can be inspected in csv format via the format option:

```shell
$ bundle exec hanami routes --format=csv

METHOD,PATH,TO,AS,CONSTRAINTS
GET,/,home.index,:root,""
GET,/books,books.index,"",""
GET,/books/:id,books.show,"",""
POST,/books,books.create,"",""
```

These formats come from Hanami Router's formatters. To use them in your own code, see [Inspecting routes](//guide/routing#inspecting-routes).
