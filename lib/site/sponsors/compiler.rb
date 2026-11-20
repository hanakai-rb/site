# frozen_string_literal: true

module Site
  module Sponsors
    # Merges the listings from both platforms into the single list that the site renders.
    #
    # Someone who sponsors on both platforms is listed once for each.
    class Compiler
      Result = Data.define(:sponsors, :private_count, :warnings)

      def initialize(config)
        @config = config
      end

      def call(github:, open_collective:)
        excluded, kept = (github.sponsors + open_collective.sponsors)
          .partition { @config.excluded?(it.fetch("handle")) }

        Result.new(
          sponsors: sort(kept + @config.extra),
          private_count: github.private_count + open_collective.private_count,
          warnings: excluded.map { "Excluded #{it.fetch("source")} sponsor #{it.fetch("handle")} (listed in `exclude`)" }
        )
      end

      private

      def sort(sponsors)
        sponsors.sort_by { [it.fetch("name").downcase, it["handle"].to_s] }
      end
    end
  end
end
