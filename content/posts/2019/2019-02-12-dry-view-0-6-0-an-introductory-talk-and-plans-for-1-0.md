---
title: "dry-view 0.6.0, an introductory talk, and plans for 1.0"
date: 2019-02-12 12:00 UTC
author: Tim Riley
---

Last month we released [dry-view](/gems/dry-view/) 0.6.0, a very special release that made huge strides towards the system's overall completeness. With 0.6.0, dry-view should now offer _everything you need_ to write better organized views in Ruby.

From here, our goal is to take dry-view to version 1.0. So please give this release a try! Your feedback at this point will help ensure 1.0 is as polished as possible.

If you're new to dry-view, or would like to see its new features presented in context, then you're in luck! [My talk from RubyConf AU](https://youtu.be/VGWt1OLFzdU) (which took place just last week!) is a nice and tidy, 20-minute package explaining dry-view's rationale and how everything fits together:

<iframe width="560" height="315" src="https://www.youtube.com/embed/VGWt1OLFzdU" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

I'd also invite you to take another look at the [dry-view documentation](/gems/dry-view/). This has been brought up to date and covers all the new features.

And as for what’s changed with this release, here are the highlights:

## Letting views be views

Firstly, a simple change, but a meaningful one: `Dry::View::Controller` has been renamed to `Dry::View`.

Until now, we gave the name "view controllers" to our main view objects. This felt reasonable, since their job was very much about _coordination_ - holding configuration, accepting input data, then working with other parts of the application to prepare values for its template.

However, this was always a source of confusion: view controllers may be an established pattern in other languages and frameworks, but not within Ruby, where the term "controller" is firmly entrenched as an object for handling HTTP requests.

And even with the previous name, we'd still end up calling these things "views" once we started using them within an application. So we've paved the cow path and embraced `Dry::View` as the name for these view classes. Let views be views.

## Automatic part decoration

[Parts](/gems/dry-view/0.7/parts) are a major reason to use dry-view: they offer an easy, integrated place for encapsulating view-specific behaviour alongside the data it relates to.

Until now, however, using a broad range of part classes involved specifying those classes by name, directly, for every exposure.

With this release, dry-view's standard part builder comes with automatic part class resolution. Now you can configure a `part_namespace` on your view class, and then your exposure values will automatically be decorated by matching parts found within that namespace.

An example will speak a thousand words:

```ruby
module Parts
  class Article < Dry::View::Part
  end
  class Author < Dry::View::Part
	end
end

class AuthorContributionsView < Dry::View
  config.part_namespace = Parts

  expose :author   # decorated by Parts::Author
  expose :articles # each item decorated by Parts::Article
end
```

Part decoration of exposure values can still be customized using the `:as` option, which now accepts both a concrete part class, as well as a symbolic name (e.g. `expose :admin_user, as: :user`), which will become the name used for the automatic part class resolution.

If you don't want an exposure value to be decorated, you can provide the `decorate: false` option. This can be useful when exposing "primitive" values (e.g. strings or numbers, etc.) instead of richer domain objects or data structures.

## Increased access to parts

Part behavior is now available when exposures access each other via exposure dependencies:

```ruby
class AuthorContributionsView < Dry::View
  config.part_namespace = Parts

  expose :author

  expose :articles do |author|
	  # author is a `Parts::Author` here
  end
end
```

Along with this, parts can now be accessed via a new `Dry::View::Rendered` object that is returned when calling views. This object converts to a string to return the view output (`my_view.call.to_s`), but also carries all the parts that are exposed to the template, which are accessible by name (`my_view.call[:author]`) and also as a complete hash of locals (`my_view.call.locals`).

## Customizable scopes!

Until now, we’ve had exposures and parts to pass values to the template along with their view-specific behavior, and the context object to provide behavior common to all templates. But what about behavior that we want to provide to just a _single_ template or partial?For this, we now have [customizable scopes](/gems/dry-view/0.7/scopes).

Unlike parts, which decorate a single value, scopes have access to a template’s entire set of locals (as well as the context object, plus the methods to render partial or build other scopes). This gives you another logical place to provide some custom view behavior that can still access all the other features of the system.

Scopes must inherit from `Dry::View::Scope`. Locals can be accessed via their names, and the full hash is available via `#locals`. Other methods of interest are `#context`, `#render`, and `#scope`.

```ruby
module Scopes
  class MediaPlayer < Dry::View::Scope
    def show_buttons?
      # Referencing full `locals` hash
      locals.fetch(:show_buttons, true)
    end

    def player_title
      # Referencing `item` local
      "Media player: #{item.title}"
    end
  end
end
```

You can specify a scope to use for a view’s own template:

```ruby
class MyView < Dry::View
  config.template = "my_template"
  config.scope = MyScope
end
```

You can also build specify a `scope_namespace` which will be used to search for scopes when you build them up _inside a template_:

```ruby
class MyView < Dry::View
  config.template = "my_template"
  config.scope_namespace = Scopes
end
```

```erb
<h1>My multimedia</h1>

<!-- Builds Scopes::MediaPlayer and renders its partial -->
<%= scope(:media_player, item: item).render %>
```

Rendering a scope like this will look for a partial matching the scope’s own name (in this case `_media_player.html.erb`), which can make for some quite expressive uses of inline scopes. Of course, you can continue to render partials with explicitly provided names, both externally, like within this template, or inside methods you define in your custom scope classes.

## Context object can decorate attributes

[Context](/gems/dry-view/0.7/context) classes must now inherit from `Dry::View::Context`. This brings the ability for context classes to specify which of their attributes should be decorated with parts.

For example, for a context with an injected `assets` dependency, specifying `decorate :assets` would have the assets object wrapped in a matching part class (e.g. `Parts::Assets` if the view currently rendering has a `part_namespace` of `Parts`).

```ruby
class Context < Dry::View::Context
  attr_reader :assets
  decorate :assets

  def initialize(assets:, **)
    @assets = assets
    super
  end
end
```

## Exposure blocks/methods can access context

A key theme of dry-view is making every aspect of the view rendering facilities available to every component of the system. In this vein, the context object is now accessible from exposure blocks and methods, via specifying a `context:` parameter.

```ruby
class AuthorContributionsView < Dry::View
  config.part_namespace = Parts

  expose :author do |author_id:, context:|
    # author_id comes from the view's `#call` args

    # context is either:
    #  - or context provided to `#call`
    #  - or the view's configured default context
  end
end
```

## Layout exposures

Exposures can now be sent to the layout via the `layout: true` option.

## Full support for Erb & Haml

An important aspect of template authoring with dry-view is the ability to pass blocks to any method or partial from within a template, and have these behave as you'd expect (i.e with the `yield` inside the method or partial returning the evaluated contents of the block).

This has always worked out of the box with [Slim templates](http://slim-lang.com), which will serve us for a quick example. Say we have a `_wrapper.html.slim` partial:

```slim
.wrapper
  == yield
```

Then rendering this partial in a template like so:

```slim
== render(:wrapper) do
  p Hello there!
```

Will give us output like this:

```html
<div class="wrapper">
  <p>Hello there!</p>
</div>
```

Makes sense, right? Turns out this isn’t possible with the other popular Ruby templating languages, Erb and Haml, without some huge degree of hackery. Luckily for us, there are 2 alternative implementations of these languages that support this sensible block capturing, [erbse](https://github.com/apotonick/erbse) and [hamlit-block](https://github.com/hamlit/hamlit-block) respectively. To give dry-view full Erb and Haml support, it will now require one of these gems to be installed before attempting to render an Erb or Haml template.

## Easier unit testing for Parts and Scopes

Parts and scopes can now be more easily [unit tested](/gems/dry-view/0.7/testing).

If you want to unit test the aspects of the class that don’t require a full rendering environment, you can now instantiate a Part with its value alone:

```ruby
part_for_testing = Parts::Article.new(value: my_article)
```

If you want to unit test aspects of a part that do require a full rendering environment, like rendering partials or accessing the context object, then you can now build a `template_env` off an existing view class:

```ruby
part_for_testing = Parts::Article.new(
  name: :article,
  value: my_article,
  render_env: MyView.template_env,
)
```

For more detailed unit testing examples, see the [dry-view testing documentation](/gems/dry-view/0.7/testing).

## And more!

Phew! Those were just the highlights. For more, see the [detailed release notes](https://github.com/dry-rb/dry-view/releases/tag/v0.6.0) for 0.6.0.
