# auto_register: false
# frozen_string_literal: true

require_relative "filters/emoji_logo_filter"
require_relative "filters/inline_attribute_list_filter"
require_relative "filters/namespace_constant_filter"

module Site
  module Content
    # Output filters applied to every rendered Markdown document. Shared so the
    # chain stays consistent across the inline-snippet, page, and blog-post
    # pipelines, which each build their own HTMLPipeline.
    DEFAULT_OUTPUT_FILTERS = [
      Filters::EmojiLogoFilter.new,
      Filters::InlineAttributeListFilter.new,
      Filters::NamespaceConstantFilter.new
    ].freeze
  end
end
