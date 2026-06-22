# auto_register: false
# frozen_string_literal: true

require "nokogiri"

module Site
  module Content
    module Filters
      # Repositions each heading's auto-generated anchor link.
      #
      # The default Markdown processor injects the permalink anchor (`<a class="anchor">`) as the
      # heading’s first child, this anchor includes the `id` that "#slug" links target. This filter
      # makes two adjustments:
      #
      # - Moves the anchor to the end of the heading, so the heading is a plain inline-flow block.
      # - Moves the `id` from the anchor onto the heading, which is the semantically correct
      #   fragment target and ensures screen-readers are properly located
      #
      # Repositioning needs whole-element awareness, so this runs as an output
      # filter rather than a streaming NodeFilter (see InlineAttributeListFilter).
      class MoveHeadingAnchorsFilter
        HEADINGS = "h1, h2, h3, h4, h5, h6"

        def call(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          doc.css(HEADINGS).each do |heading|
            anchor = heading.at_css("a.anchor")
            next unless anchor

            if (id = anchor["id"])
              heading["id"] = id
              anchor.remove_attribute("id")
            end

            # add_child moves an already-attached node, so this re-parents the
            # anchor to the end of the heading.
            heading.add_child(anchor)
          end

          doc.to_html
        end
      end
    end
  end
end
