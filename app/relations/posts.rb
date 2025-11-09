# frozen_string_literal: true

module Site
  module Relations
    class Posts < Hanami::DB::Relation
      schema :posts do
        attribute :permalink, Types::Nominal::String
        attribute :title, Types::Nominal::String
        attribute :published_at, Types::Nominal::Time.optional
        attribute :author, Types::Nominal::String
        attribute :org, Types::Nominal::String.optional
        attribute :excerpt, Types::Nominal::String.optional
        attribute :content, Types::Nominal::String

        indexes do
          index :permalink, name: :unique_permalink, unique: true
        end
      end

      use :pagination
      per_page 10

      def published
        where { !published_at.is(nil) }
          .where { published_at < Time.now }
      end
    end
  end
end
