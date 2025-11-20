# frozen_string_literal: true

module Site
  module Actions
    module Guides
      class Show < Site::Action
        INDEX_PAGE_PATH = Content::INDEX_PAGE_PATH

        include Deps["repos.guide_repo"]

        def handle(request, response)
          # Return 404 when index name is explicitly given, since we use this for the guide's root.
          halt 404 if request.params[:path] == INDEX_PAGE_PATH

          # If no version is given, redirect to the latest
          if (redirect = guide_redirect_url(request.params))
            response.redirect_to redirect
          end

          # When no path is given, we're at the guide's root. Here we can set the path to index to
          # render the guide's index page.
          params = request.params.to_h
          params[:path] ||= INDEX_PAGE_PATH

          response.render(view, **params)
        rescue Content::NotFoundError => e
          raise Action::NotFoundError, "#{e.path} not found"
        end

        private

        def guide_redirect_url(params)
          return if Hanami.env == :production

          version = params[:org_version] || params[:guide_version]
          return unless version.nil?

          guide = guide_repo.with_latest_version(org: params[:org], slug: params[:slug])
          return unless guide

          redirect_url = guide.url_path
          redirect_url += "/#{params[:path]}" unless params[:path].to_s.empty?

          redirect_url
        end
      end
    end
  end
end
