# frozen_string_literal: true
# encoding: utf-8

# Ensure UTF-8 encoding for all file operations
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

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
