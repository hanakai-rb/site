# frozen_string_literal: true

module Site
  module Relations
    class Guides < Hanami::DB::Relation
      schema :guides do
        attribute :org, Types::Nominal::String
        attribute :slug, Types::Nominal::String
        attribute :title, Types::Nominal::String
        attribute :description, Types::Nominal::String.optional
        attribute :position, Types::Nominal::Integer
        attribute :version, Types::Nominal::String.optional
        attribute :version_scope, Types::Nominal::String
        attribute :deprecated, Types::Nominal::Bool
        attribute :banner, Types::Nominal::String.optional
        attribute :banner_type, Types::Nominal::String.optional
        attribute :unlisted, Types::Nominal::Bool
      end

      def listed = where(unlisted: false)
    end
  end
end
