# auto_register: false
# frozen_string_literal: true

require_relative "filters/emoji_logo_filter"
require_relative "filters/inline_attribute_list_filter"
require_relative "filters/move_heading_anchors_filter"
require_relative "filters/namespace_constant_filter"

module Site
  module Content
    # Rewrites heading anchor slugs so `&` maps to "and" instead of being
    # dropped (commonmarker's default turns "Principles & Design" into
    # `principles--design`; this makes it `principles-and-design`). Within a
    # heading's HTML, `--` only appears in the anchor's href/id; visible text
    # uses `&amp;`, never literal `--`.
    HEADING_AMPERSAND_FILTER = ->(html) {
      html.gsub(%r{<(h[1-6])\b[^>]*>.*?</\1>}m) do |heading|
        heading.include?("&amp;") ? heading.gsub("--", "-and-") : heading
      end
    }

    # Output filters applied to every rendered Markdown document. Shared so the
    # chain stays consistent across the inline-snippet, page, and blog-post
    # pipelines, which each build their own HTMLPipeline.
    DEFAULT_OUTPUT_FILTERS = [
      Filters::EmojiLogoFilter.new,
      HEADING_AMPERSAND_FILTER,
      Filters::InlineAttributeListFilter.new,
      Filters::MoveHeadingAnchorsFilter.new,
      Filters::NamespaceConstantFilter.new
    ].freeze
  end
end
