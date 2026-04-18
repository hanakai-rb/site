# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"
require_relative "../content/pipeline"
require_relative "../content/filters/inline_attribute_list_filter"

module Site
  module Structs
    class Post < Site::DB::Struct
      def url_path
        "/blog/#{permalink}"
      end

      def content_md
        content
      end

      def content_html
        @content_html ||= content_data.fetch(:output).html_safe
      end

      def excerpt
        self[:excerpt] || "TODO"
      end

      def show_toc?
        self[:show_toc]
      end

      def headings
        heading_collection.all
      end

      def nested_headings
        heading_collection.nested
      end

      private

      def heading_collection
        @heading_collection ||= Content::HeadingCollection.new(content_data.fetch(:headings))
      end

      ContentPipeline = Content::Pipeline.new(
        HTMLPipeline.new(
          convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new(
            context: {
              markdown: {
                parse: {smart: true},
                render: {unsafe: true},
                plugins: {syntax_highlighter: {theme: ""}}
              }
            }
          ),
          node_filters: [
            Content::Filters::SanitizeHeadingAnchorsFilter.new,
            Content::Filters::LinkableHeadingsFilter.new,
            Content::Filters::TableWrapperFilter.new,
            Content::Filters::PreWrapperFilter.new
          ],
          # Don't bother sanitizing content, we already trust what's in this repo.
          sanitization_config: nil
        ),
        post_filters: [Content::Filters::InlineAttributeListFilter.new]
      )
      private_constant :ContentPipeline

      def content_data
        @content_data ||= ContentPipeline.call(content_md)
      end
    end
  end
end
