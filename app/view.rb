# auto_register: false
# frozen_string_literal: true

require "hanami/view"

# For .xml.builder templates
require "builder"

module Site
  class View < Hanami::View
    include Deps["settings"]

    # Used in the app layout
    expose :settings, decorate: false

    NavItem = Data.define(:label, :url, :selected, :children)
    expose :nav_items, layout: true do
      [
        NavItem.new(label: "Guides", url: "/guides", selected: false, children: [
          NavItem.new(label: "Hanami", url: "/guides/hanami/v2.2/getting-started", selected: false, children: []),
          NavItem.new(label: "Dry", url: "/guides/dry/v1.0/getting-started", selected: false, children: []),
          NavItem.new(label: "Rom", url: "/guides/rom/v5.0/getting-started", selected: false, children: [])
        ]),
        NavItem.new(label: "Docs", url: "/docs", selected: false, children: [
          NavItem.new(label: "Hanami", url: "/docs/#hanami", selected: false, children: []),
          NavItem.new(label: "Dry", url: "/docs/#dry", selected: false, children: []),
          NavItem.new(label: "Rom", url: "/docs/#rom", selected: false, children: [])
        ]),
        NavItem.new(label: "Blog", url: "/blog", selected: false, children: []),
        NavItem.new(label: "Community", url: "/blog", selected: false, children: []),
        NavItem.new(label: "Conduct", url: "/conduct", selected: false, children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: false, children: [])
      ]
    end
  end
end
