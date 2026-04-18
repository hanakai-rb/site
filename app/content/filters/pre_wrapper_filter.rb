# auto_register: false
# frozen_string_literal: true

require "html_pipeline"

module Site
  module Content
    module Filters
      # Wraps each `<pre>` element in a `<div class="pre-wrapper">` container and prepends a
      # `<button>` so JS can attach behaviour (e.g. copy to clipboard) without mutating the DOM
      # at runtime.
      class PreWrapperFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(match_element: "pre")

        # Kept in sync with app/templates/svgs/icons/_copy.html.erb and _check.html.erb — inlined
        # because node filters can't invoke Hanami view partials.
        COPY_ICON = <<~SVG.gsub(/\s+/, " ").strip
          <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" class="pre-wrapper__icon pre-wrapper__icon--copy" height="16" viewBox="0 0 256 256" width="16">
            <path d="M172,164a12,12,0,0,1-12,12H96a12,12,0,0,1,0-24h64A12,12,0,0,1,172,164Zm-12-52H96a12,12,0,0,0,0,24h64a12,12,0,0,0,0-24Zm60-64V216a20,20,0,0,1-20,20H56a20,20,0,0,1-20-20V48A20,20,0,0,1,56,28H90.53a51.88,51.88,0,0,1,74.94,0H200A20,20,0,0,1,220,48ZM100.29,60h55.42a28,28,0,0,0-55.42,0ZM196,52H178.59A52.13,52.13,0,0,1,180,64v8a12,12,0,0,1-12,12H88A12,12,0,0,1,76,72V64a52.13,52.13,0,0,1,1.41-12H60V212H196Z"></path>
          </svg>
        SVG

        # viewBox expanded and recentred so the check renders at the same visual width as the
        # copy icon (whose content fills ~200/256 of its viewBox). The check path itself is
        # naturally flatter than the copy so heights won't match exactly.
        CHECK_ICON = <<~SVG.gsub(/\s+/, " ").strip
          <svg xmlns="http://www.w3.org/2000/svg" aria-hidden="true" class="pre-wrapper__icon pre-wrapper__icon--check" height="16" viewBox="-13 0 276 276" width="16">
            <path d="M232.49,80.49l-128,128a12,12,0,0,1-17,0l-56-56a12,12,0,1,1,17-17L96,183,215.51,63.51a12,12,0,0,1,17,17Z"></path>
          </svg>
        SVG

        BUTTON = %(<div class="pre-wrapper" data-defo-copy-code><button type="button" class="pre-wrapper__button" aria-label="Copy">#{COPY_ICON}#{CHECK_ICON}</button>)

        def selector = SELECTOR

        def handle_element(element)
          element.before(BUTTON, as: :html)
          element.after("</div>", as: :html)
        end
      end
    end
  end
end
