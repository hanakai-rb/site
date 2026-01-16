# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Index < Site::View
        include Deps["repos.guide_repo"]

        expose :guides do
          guide_repo.latest_by_org
        end

        private_expose :versions do
          guide_repo.versions_by_org
        end

        expose :hanami_version_links, decorate: false do |versions|
          versions.fetch("hanami", []).to_h do |version|
            first_guide = guide_repo.all_for(org: "hanami", version: version).min_by(&:position)
            url = first_guide ? first_guide.url_path : "/learn/hanami/#{version}"
            [version, url]
          end
        end

        expose :rom_version_links, decorate: false do |versions|
          versions.fetch("rom", []).to_h do |version|
            first_guide = guide_repo.all_for(org: "rom", version: version).min_by(&:position)
            url = first_guide ? first_guide.url_path : "/learn/rom/#{version}"
            [version, url]
          end
        end
      end
    end
  end
end
