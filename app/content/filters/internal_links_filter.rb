# auto_register: false
# frozen_string_literal: true

require "html_pipeline"

module Site
  module Content
    module Filters
      # Replaces internal links with the format "//link_type/some/extra/path".
      #
      # Expects an `:internal_links` hash to be provided in the context, with a transformation proc
      # for each link type. Based on the above example, the following context should be provided:
      #
      # ```
      # context: {
      #   internal_links: {
      #     link_type: ->(path) {
      #       # transform the path here
      #     }
      #   }
      # }
      # ```
      class InternalLinksFilter < HTMLPipeline::NodeFilter
        SELECTOR = Selma::Selector.new(match_element: "a, img")

        def selector = SELECTOR

        def after_initialize
          result[:internal_links] ||= {}
        end

        def handle_element(element)
          if element.tag_name == "a"
            return unless element["href"]
            element["href"] = rewrite_url(element["href"])
          elsif element.tag_name == "img"
            return unless element["src"]
            # binding.irb
            element["src"] = rewrite_url(element["src"])
          end
        end

        private

        def rewrite_url(url)
          begin
            uri = URI.parse(url)
          rescue
            return url
          end
          return url unless uri.scheme.nil? && !uri.host.to_s.empty?

          replacement_proc = internal_links[uri.host.to_sym]
          return url unless replacement_proc

          fragment = uri.fragment ? "#" + uri.fragment : ""
          replacement_proc&.call(uri.path + fragment)
        end

        def internal_links = context[:internal_links]
      end
    end
  end
end
