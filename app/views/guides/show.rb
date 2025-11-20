# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        expose :org, decorate: false

        expose :org_version, decorate: false

        expose :version, decorate: false do |org_version: nil, guide_version: nil|
          org_version || guide_version
        end

        expose :guide do |version, org:, slug:|
          guide_repo.find(org:, version:, slug:)
        end

        expose :page do |guide, path:|
          guide.pages[path]
        end

        expose :org_guides do |org:, org_version: nil, guide_version: nil|
          if org_version
            guide_repo.all_for(org:, version: org_version)
          else
            guide_repo.latest_for(org:)
          end
        end

        expose :org_versions, decorate: false do |org:|
          guide_repo.org_versions(org:)
        end

        expose :guide_versions, decorate: false do |org:, slug:|
          guide_repo.guide_versions(org:, slug:)
        end

        expose :latest_version, decorate: false do |org_versions, guide_versions|
          (org_versions + guide_versions).max
        end

        # TODO: Move this and add ancestors to chain
        Breadcrumb = Data.define(:label, :url, :root)
        expose :breadcrumbs do |guide, org:|
          [
            Breadcrumb.new(label: "Guides", url: "/guides", root: true),
            Breadcrumb.new(label: org.capitalize, url: "/guides##{org}", root: false),
            Breadcrumb.new(label: guide.title, url: guide.url_path, root: false)
          ]
        end
      end
    end
  end
end
