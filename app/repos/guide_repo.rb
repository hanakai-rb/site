# frozen_string_literal: true

module Site
  module Repos
    class GuideRepo < Site::DB::Repo
      def find(org:, version:, slug:)
        guides.where(org:, version:, slug:).one!
      end

      def all_for(org:, version:)
        guides.where(org:, version:).to_a
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
    end
  end
end
