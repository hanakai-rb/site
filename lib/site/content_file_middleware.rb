# frozen_string_literal: true

require "digest"

module Site
  # Serves certain static files (such as images) from `content/`
  #
  # Understands our `/guides` and `/docs` URL structure to find the static files for each.
  #
  # This allows for images to be placed alongside their markdown content, to make them easier to
  # reference and manage.
  #
  # For guides, a file requested at /guides/rom/v5.0/getting-started/overview.png will be served
  # from the same file within the guide's content dir.
  #
  # For docs, a file requested at /guides/dry-types/v1.0/overview.png will be served
  # from the same file within the docs's content dir.
  #
  # Sets content-based ETag headers on the returned image.
  class ContentFileMiddleware
    ALLOWED_FILE_EXTENSIONS = %w[png jpg jpeg gif svg].freeze

    PATH_HANDLERS = [
      {
        pattern: %r{^/guides/(?<org>[^/]+)/(?<version>v\d+\.\d+)/(?<path>.+)},
        mapper: ->(m) { "content/guides/#{m[:org]}/#{m[:version]}/#{m[:path]}" }
      },
      {
        pattern: %r{^/docs/(?<slug>[^/]+)/(?<version>v\d+\.\d+)/(?<path>.+)},
        mapper: ->(m) {
          # For docs, we don't currently put the org in the URL, so infer the org from the gem name.
          #
          # We can adjust or remove this later.
          org = m[:slug].split("-").first
          org = "#{org}-rb" unless org == "hanami"

          "content/docs/#{org}/#{m[:slug]}/#{m[:version]}/#{m[:path]}"
        }
      }
    ].freeze

    def initialize(app)
      @app = app
      @file_server = Rack::File.new(Dir.pwd)
    end

    def call(env)
      path_info = env["PATH_INFO"]

      return @app.call(env) unless serve_file?(path_info)

      content_path = map_to_content_path(path_info)
      serve_file(env, content_path) if content_path
    end

    private

    def serve_file?(path)
      file_type_allowed?(path) && path_handler(path)
    end

    def file_type_allowed?(path)
      ALLOWED_FILE_EXTENSIONS.include?(File.extname(path).downcase[1..])
    end

    def path_handler(path)
      PATH_HANDLERS.find { |handler| path.match?(handler[:pattern]) }
    end

    def map_to_content_path(path)
      return unless (handler = path_handler(path))

      handler[:mapper].call(path.match(handler[:pattern]))
    end

    def serve_file(env, content_path)
      return [404, {}, ["Not found"]] unless File.file?(content_path)

      etag = etag(content_path)
      return [304, {"ETag" => etag}, []] if env["HTTP_IF_NONE_MATCH"] == etag

      file_env = env.dup
      file_env["PATH_INFO"] = "/#{content_path}"
      status, headers, body = @file_server.call(file_env)

      if status == 200
        headers["ETag"] = etag
        headers["Cache-Control"] = "public, max-age=31536000, must-revalidate" # 1 year with validation
      end

      [status, headers, body]
    end

    def etag(file_path)
      # Use first 16 characters of SHA256 hash for reasonable ETag length
      Digest::SHA256.file(file_path).hexdigest[0, 16]
    end
  end
end
