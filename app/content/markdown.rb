# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"
require_relative "pipeline"
require_relative "output_filters"

module Site
  module Content
    # General-purpose Markdown-string renderer, used for ad-hoc content such as
    # code snippets in templates. Full content files go through `Page`/`Post`
    # instead, which add their own node filters.
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
        output_filters: DEFAULT_OUTPUT_FILTERS
      )
      private_constant :Pipeline

      def self.render(str)
        Pipeline.call(str).fetch(:output)
      end
    end
  end
end
