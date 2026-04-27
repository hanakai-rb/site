# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    module Scopes
      # Scope for rendering the top nav in the layout. Includes nav item details so they do not need
      # to be repeated across desktop and mobile versions of the nav markup.
      class TopNav < Site::Views::Scope
        Item = Data.define(:label, :url)
        Logo = Data.define(:width, :height)
        Project = Data.define(:slug, :description, :desktop_logo, :mobile_logo)

        NAV_ITEMS = [
          Item.new("Learn", "/learn"),
          Item.new("Blog", "/blog"),
          Item.new("Community", "/community"),
          Item.new("Sponsor", "/sponsor")
        ].freeze

        NAV_PROJECTS = [
          Project.new("hanami", "Complete framework for building apps", Logo.new(41, 40), Logo.new(36, 35)),
          Project.new("dry", "Validation, types, functional patterns and more", Logo.new(40, 40), Logo.new(35, 35)),
          Project.new("rom", "Powerful and flexible persistence toolkit", Logo.new(36, 40), Logo.new(31, 35))
        ].freeze

        def nav_items = NAV_ITEMS

        def nav_projects = NAV_PROJECTS

        def current_page?(url)
          path = request.path
          path == url || path.start_with?(url + "/")
        end
      end
    end
  end
end
