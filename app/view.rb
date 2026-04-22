# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "json"

# For .xml.builder templates
require "builder"

module Site
  class View < Hanami::View
    include Deps["settings", og_image_manifest: "og_images.manifest"]

    # Used in the app layout
    expose :settings, decorate: false

    expose :og_image_url, layout: true, decorate: false do |context:|
      entry = og_image_manifest.for_url(context.request.path) || og_image_manifest.default_entry
      "#{settings.site_url}#{entry.url_path}"
    end

    expose :canonical_page_url, layout: true, decorate: false do |context:|
      "#{settings.site_url}#{context.request.path}"
    end

    NavItem = Data.define(:label, :url, :selected, :children)
    expose :header_nav_items, layout: true do |context:|
      path = context.request.path
      [
        NavItem.new(label: "Projects", url: "/projects", selected: path.start_with?("/projects"), children: [
          NavItem.new(label: "Hanami", url: "/projects/hanami", selected: path.start_with?("/projects/hanami"), children: []),
          NavItem.new(label: "Dry", url: "/projects/dry", selected: path.start_with?("/projects/dry"), children: []),
          NavItem.new(label: "Rom", url: "/projects/rom", selected: path.start_with?("/projects/rom"), children: [])
        ]),
        NavItem.new(label: "Learn", url: "/learn", selected: path.start_with?("/learn"), children: []),
        NavItem.new(label: "Blog", url: "/blog", selected: path.start_with?("/blog"), children: []),
        NavItem.new(label: "Community", url: "/community", selected: path.start_with?("/community"), children: []),
        NavItem.new(label: "Sponsor", url: "/sponsor", selected: path == "/sponsor", children: [])
      ]
    end

    expose :footer_nav_items, layout: true do |context:|
      path = context.request.path
      [
        NavItem.new(label: "Projects", url: nil, selected: false, children: [
          NavItem.new(label: "Hanami", url: "/projects/hanami", selected: path.start_with?("/projects/hanami"), children: []),
          NavItem.new(label: "Dry", url: "/projects/dry", selected: path.start_with?("/projects/dry"), children: []),
          NavItem.new(label: "Rom", url: "/projects/rom", selected: path.start_with?("/projects/rom"), children: [])
        ]),
        NavItem.new(label: "Learn", url: "/learn", selected: path.start_with?("/learn"), children: [
          NavItem.new(label: "Hanami", url: "/learn#hanami", selected: false, children: []),
          NavItem.new(label: "Dry", url: "/learn#dry", selected: false, children: []),
          NavItem.new(label: "Rom", url: "/learn#rom", selected: false, children: [])
        ]),
        NavItem.new(label: "Community", url: "/community", selected: path.start_with?("/community"), children: [
          NavItem.new(label: "Code repos", url: "https://github.com/hanakai-rb", selected: false, children: []),
          NavItem.new(label: "Discussion forum", url: "https://discourse.hanamirb.org/", selected: false, children: []),
          NavItem.new(label: "Chat room", url: "https://discord.gg/KFCxDmk3JQ", selected: false, children: []),
          NavItem.new(label: "AI policy", url: "/ai-policy", selected: false, children: [])
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
