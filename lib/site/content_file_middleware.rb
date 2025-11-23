# frozen_string_literal: true

require "digest"

module Site
  # Serves certain static files (such as images) from `content/`
  #
  # Understands our `/learn` and `/blog` URL structure to find the static files for each.
  #
  # This allows for images to be placed alongside their markdown content, to make them easier to
  # reference and manage.
  #
  # For guides, a file requested at /learn/rom/v5.0/getting-started/overview.png will be served
  # from the same file within the guide's content dir.
  #
  # For docs, a file requested at /learn/dry-types/v1.0/overview.png will be served
  # from the same file within the docs's content dir.
  #
  # For posts, a file requested at /blog/2025/06/07/field-trip/photo.jpeg will be served
  # from the file at `posts/2025/2025-06-07-field-trip/photo.jpeg` within the content dir.`
  #
  # Sets content-based ETag headers on the returned image.
  class ContentFileMiddleware
    ALLOWED_FILE_EXTENSIONS = %w[png jpg jpeg gif svg].freeze

    Source = Data.define(:directory, :pattern, :to_url)

    SOURCES = [
      Source.new(
        directory: "content/guides",
        pattern: %r{^/(?<org>[^/]+)/(?<version>v\d+\.\d+)/(?<path>.+)},
        to_url: ->(m) { "/learn/#{m[:org]}/#{m[:version]}/#{m[:path]}" }
      ),
      Source.new(
        directory: "content/posts/assets",
        pattern: %r{^/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})-(?<slug>[^/]+)/(?<path>.+)},
        to_url: ->(m) { "/blog/assets/#{m[:year]}-#{m[:month]}-#{m[:day]}-#{m[:slug]}/#{m[:path]}" }
      )
    ]

    def initialize(app)
      @app = app
      @file_server = Rack::Files.new(Dir.pwd)
      @assets = {}
    end

    def call(env)
      path_info = env["PATH_INFO"]

      return @app.call(env) unless file_type_allowed?(path_info)

      hydrate_if_needed

      return @app.call(env) unless serve_file?(path_info)

      content_path = map_to_content_path(path_info)
      serve_file(env, content_path) if content_path
    end

    def paths_map
      hydrate_if_needed
      @assets.invert
    end

    private

    def hydrate_if_needed
      return unless @assets.empty?

      SOURCES.each do |source|
        Dir.glob(File.join(source.directory, "**/*.{#{ALLOWED_FILE_EXTENSIONS.join(",")}}")).each do |file|
          path = file.sub(source.directory, "")
          if (match = path.match(source.pattern))
            url = source.to_url.call(match)
            @assets[url] = File.join(source.directory, path)
          end
        end
      end
    end

    def serve_file?(path)
      @assets.key?(path.to_s)
    end

    def file_type_allowed?(path)
      ALLOWED_FILE_EXTENSIONS.include?(File.extname(path).downcase[1..])
    end

    def map_to_content_path(path)
      @assets[path.to_s]
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
