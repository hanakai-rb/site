# frozen_string_literal: true

require "yaml"

module Site
  module Content
    module Loaders
      # Loads guides from content/guides/ into the database.
      class Guides
        GuideData = Data.define(:org, :slug, :version, :version_scope, :position, :title, :deprecated, :banner, :banner_type) do
          def initialize(deprecated: false, banner: nil, banner_type: "note", **attrs)
            super
          end
        end

        GUIDES_YML = "guides.yml"
        GUIDES_KEY = :guides
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

            version = version_dir.basename.to_s
            parse_guides_yml(guides_yml).map.with_index do |guide_attrs, position|
              GuideData.new(org:, version:, version_scope: "org", position:, **guide_attrs)
            end
          end
        end

        def load_self_versioned_guides(org_path, org)
          guides_yml = org_path.join(GUIDES_YML)
          return [] unless guides_yml.file?

          parse_guides_yml(guides_yml).flat_map.with_index do |guide_attrs, position|
            guide_path = org_path.join(guide_attrs.fetch(SLUG_KEY))
            next [] unless guide_path.directory?

            guide_version_dirs = guide_path.glob("v*").select(&:directory?)

            if guide_version_dirs.none?
              next [GuideData.new(org:, version: nil, version_scope: "none", position:, **guide_attrs)]
            end

            guide_version_dirs.map do |version_dir|
              version = version_dir.basename.to_s
              GuideData.new(org:, version:, version_scope: "self", position:, **guide_attrs)
            end
          end
        end

        def parse_guides_yml(guides_yml)
          File.read(guides_yml)
            .then { YAML.load(it, symbolize_names: true) }
            .fetch(GUIDES_KEY)
        end
      end
    end
  end
end
