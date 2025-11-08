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
    end
  end
end
