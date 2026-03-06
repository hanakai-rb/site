# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

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

      def headings
        @headings ||= content_data.fetch(:headings).map { Content::Heading.new(**it) }
      end

      def nested_headings
        @nested_headings ||= begin
          root = []

          # Track the most recent heading at each level
          children_at_level = {0 => root}

          headings.each do |heading|
            # Find the closest parent level smaller then our current level
            parent_level = children_at_level.keys.select { it < heading.level }.max || 0

            # Create entry and add to parent's children
            entry = [heading, []]
            children_at_level[parent_level] << entry

            # Track this heading's children for possible new entries
            children_at_level[heading.level] = entry.last

            # Remove all levels deeper than current; they can no longer be parents
            children_at_level.reject! { |k, v| k > heading.level }
          end

          root
        end
      end

      private

      ContentPipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new(
          context: {
            markdown: {
              render: {unsafe: true},
              plugins: {syntax_highlighter: {theme: ""}}
            }
          }
        ),
        node_filters: [
          Content::Filters::SanitizeHeadingAnchorsFilter.new,
          Content::Filters::LinkableHeadingsFilter.new
        ],
        # Don't bother sanitizing content, we already trust what's in this repo.
        sanitization_config: nil
      )
      private_constant :ContentPipeline

      def content_data
        @content_data ||= ContentPipeline.call(content_md)
      end
    end
  end
end
