# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        NavItem = Data.define(:label, :path, :guide) do
          def self.wrap(obj, guide = nil)
            case obj
            in nil then nil
            in Site::Content::Page then new(obj.title, obj.url_path, guide)
            in Site::Structs::Guide then new(obj.title, obj.url_path, obj)
            end
          end
        end

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

        expose :versions, decorate: false do |org_versions, guide_versions|
          if org_versions.any?
            org_versions
          else
            guide_versions
          end
        end

        expose :path_prefix, decorate: false do |guide, org, org_version|
          if org_version
            "/guides/#{org}"
          else
            "/guides/#{org}/#{guide.slug}"
          end
        end

        expose :latest_version, decorate: false do |versions|
          versions.max
        end

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

        # TODO: Move this and add ancestors to chain
        Breadcrumb = Data.define(:label, :url, :root)
        expose :breadcrumbs do |guide, org:|
          [
            Breadcrumb.new(label: org.capitalize, url: "/guides##{org}", root: true),
            Breadcrumb.new(label: guide.title, url: guide.url_path, root: false)
          ]
        end
      end
    end
  end
end
