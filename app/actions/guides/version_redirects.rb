# frozen_string_literal: true

module Site
  module Actions
    module Guides
      class VersionRedirects < Site::Action
        include Deps["repos.guide_repo"]

        def handle(request, response)
          halt 404 if Hanami.env == :production

          org = request.params[:org]
          org_version = request.params[:org_version]
          default_org_version = Content::DEFAULT_GUIDE_VERSIONS.fetch(org)

          # Redirect to first guide in the org at the appropriate version
          version = org_version || default_org_version
          target = guide_repo.all_for(org:, version:).min_by(&:position)

          response.redirect target.url_path
        end

        private
      end
    end
  end
end
