# auto_register: false
# frozen_string_literal: true

require "html_pipeline"

module Site
  module Content
    module Filters
      # Wraps each `<table>` element in a `<div class="table">` container.
      #
      # This allows CSS to constrain or scroll tables without adding classes to the generated
      # Markdown HTML directly.
      class TableWrapperFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(match_element: "table")

        def selector = SELECTOR

        def handle_element(element)
          element.before('<div class="table-wrapper" data-defo-overflow-class=\'{"x":true,"overflowXClass":"table-wrapper--overflow-x scrolling-panel"}\'>', as: :html)
          element.after("</div>", as: :html)
        end
      end
    end
  end
end
