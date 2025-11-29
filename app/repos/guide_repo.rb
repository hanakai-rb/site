# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def all
        guides.to_a
      end

      def all_for(org:, version:)
        guides.where(org:, version:).to_a
      end

      # Returns the latest version of each guide for an org without an org-level version.
      #
      # This finds all guides within the org, picking the latest version for each self-versioned
      # guide.
      def latest_for(org:)
        self_versioned_dataset = guides.dataset
          .with(:latest_versions, latest_version_query)
          .join(:latest_versions, slug: :slug, version: :version)
          .where(org:, version_scope: "self")

        self_versioned = guides.new(self_versioned_dataset).to_a

        unversioned = guides.where(org:, version_scope: "none").to_a

        (self_versioned + unversioned).sort_by(&:position)
      end

      def with_latest_version(org:, slug:)
        guides
          .where(org:, slug:)
          .where { version.not nil }
          .order { guides[:version].desc }
          .limit(1).one
      end

      def org_versions(org:)
        guides
          .where(org:, version_scope: "org")
          .group(:version)
          .order(guides[:version].desc)
          .pluck(:version)
      end

      def guide_versions(org:, slug:)
        guides
          .where(org:, slug:, version_scope: "self")
          .group(:version)
          .order(guides[:version].desc)
          .pluck(:version)
      end

      def latest_by_org
        Content::DEFAULT_GUIDE_VERSIONS.to_h { |org, version|
          org_guides =
            if version.nil?
              latest_for(org:)
            else
              guides.where(org:, version:).order(guides[:position].asc).to_a
            end

          [org, org_guides]
        }
      end

      def versions_by_org
        guides
          .where(version_scope: "org")
          .group(:org, :version)
          .order(guides[:version].desc)
          .pluck(:org, :version)
          .each_with_object({}) { |guide, hsh| (hsh[guide[0]] ||= []) << guide[1] }
      end

      def next_guide(guide)
        next_prev_guide_base_query(guide)
          .where { position > guide.position }
          .order { position }
          .limit(1)
          .one
      end

      def previous_guide(guide)
        next_prev_guide_base_query(guide)
          .where { position < guide.position }
          .order { position.desc }
          .limit(1)
          .one
      end

      private

      def next_prev_guide_base_query(guide)
        if guide.version_scope == "org"
          guides.where(org: guide.org, version: guide.version)
        else
          guides.dataset
            .with(:latest_versions, latest_version_query)
            .join(:latest_versions, slug: :slug, version: :version)
            .where(org: guide.org)
            .then { guides.new(it) }
        end
      end

      def latest_version_query
        guides.dataset
          .select(:slug)
          .select_append { max(version).as(:version) }
          .group(guides[:slug])
      end
    end
  end
end
