# auto_register: false
# frozen_string_literal: true

module Site
  module Content
    # Wraps HTMLPipeline to support `post_filters`: callables applied to the
    # HTML output string after the main pipeline runs. This is necessary for
    # filters that require full-DOM sibling awareness (e.g. InlineAttributeListFilter),
    # which can't be expressed as streaming NodeFilters.
    #
    # Exposes the same `call` interface as HTMLPipeline so it can be used as a
    # drop-in replacement.
    class Pipeline
      def initialize(html_pipeline, post_filters: [])
        @html_pipeline = html_pipeline
        @post_filters = post_filters
      end

      def call(text, context: {}, result: {})
        data = @html_pipeline.call(text, context: context, result: result)
        @post_filters.each do |filter|
          data[:output] = filter.call(data.fetch(:output).to_s)
        end
        data
      end
    end
  end
end
