# auto_register: false
# frozen_string_literal: true

require "nokogiri"

module Site
  module Content
    module Filters
      module InlineAttributeListFilter
        ANNOTATION = /\A\{:\.([-\w]+(?:\.[-\w]+)*)\}\z/
        VALID_CLASS = /\A[a-zA-Z][a-zA-Z0-9_-]*\z/

        def self.call(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          doc.css("p").each do |node|
            text = node.text.strip
            match = ANNOTATION.match(text)
            next unless match

            # Must be only an annotation with no other content
            next unless node.children.all?(&:text?)

            class_names = match[1].split(".").select { _1.match?(VALID_CLASS) }
            next unless class_names.any?

            prev = node.previous_element
            next unless prev

            existing = prev["class"].to_s.split
            prev["class"] = (existing + class_names).join(" ")

            # Remove the whitespace text node between the two elements, if any
            between = node.previous_sibling
            between.remove if between&.text? && between.content.strip.empty?

            node.remove
          end

          doc.to_html
        end
      end
    end
  end
end
