# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"
require_relative "pipeline"
require_relative "filters/emoji_logo_filter"
require_relative "filters/inline_attribute_list_filter"

module Site
  module Content
    module Markdown
      Pipeline = Content::Pipeline.new(
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
          node_filters: [],
          sanitization_config: nil
        ),
        post_filters: [
          Filters::EmojiLogoFilter.new,
          Filters::InlineAttributeListFilter.new
        ]
      )
      private_constant :Pipeline

      def self.render(str)
        Pipeline.call(str).fetch(:output)
      end
    end
  end
end
