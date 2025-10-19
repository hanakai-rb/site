# frozen_string_literal: true

require "hanami"
require "rack/rewrite"

module Site
  class App < Hanami::App
    require "site/content_file_middleware"
    config.middleware.use ContentFileMiddleware
    config.middleware.use Rack::Rewrite do
      r302 %r{^/(.+)/$}, "/$1"
    end

    config.actions.content_security_policy[:script_src] += " 'unsafe-inline'"
    config.actions.content_security_policy[:connect_src] += " https://*.algolia.net https://*.algolianet.com https://*.algolia.io"

    environment :production do
      # We set HANAMI_ENV to production in bin/static-build, but we don't want the noisy default of
      # logging to stdout.
      config.logger.stream = File::NULL if ENV["SITE_STATIC_BUILD"]
    end

    class << self
      def prepare
        super
        load_content
        self
      end

      private def load_content
        # Start the db provider, which will auto-migrate the tables (see config/providers/db.rb)
        start :db

        # Load content into the database
        self["content.loaders.gems_docs"].call
        self["content.loaders.guides"].call
        self["content.loaders.posts"].call
        self["content.loaders.team_members"].call
      end
    end
  end
end
