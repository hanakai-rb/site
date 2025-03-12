---
title: "dry-view 0.3.0: another step towards solving the view layer mess"
date: 2017-05-15 12:00 UTC
author: Tim Riley
---

We’re excited to announce the release of dry-view 0.3.0, which introduces two concepts for better organising your views: view parts and decorators.

How do these work? Every dry-view controller now comes configured with a **decorator** (you can use our default or provide your own), whose job is to wrap up your values in **view parts** before passing them to the template. View parts give you a place to cleanly combine view-specific behaviour with your application’s values.

By default, every view part is a plain `Dry::View::Part` instance. This gives you access to a `#render` method for rendering a partial with the view part included in the partial’s scope:

```ruby
class AccountView < Dry::View::Controller
  configure do |config|
    config.template = "account"
  end

  expose :account do
    # fetch the account value
  end
end
```

```erb
<h1>Your account</h1>

<%# Renders "account/_info_box.html.erb" with `account` in scope %>
<%= account.render :info_box %>
```

This is just the beginning. Things get interesting when you specify your own view part classes:

```ruby
expose :account, as: AccountPart
```

Since view parts are designed as wrappers, you have access to every method on the value:

```ruby
class AccountPart < Dry::View::Part
  def display_name
    "#{full_name} <#{email}>"
  end
end
```

This is nice, but so far it’s just typical delegator-style behaviour. We can do more: these things are called _view_ parts for a reason! Every view part is initialised with the view’s current [context object](http://dry-rb.org/gems/dry-view/0.7/context) and renderer. This means the view part can now encapsulate much of the logic you’d otherwise have to scatter around your templates.

Let’s say our context object has `#attachment_url` and `#asset_url` methods, for generating URLs for user-uploaded files and application assets respectively. If you wanted to start showing a profile image for your “account” value, you could now do this:

```ruby
class AccountPart < Dry::View::Part
  def profile_image_url
    # profile_image_path is an attribute on the wrapped value
    if profile_image_path
      context.attachment_url(profile_image_path, "80x80")
    else
      context.asset_url("images/default_user_profile.jpg")
    end
  end
end
```

Then all you have left to do is add this one-liner to your template:

```erb
<img src=<%= account.profile_image_url %>>
```

The result? A cleaner template, and your view logic properly named and encapsulated in its own class, which you can also test  independently.

In this way, view parts provide a critical new layer for placing the majority of your complex view logic. They make your templates easier to understand and easier to work with, and they help ensure that your view layer isn’t where good code structure has to stop.

Want to learn more? Check out [view parts in the dry-view documentation](http://dry-rb.org/gems/dry-view/0.7/parts) and give dry-view 0.3.0 a try!
