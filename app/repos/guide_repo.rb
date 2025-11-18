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

      def latest_version(org:)
        Content::DEFAULT_GUIDE_VERSIONS.fetch(org)
      end

      def versions_for(org:)
        guides.where(org:).group(:version).order(guides[:version].desc).pluck(:version)
      end

      def latest_by_org
        Content::DEFAULT_GUIDE_VERSIONS.to_h { |org, version|
          [
            org,
            guides.where(org:, version:).order(guides[:position].asc).to_a
          ]
        }
      end

      def versions_by_org
        guides
          .group(:org, :version)
          .order(guides[:version].desc)
          .pluck(:org, :version)
          .each_with_object({}) { |guide, hsh| (hsh[guide[0]] ||= []) << guide[1] }
      end

      def next_guide(guide)
        guides.where(org: guide.org, version: guide.version).where { position > guide.position }.order { position }.limit(1).one
      end

      def previous_guide(guide)
        guides.where(org: guide.org, version: guide.version).where { position < guide.position }.order { position.desc }.limit(1).one
      end
    end
  end
end
