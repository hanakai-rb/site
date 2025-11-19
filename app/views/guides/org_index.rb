# frozen_string_literal: true

module Site
  module Views
    module Guides
      class OrgIndex < Site::View
        include Deps["repos.guide_repo"]

        expose :guides do |org:, version:|
          guide_repo.all_for(org:, version:)
        end

        expose :org_versions, decorate: false do |org:|
          guide_repo.org_versions(org:)
        end

        expose :org_slug, decorate: false do |org:|
          org
        end

        expose :version, decorate: false
      end
    end
  end
end
