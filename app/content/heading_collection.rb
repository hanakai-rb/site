# frozen_string_literal: true

module Site
  module Content
    class HeadingCollection
      def initialize(raw_headings)
        @raw_headings = raw_headings
      end

      def all
        @all ||= @raw_headings.map { Heading.new(**it) }
      end

      # Returns an array of nested headings, each being a 2-element array, containing the parent
      # header and an array of its children.
      #
      # For example:
      #
      # [
      #   [#<Heading level: 1>, [
      #     [#<Heading level: 2>, [
      #       [#<Heading level: 3>, []]
      #     ]]
      #   ]],
      #   [#<Heading level: 1>, [
      #     [#<Heading level: 3>, []]
      #   ]],
      #   [#<Heading level: 1>, []]
      # ]
      def nested
        @nested ||= begin
          root = []

          # Track the most recent heading at each level
          children_at_level = {0 => root}

          all.each do |heading|
            # Find the closest parent level smaller then our current level
            parent_level = children_at_level.keys.select { it < heading.level }.max || 0

            # Create entry and add to parent's children
            entry = [heading, []]
            children_at_level[parent_level] << entry

            # Track this heading's children for possible new entries
            children_at_level[heading.level] = entry.last

            # Remove all levels deeper than current; they can no longer be parents
            children_at_level.reject! { |k, v| k > heading.level }
          end

          root
        end
      end
    end
  end
end
