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

    # TODO: Get selected state properly
    expose :nav_items, layout: true do
      [
        NavItem.new(label: "Guides", url: "/guides", selected: false, children: []),
        NavItem.new(label: "Docs", url: "/docs", selected: false, children: []),
        NavItem.new(label: "Blog", url: "/blog", selected: false, children: []),
        NavItem.new(label: "Community", url: "/blog", selected: false, children: []),
        NavItem.new(label: "Conduct", url: "/conduct", selected: false, children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: false, children: [])
      ]
    end
  end
end
