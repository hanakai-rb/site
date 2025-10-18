# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        expose :guide do |org:, version:, slug:|
          guide_repo.find(org:, version:, slug:)
        end

        expose :page do |guide, path:|
          guide.pages[path]
        end

        expose :org, decorate: false

        expose :version, decorate: false

        expose :latest_version, decorate: false do |org:|
          guide_repo.latest_version(org:)
        end

        expose :other_versions, decorate: false do |org:|
          guide_repo.versions_for(org:)
        end

        expose :org_guides do |org:, version:|
          guide_repo.all_for(org:, version:)
        end

        # TODO: Move this and add ancestors to chain
        Breadcrumb = Data.define(:label, :url)
        expose :breadcrumbs do |guide, org:|
          [
            Breadcrumb.new(label: org.capitalize, url: "/guides##{org}"),
            Breadcrumb.new(label: guide.title, url: guide.url_path)
          ]
        end
      end
    end
  end
end
