# frozen_string_literal: true

require "front_matter_parser"

module Site
  module Content
    class PageCollection
      attr_reader :root
      attr_reader :base_url_path

      def initialize(root:, base_url_path:)
        @root = root
        @base_url_path = base_url_path

        @pages = {}
      end

      def paths
        @paths ||= index_page.front_matter
          .fetch(PAGES_FRONTMATTER_KEY, [])
          .then { flatten_paths(it) }
          .then { it.prepend(INDEX_PAGE_PATH) }
      end

      def keys = paths

      def nested_paths
        @paths_hash ||= index_page.front_matter
          .fetch(PAGES_FRONTMATTER_KEY, [])
          .map { hashify_path(it) }
          .then { it.prepend(INDEX_PAGE_PATH => {}) }
      end

      def [](path)
        @pages.fetch(path) { @pages[path] = build_page(path) }
      end

      def each(&)
        return to_enum(:each) unless block_given?

        to_a.each(&)
      end

      # def to_a
      #   paths.map { self[it] }
      # end

      def to_a
        nested_paths.to_a
      end

      private

      def build_page(path)
        file_path = root.join(path)

        begin
          parsed_file = FrontMatterParser::Parser.parse_file("#{file_path}.md")
        rescue Errno::ENOENT
          raise Content::NotFoundError, file_path
        end

        Content::Page.new(
          url_base: base_url_path,
          url_path: (path == INDEX_PAGE_PATH) ? base_url_path : File.join(base_url_path, path),
          front_matter: parsed_file.front_matter,
          content: parsed_file.content
        )
      end

      def flatten_paths(paths, prefix = nil)
        paths.each_with_object([]) { |path, memo|
          if path.is_a?(String)
            memo.push([prefix, path].compact.join("/"))
          elsif path.is_a?(Hash) && path.length == 1
            memo.push(path.keys.first)
            memo.concat(flatten_paths(path.values.first, path.keys.first))
          else
            raise "Unsupported path format #{paths.inspect}"
          end
        }
      end

      def hashify_path(path, prefix = nil)
        if path.is_a?(Hash) && path.length == 1
          path.transform_values { hashify_path(it, path.keys.first) }
        elsif path.is_a?(Array)
          path.map { hashify_path(it, prefix) }
        elsif path.is_a?(String)
          {[prefix, path].compact.join("/") => {}}
        else
          raise "Invalid path #{path}"
        end
      end

      def index_page
        self[INDEX_PAGE_PATH]
      end
    end
  end
end
