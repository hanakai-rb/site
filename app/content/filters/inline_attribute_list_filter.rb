# auto_register: false
# frozen_string_literal: true

require "nokogiri"

module Site
  module Content
    module Filters
      module InlineAttributeListFilter
        ANNOTATION_PREFIX = /\A\{:\.([-\w]+(?:\.[-\w]+)*)\}\s*/
        VALID_CLASS = /\A[a-zA-Z][a-zA-Z0-9_-]*\z/

        def self.call(html)
          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          doc.css("p").each do |node|
            first_child = node.children.first
            next unless first_child&.text?

            match = ANNOTATION_PREFIX.match(first_child.content)
            next unless match

            class_names = match[1].split(".").select { _1.match?(VALID_CLASS) }
            next unless class_names.any?

            existing = node["class"].to_s.split
            node["class"] = (existing + class_names).join(" ")
            first_child.content = first_child.content.delete_prefix(match[0])
          end

          doc.to_html
        end
      end
    end
  end
end
