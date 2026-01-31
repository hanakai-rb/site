# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "json"

# For .xml.builder templates
require "builder"

module Site
  class View < Hanami::View
    include Deps["settings"]

    # Used in the app layout
    expose :settings, decorate: false

    NavItem = Data.define(:label, :url, :selected, :children)
    expose :header_nav_items, layout: true do |context:|
      path = context.request.path
      [
        NavItem.new(label: "Learn", url: "/learn", selected: path.start_with?("/learn"), children: []),
        NavItem.new(label: "Blog", url: "/blog", selected: path.start_with?("/blog"), children: []),
        NavItem.new(label: "Community", url: "/community", selected: path.start_with?("/community"), children: []),
        NavItem.new(label: "Conduct", url: "/conduct", selected: path == "/conduct", children: []),
        NavItem.new(label: "Status", url: "/status", selected: path == "/status", children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: path == "/sponsor", children: [])
      ]
    end

    expose :footer_nav_items, layout: true do |context:|
      path = context.request.path
      [
        NavItem.new(label: "Learn", url: "/learn", selected: path.start_with?("/learn"), children: [
          NavItem.new(label: "Hanami", url: "/learn#hanami", selected: false, children: []),
          NavItem.new(label: "Dry", url: "/learn#dry", selected: false, children: []),
          NavItem.new(label: "Rom", url: "/learn#rom", selected: false, children: [])
        ]),
        NavItem.new(label: "Community", url: "/community", selected: path.start_with?("/community"), children: [
          NavItem.new(label: "Code repository", url: "https://github.com/hanami", selected: false, children: []),
          NavItem.new(label: "Discussion forum", url: "https://discourse.hanamirb.org/", selected: false, children: []),
          NavItem.new(label: "Chat room", url: "https://discord.gg/KFCxDmk3JQ", selected: false, children: [])
        ]),
        NavItem.new(label: "Blog", url: "/blog", selected: path.start_with?("/blog"), children: []),
        NavItem.new(label: "Conduct", url: "/conduct", selected: path == "/conduct", children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: path == "/sponsor", children: [])
      ]
    end

    expose :theme, layout: true, decorate: false do |context:, org: nil, slug: nil|
      orgs = %w[hanami dry rom]

      # If org was provided explicitly (e.g. from guides actions), trust it
      next org if org && orgs.include?(org)

      "hanakai"
    end
  end
end
