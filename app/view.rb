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
    expose :nav_items, layout: true do |context:|
      path = context.request.path
      [
        NavItem.new(label: "Guides", url: "/guides", selected: path.start_with?("/guides"), children: []),
        NavItem.new(label: "Docs", url: "/docs", selected: path.start_with?("/docs"), children: []),
        NavItem.new(label: "Blog", url: "/blog", selected: path.start_with?("/blog"), children: []),
        NavItem.new(label: "Community", url: "/community", selected: path.start_with?("/community"), children: []),
        NavItem.new(label: "Conduct", url: "/conduct", selected: path == "/conduct", children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: path == "/sponsor", children: [])
      ]
    end
  end
end
