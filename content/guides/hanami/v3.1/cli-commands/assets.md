---
title: Assets
---

## hanami assets compile

Compiles the app's [assets](//guide/actions) into bundles for use in production:

```shell
$ bundle exec hanami assets compile
[bookshelf]
[bookshelf]   public/assets/app-SQ36TYM4.js       53b
[bookshelf]   public/assets/app-KUHJPSX7.css      45b
[bookshelf]   public/assets/app-KUHJPSX7.css.map  93b
[bookshelf]   public/assets/app-SQ36TYM4.js.map   93b
[bookshelf]
[bookshelf] ⚡ Done in 3ms
```

## hanami assets watch

Watches for changes to your assets and compiles the relevant files immediately. This is a long-running command, and is run by [hanami dev](//page/dev) by default.

```shell
$ bundle exec hanami assets watch
[bookshelf] [watch] build finished, watching for changes...
[bookshelf] [watch] build started (change: "app/assets/js/app.js")
[bookshelf] [watch] build finished
[bookshelf] [watch] build started (change: "app/assets/css/app.css")
[bookshelf] [watch] build finished
```
