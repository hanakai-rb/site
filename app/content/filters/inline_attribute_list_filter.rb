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
            match = ANNOTATION.match(node.text.strip)
            next unless match

            class_names = match[1].split(".").select { _1.match?(VALID_CLASS) }
            prev = node.previous_element

            if prev && class_names.any?
              existing = prev["class"].to_s.split
              prev["class"] = (existing + class_names).join(" ")
            end

            node.remove
          end

          doc.to_html
        end
      end
    end
  end
end
