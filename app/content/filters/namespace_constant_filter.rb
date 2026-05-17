# auto_register: false
# frozen_string_literal: true

module Site
  module Content
    module Filters
      # Restores constant highlighting for namespaced constants invoked with
      # arguments, e.g. `Dry::Core::Equalizer(:latitude)`.
      #
      # The syntax highlighter parses the trailing constant as a method call and
      # leaves it unscoped, so it renders in the plain text colour while the
      # surrounding namespace segments (`Dry`, `Core`) are highlighted as
      # constants. This filter wraps any bare constant directly following a `::`
      # scope-resolution operator in the same span the other segments receive.
      #
      # Used as an output filter via Content::Pipeline's `output_filters:` option.
      class NamespaceConstantFilter
        ACCESSOR = %r{<span class="[^"]*\baccessor\b[^"]*">::</span>}
        NAMESPACED_CONSTANT = /(#{ACCESSOR})([A-Z][A-Za-z0-9_]*)/o

        def call(html)
          html.gsub(NAMESPACED_CONSTANT) do
            %(#{$1}<span class="support class ruby">#{$2}</span>)
          end
        end
      end
    end
  end
end
