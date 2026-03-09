# auto_register: false
# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

module Site
  module Content
    module Markdown
      Pipeline = HTMLPipeline.new(
        convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new(
          context: {
            markdown: {
              render: {unsafe: true},
              plugins: {syntax_highlighter: {theme: ""}}
            }
          }
        ),
        node_filters: [],
        sanitization_config: nil
      )
      private_constant :Pipeline

      def self.render(str)
        Pipeline.call(str).fetch(:output)
      end
    end
  end
end
