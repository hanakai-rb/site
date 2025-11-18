# frozen_string_literal: true

module Site
  module Views
    module Guides
      class Show < Site::View
        include Deps["repos.guide_repo"]

        NavItem = Data.define(:label, :path) do
          def self.wrap(obj)
            case obj
            in nil then nil
            in Site::Content::Page then new(obj.title, obj.url_path)
            in Site::Structs::Guide then new(obj.title, obj.url_path)
            end
          end
        end

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

        expose :next_nav_item, decorate: false do |guide, path:|
          paths = guide.pages.paths
          current_page_path_index = paths.index(path)
          next_path = paths[current_page_path_index + 1]

          if next_path
            guide.pages[next_path]
          else
            guide_repo.next_guide(guide)
          end.then { NavItem.wrap(it) }
        end

        expose :prev_nav_item, decorate: false do |guide, path:|
          paths = guide.pages.paths
          current_page_path_index = paths.index(path)
          previous_path = (current_page_path_index > 0) ? paths[current_page_path_index - 1] : nil

          if previous_path
            guide.pages[previous_path]
          elsif (previous_guide = guide_repo.previous_guide(guide))
            # get the last page of a previous guide
            last_path = previous_guide.pages.paths[-1]
            previous_guide.pages[last_path]
          end.then { NavItem.wrap(it) }
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
