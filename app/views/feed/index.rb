# frozen_string_literal: true

module Site
  module Views
    module Feed
      class Index < Site::View
        include Deps["settings", "repos.post_repo"]

        config.default_format = :xml
        config.layout = false

        decorate :posts do
          post_repo.latest(page: 1)
        end

        expose :site_url do
          settings.site_url
        end
      end
    end
  end
end
