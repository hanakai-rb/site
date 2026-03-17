# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    module Helpers
      def org_name(org_slug)
        case org_slug
        when "hanami" then "Hanami"
        when "dry" then "Dry"
        when "rom" then "Rom"
        else
          raise ArgumentError, "unknown org slug '#{org_slug}'"
        end
      end

      def blog_page_path(page)
        "/blog/page/#{page}"
      end

      def learn_path(org_slug, version)
        "/learn/#{org_slug}/#{version}"
      end
    end
  end
end
