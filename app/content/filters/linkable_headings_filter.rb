# auto_register: false
# frozen_string_literal: true

module Site
  module Content
    module Filters
      # Extracts linkable headings (heading tags containing anchors) from the HTML and generates an
      # array of `:headings` in the result hash.
      #
      # Each heading is a hash containing:
      #
      # - `:level` - the heading level (`1` for `"h1", etc.)
      # - `:href` - the link to the heading, to be used in a table of contents
      # - `:text` - the text of the heading
      #
      # Also adds a span within each heading which can be used to position a clickable link next for
      # the heading:
      #
      #   <span aria-hidden="true" class="anchor"></span>
      #
      # Based on `HTMLPipeline::NodeFilter::TableOfContentsFilter`.
      class LinkableHeadingsFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(
          match_element: "h1 a[href], h2 a[href], h3 a[href], h4 a[href], h5 a[href], h6 a[href]",
          match_text_within: "h1, h2, h3, h4, h5, h6"
        )

        def selector = SELECTOR

        def after_initialize
          result[:headings] = []
        end

        def handle_element(element)
          heading_href = element["href"]

          return unless heading_href.start_with?("#")

          heading_id = heading_href[1..]

          element["id"] = heading_id
          element["class"] = "anchor"

          # Add a span that can be used to show a "link" icon next to headings
          element.set_inner_content(anchor_html, as: :html)

          heading_level = Integer(element.ancestors.last.gsub(/[^0-9]/, ""))

          result[:headings] << {level: heading_level, href: heading_href, text: +""}
        end

        def handle_text_chunk(text)
          # Concat text rather than assigning it, since a header may contain multiple text
          # chunks, e.g. a "Keyword arguments (`kwargs`)" markdown header contains 3 text chunks.
          result[:headings].last[:text].concat(text.to_s)
        end

        private

        def anchor_html
          %(<span aria-hidden="true" class="anchor"></span>)
        end
      end
    end
  end
end
