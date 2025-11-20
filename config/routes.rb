# frozen_string_literal: true

module Site
  class Routes < Hanami::Routes
    # Only consider strings like "v1.0" as versions in paths
    VERSION_REGEX = /v\d+\.\d+/
    VERSION_OPTS = %i[version org_version guide_version].to_h { [_1, VERSION_REGEX] }.freeze

    root to: "pages.home"

    # Guides indexes
    get "/guides", to: "guides.index"
    get "/guides/:org/:version", to: "guides.org_index", **VERSION_OPTS

    # Org-versioned guides
    get "/guides/:org/:org_version/:slug", to: "guides.show", **VERSION_OPTS
    get "/guides/:org/:org_version/:slug/*path", to: "guides.show", **VERSION_OPTS

    # Self-versioned guides
    get "/guides/:org/:slug/:guide_version", to: "guides.show", **VERSION_OPTS
    get "/guides/:org/:slug/:guide_version/*path", to: "guides.show", **VERSION_OPTS

    # Unversioned guides
    get "/guides/:org/:slug", to: "guides.show"
    get "/guides/:org/:slug/*path", to: "guides.show"

    # Blog
    get "/blog", to: "blog.index", as: :blog
    get "/blog/page/:page", to: "blog.index"
    get "/blog/*permalink", to: "blog.show", as: :blog_post
    get "/feed.xml", to: "feed.index"

    # Special pages
    get "/community", to: "pages.community"
    get "/conduct", to: "pages.conduct"
    get "/sponsor", to: "pages.sponsor"
  end
end
