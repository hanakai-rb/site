# frozen_string_literal: true

module Site
  module Repos
    # Provides data about the individuals who sponsor Hanakai.
    #
    # Loads its data from `content/sponsors.yml`.
    class SponsorRepo
      SPONSORS_YML_PATH = App.root.join("content/sponsors.yml")

      def individuals
        @individuals ||= named_sponsors + private_sponsors
      end

      private

      def named_sponsors
        dataset.fetch(:sponsors).map { Structs::Sponsor.new(**it) }
      end

      def private_sponsors
        Array.new(dataset.fetch(:private_count)) { Structs::Sponsor.new(private: true) }
      end

      def dataset
        @dataset ||= YAML.load_file(SPONSORS_YML_PATH, symbolize_names: true)
      end
    end
  end
end
