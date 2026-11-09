---
title: Templates and partials
---

Every view has a template, which is given the values from the view's [exposures](//page/input-and-exposures) and then used to render the view's output.

Templates are kept the `templates/` directory in the root of `app/` and each slice directory.

Each view looks for a template that matches its name. For example, given a `Books::Show` view, a template named `books/show` will be located within the templates directory.

## Template engines

Views use ERB templates by default. To use an ERB template, give your file an `.html.erb` extension.

Template files follow a 3-part naming scheme: `<name>.<format>.<engine>`:

- `name` matches the name of the view, with Ruby module nesting translated into slashes
- `format` matches the template with the view's [format](//page/configuration)
- `engine` determines the rendering engine to use for the template

Along with ERB, Hanami supports the full range of template engines available through [Tilt](https://github.com/jeremyevans/tilt), and will detect the engine based on each template's file extension.

Views also provide special first-class support for [Haml](https://haml.info) and [Slim](https://slim-template.github.io) to ensure they behave consistently with the default ERB templates.

Where a template engine requires their own gem, be sure to install this yourself, as well as require it in your base view class:

```ruby
# app/view.rb

# Use Slim for ".html.slim" templates
require "slim"

module Bookshelf
  class View < Hanami::View
  end
end
```

## Layouts

Each view's template is rendered within a layout. Layouts are kept within the `templates/layouts/` directory, and views use an `app` layout by default.

Every layout should `yield` at the appropriate location to include the content from the template. For example:

```sql
# app/templates/layouts/app.html.erb

<html>
  <body>
    <%= yield %>
  </body>
</html>
```

## HTML safety

When using ERB, Haml or Slim templates, strings will be checked for their HTML safety when they are included in the template.

If the string is HTML safe, it will be included in the template without escaping. For all other strings, it will be HTML escaped as it is included.

HTML safety checks are made by calling `string.html_safe?`.

When writing your own [helpers](//page/helpers) or other code providing strings to templates, you can make a string as HTML safe by calling `.html_safe` on the string:

```
def my_helper
  "<p>This is safe</p>".html_safe
end
```

You may choose to skip the auto-escaping of non-HTML safe strings by using particular template tags. In ERB:

```sql
<%== "<p>Non-safe strings will not be auto-escaped</p>" %>
```

Similar tags also exist for Haml and Slim. Use these tags with caution. This is **not recommended** for strings coming from untrusted user input.

## Template scope

Each template and partial is rendered within its own scope, which determines the variables and methods available for the template to use. These include:

- Your template's locals: the values returned from its [exposures](//page/input-and-exposures), wrapped by [parts](//page/parts)
- Your app or slice's [helpers](//page/helpers)
- The public methods available on the view's [context](//page/context)
- A `#render` method, for rendering partials

You may choose to provide custom scopes for templates and partials. To learn more, see [Scopes](//page/scopes).

## Rendering partials

You can render a partial from your template using the `render` method:

```sql
<%= render "path/to/my_partial" %>
```

Partials are looked up within the templates directory, with the partial's file name expected to be prefixed by an underscore. For the example above, the partial template is expected to be at `templates/path/to/_my_partial.html.slim`.

You can provide explicit locals to a partial via keyword arguments:

```sql
<%= render "path/to/my_partial", my_locals: "go here" %>
```

When you provide explicit locals to a partial, only those locals will be available to the partial. When you provide no locals at all, then the partial will have access to the calling template's own set of locals.

## Declaring locals

A template can declare the locals it takes with a magic comment at its top, written like a Ruby method's keyword arguments:

```erb
<%# app/templates/books/_form.html.erb %>
<%# locals: (form_title:, submit_label: "Save") %>

<h2><%= form_title %></h2>
```

Rendering this partial without `form_title`, or with a local it does not declare, raises an `ArgumentError` (such as `missing keyword: :form_title` or `unknown keyword: :titel`). Locals with defaults, like `submit_label` above, are filled in when not given.

In Haml, write the comment as `-# locals: (form_title:)`, and in Slim as `/# locals: (form_title:)`, with only comment syntax before it on its line.

In ERB, Haml, and Slim, the declaration must open its comment, and it ends at the parenthesis matching its opening one. This means defaults can call methods, a note can follow the declaration, and an ERB declaration can span several lines:

```erb
<%# locals: (
  book:,
  heading: book.title.upcase,
  show_author: true
) Used by the books index and show pages %>
```

It also means a template whose text happens to show the syntax is not treated as declaring its locals. Templates in other languages use Tilt's own matching, which finds `# locals: (` anywhere in the template.

### Partials

A partial that declares its locals receives only the locals passed to it. It never receives its caller's locals, even when rendered without arguments, so pass it everything it needs:

```erb
<%= render "books/form", form_title: "New book" %>
```

A partial rendered from a [part](//page/parts) is given the part under its name, so a `user.render("avatar")` call can be declared with `<%# locals: (user:) %>`.

If the partial uses a custom [scope](//page/scopes), it keeps its caller's scope class and its methods. However, scope methods that read a local will raise in a declaring partial unless that local is passed to it.

### View templates

In a view's template, the comment declares the view's [exposures](//page/input-and-exposures). Every exposure must be declared, including any added by a base view class, so declare the ones the template uses and accept the rest with `**`:

```erb
<%# app/templates/books/show.html.erb %>
<%# locals: (book:, **) %>

<h1><%= book.title %></h1>
```

Exposures are only run when a template reads them, so a template that declares its locals runs only the exposures it declares. Accepting the rest with `**` runs them all.

### Turning off declared locals

Templates without the comment are unaffected. Since the comment follows the same form as in Rails, a declaration kept from a Rails app is enforced too. To ignore these comments entirely, configure your view's renderer options:

```ruby
# app/view.rb

module Bookshelf
  class View < Hanami::View
    config.renderer_options = {extract_fixed_locals: false}
  end
end
```
