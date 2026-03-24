# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads guides from content/guides/ into the database.
      class Guides
        GuideData = Data.define(:org, :slug, :version, :version_scope, :position, :title, :description, :deprecated, :banner, :banner_type, :unlisted) do
          def initialize(deprecated: false, banner: nil, banner_type: "note", description: nil, unlisted: false, **attrs)
            super
          end
        end

        GUIDES_YML = "guides.yml"
        GUIDE_YML = "guide.yml"
        GUIDES_KEY = :guides
        UNLISTED_KEY = :unlisted
        SLUG_KEY = :slug

        include Deps[relation: "relations.guides"]

        def call(root: GUIDES_PATH)
          root.glob("*").select(&:directory?)
            .flat_map { |org_path| load_guides_for_org(org_path) }
            .each { |guide| relation.insert(**guide.to_h) }
        end

        private

        def load_guides_for_org(org_path)
          org = org_path.basename.to_s
          org_version_dirs = org_path.glob("v*").select(&:directory?)

          if org_version_dirs.any?
            load_org_versioned_guides(org_version_dirs, org)
          else
            load_self_versioned_guides(org_path, org)
          end
        end

        def load_org_versioned_guides(org_version_dirs, org)
          org_version_dirs.flat_map do |version_dir|
            guides_yml = version_dir.join(GUIDES_YML)
            next [] unless guides_yml.file?

            org_guides_attrs = read_yaml(guides_yml)
            version = version_dir.basename.to_s
            unlisted = org_guides_attrs[UNLISTED_KEY] || false

            org_guides_attrs.fetch(GUIDES_KEY).filter_map.with_index do |guide_attrs, position|
              guide_path = version_dir.join(guide_attrs.fetch(SLUG_KEY))
              next unless guide_path.directory?

              GuideData.new(
                org:,
                version:,
                version_scope: "org",
                position:,
                unlisted:,
                **guide_attrs
              )
            end
          end
        end

        def load_self_versioned_guides(org_path, org)
          guides_yml = org_path.join(GUIDES_YML)
          return [] unless guides_yml.file?

          read_yaml(guides_yml).fetch(GUIDES_KEY).flat_map.with_index do |guide_attrs, position|
            guide_path = org_path.join(guide_attrs.fetch(SLUG_KEY))
            next [] unless guide_path.directory?

            guide_version_dirs = guide_path.glob("v*").select(&:directory?)

            if guide_version_dirs.none?
              next [
                GuideData.new(
                  org:,
                  version: nil,
                  version_scope: "none",
                  position:,
                  **guide_attrs
                )
              ]
            end

            guide_version_dirs.map do |version_dir|
              version = version_dir.basename.to_s

              version_guide_yml = version_dir.join(GUIDE_YML)
              version_guide_attrs = version_guide_yml.file? ? read_yaml(version_guide_yml) : {}
              unlisted = version_guide_attrs[UNLISTED_KEY] || false

              GuideData.new(
                org:,
                version:,
                version_scope: "self",
                position:,
                unlisted:,
                **guide_attrs
              )
            end
          end
        end

        def read_yaml(path)
          File.read(path).then { YAML.load(it, symbolize_names: true) }
        end
      end
    end
  end
end
