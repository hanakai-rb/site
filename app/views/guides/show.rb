# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        # Main guide exposures

        expose :org, decorate: false

        expose :guide do |version, org:, slug:|
          guide_repo.get(org:, version:, slug:)
        end

        expose :page do |guide, path:|
          guide.pages[path]
        end

        expose :path_prefix, decorate: false do |guide, org, org_version: nil|
          if org_version
            "/learn/#{org}"
          else
            "/learn/#{org}/#{guide.slug}"
          end
        end

        # Other guides

        expose :org_guides do |guide, org:, org_version: nil, guide_version: nil|
          if org_version
            guide_repo.all_for(org:, version: org_version)
          elsif guide_version
            guide_repo.latest_for(org:).tap { |guides|
              # Ensure the currently selected guide (which may have an older version) is the one
              # that appears in the guides list.
              guides[guide.position] = guide
            }
          else
            guide_repo.latest_for(org:)
          end
        end

        # Versioning

        expose :version, decorate: false do |org_version: nil, guide_version: nil|
          org_version || guide_version
        end

        expose :latest_version, decorate: false do |versions|
          versions.max
        end

        private_expose :versions, decorate: false do |org:, slug:|
          org_versions = guide_repo.org_versions(org:)
          next org_versions if org_versions.any?

          guide_repo.guide_versions(org:, slug:)
        end

        # Exposes a hash of version links for the currently selected guide page.
        #
        # Use the same guide and page in the other versions, if such a guide and page exists.
        # Otherwise links to either:
        #
        # 1. The root of the guide (if the guide exists but not the page), or
        # 2. The first guide (if the guide does not exist).
        #
        # @example
        #   {
        #     "v2.3" => "/learn/hanami/v2.3/database/migrations",
        #     # ...
        #     "v2.0" => "/learn/hanami/v2.0/getting-started"
        #   }
        expose :version_links, decorate: false do |versions, org:, slug:, path:|
          versions.to_h do |other_version|
            other_guide = guide_repo.find_by(org:, version: other_version, slug:)

            # This guide exists for the other verison. Link to the same page at that version (if it
            # exists), or the root of the guide.
            if other_guide
              url =
                if other_guide.pages.paths.include?(path)
                  other_guide.pages[path].url_path
                else
                  other_guide.url_path
                end

              next [other_version, url]
            end

            # This guide does not exist for the other version. Link to the first guide for that
            # version as a fallback.
            version_guides = guide_repo.all_for(org:, version: other_version)
            [other_version, version_guides.min_by(&:position).url_path]
          end
        end

        # Navigation

        expose :next_nav_item, decorate: false do |guide, path:|
          paths = guide.pages.paths
          current_page_path_index = paths.index(path)
          next_path = paths[current_page_path_index + 1]

          if next_path
            NavItem.wrap(guide.pages[next_path], guide)
          else
            next_guide = guide_repo.next_guide(guide)
            NavItem.wrap(next_guide)
          end
        end

        expose :prev_nav_item, decorate: false do |guide, path:|
          paths = guide.pages.paths
          current_page_path_index = paths.index(path)
          previous_path = (current_page_path_index > 0) ? paths[current_page_path_index - 1] : nil

          if previous_path
            NavItem.wrap(guide.pages[previous_path], guide)
          elsif (previous_guide = guide_repo.previous_guide(guide))
            # get the last page of a previous guide
            last_path = previous_guide.pages.paths[-1]
            NavItem.wrap(previous_guide.pages[last_path], previous_guide)
          end
        end

        NavItem = Data.define(:label, :path, :guide) do
          def self.wrap(obj, guide = nil)
            case obj
            in nil then nil
            in Site::Content::Page then new(obj.title, obj.url_path, guide)
            in Site::Structs::Guide then new(obj.title, obj.url_path, obj)
            end
          end
        end

        # TODO: Move this and add ancestors to chain
        Breadcrumb = Data.define(:label, :url, :root)
        expose :breadcrumbs do |guide, org:|
          [
            Breadcrumb.new(label: org.capitalize, url: "/learn##{org}", root: true),
            Breadcrumb.new(label: guide.title, url: guide.url_path, root: false)
          ]
        end
      end
    end
  end
end
