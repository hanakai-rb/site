# auto_register: false
# frozen_string_literal: true

require "fastimage"
require "html_pipeline"

module Site
  module Content
    module Filters
      # Adds intrinsic `width` and `height` attributes to `<img>` tags by
      # reading the image file from disk. Lets the browser reserve layout space
      # before the image bytes arrive, eliminating cumulative layout shift.
      #
      # Resolves the image src using either:
      #   - `<img src="//file/foo.png">` against `:source_dir` (the directory
      #     containing the markdown file). Used by guides, where this filter
      #     must run *before* InternalLinksFilter so the `//file/` URL is intact.
      #   - any other URL via `:image_paths`, a Hash mapping URL -> on-disk
      #     path. Used by posts, which reference images via absolute URLs that
      #     are already in their final form.
      #
      # Images that already have both attributes, external URLs, and
      # unresolvable paths are left untouched.
      class ImageDimensionsFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(match_element: "img")

        FILE_HOST = "file"

        def selector = SELECTOR

        def handle_element(element)
          return if element["width"] && element["height"]

          path = resolve_path(element["src"])
          return unless path && File.file?(path)

          width, height = FastImage.size(path)
          return unless width && height

          element["width"] = width.to_s
          element["height"] = height.to_s
        end

        private

        def resolve_path(src)
          return unless src

          uri = URI.parse(src)

          if uri.scheme.nil? && uri.host == FILE_HOST
            source_dir = context[:source_dir]
            return unless source_dir
            File.join(source_dir.to_s, uri.path)
          else
            context[:image_paths]&.[](src)
          end
        rescue URI::InvalidURIError
          nil
        end
      end
    end
  end
end
