# frozen_string_literal: true

module Site
  module Relations
    class Guides < Hanami::DB::Relation
      schema :guides do
        attribute :org, Types::Nominal::String
        attribute :slug, Types::Nominal::String
        attribute :title, Types::Nominal::String
        attribute :position, Types::Nominal::Integer
        attribute :version, Types::Nominal::String.optional
        attribute :version_scope, Types::Nominal::String
        attribute :deprecated, Types::Nominal::Bool
      end
    end
  end
end
