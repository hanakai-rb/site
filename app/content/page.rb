# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"
require_relative "pipeline"
require_relative "filters/inline_attribute_list_filter"

module Site
  module Content
    class Page < Site::Struct
      attribute :url_base, Types::Strict::String
      attribute :url_path, Types::Strict::String
      attribute :front_matter, Types::Strict::Hash.constructor(->(hsh) { hsh.transform_keys(&:to_sym) })
      attribute :content, Types::Strict::String

      def title
        front_matter.fetch(:title)
      end

      def headings
        heading_collection.all
      end

      def nested_headings
        heading_collection.nested
      end

      def content_md
        content
      end

      def content_html
        @content_html ||= content_data.fetch(:output).html_safe
      end

      private

      def heading_collection
        @heading_collection ||= HeadingCollection.new(content_data.fetch(:headings))
      end

      ContentPipeline = Content::Pipeline.new(
        HTMLPipeline.new(
          convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new(
            context: {
              markdown: {
                extension: {alerts: true},
                parse: {smart: true},
                render: {unsafe: true},
                plugins: {syntax_highlighter: {theme: ""}}
              }
            }
          ),
          node_filters: [
            Content::Filters::SanitizeHeadingAnchorsFilter.new,
            Content::Filters::LinkableHeadingsFilter.new,
            Content::Filters::InternalLinksFilter.new,
            Content::Filters::TableWrapperFilter.new
          ],
          # Don't bother sanitizing content, we already trust what's in this repo.
          sanitization_config: nil
        ),
        post_filters: [Filters::InlineAttributeListFilter.new]
      )
      private_constant :ContentPipeline

      def content_data
        @content_data ||= ContentPipeline.call(
          content_md,
          context: {
            internal_links: {
              page: method(:page_path),
              file: method(:page_path),
              guide: method(:guide_path),
              org_guide: method(:org_guide_path),
              doc: method(:doc_path)
            }
          }
        )
      end

      # Transforms "//page/page-slug" into a path within the current guide and version, such as
      # "/learn/hanami/v2.2/current-guide/page-slug".
      def page_path(path)
        url_base + path
      end

      # Transforms "//guide/guide-slug/page-slug" into a path within the current version, such as
      # "/learn/hanami/v2.2/guide-slug/page-slug".
      #
      # To link to the guide's index page, provide a guide slug only.
      def guide_path(path)
        url_base_without_slug = url_base.split("/")[0..-2].join("/")
        url_base_without_slug + path
      end

      # Transforms "//org_guide/org-slug/guide-slug" into a versionless path for the guide within
      # the given org.
      #
      # Visitors to that link will then be redirected to the latest version of the guide.
      def org_guide_path(path)
        "/learn" + path
      end

      # TODO: convert all actual //doc URLs to //guide URLs
      #
      # Transforms //doc/doc-slug/page-slug into a versionless path for the doc.
      #
      # Visitors to that link will then be redirected to the latest version of the doc.
      def doc_path(path)
        "/learn" + path
      end
    end
  end
end
