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
    expose :header_nav_items, layout: true do |context:|
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

    expose :theme, layout: true, decorate: false do |context:, org: nil, slug: nil|
      orgs = %w[hanami dry rom]

      detected = nil

      # If org was provided explicitly (e.g. from guides actions), trust it
      if org && orgs.include?(org)
        detected = org
      end

      path = context.request.path

      # Infer org from /docs/:slug pattern
      if detected.nil?
        slug ||= path[/\A\/docs\/([^\/]+)/, 1]
        if slug
          if orgs.include?(slug)
            detected = slug
          else
            prefix = slug.split(/[-_]/).first
            detected = prefix if orgs.include?(prefix)
          end
        end
      end

      detected || "hanakai"
    end
  end
end
