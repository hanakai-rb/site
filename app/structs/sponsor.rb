# frozen_string_literal: true

module Site
  module Structs
    # An individual sponsor of Hanakai.
    class Sponsor < Site::Struct
      attribute? :source, Types::String
      attribute? :name, Types::String
      attribute? :handle, Types::String
      attribute? :profile_url, Types::String
      attribute? :avatar_url, Types::String
      attribute? :private, Types::Bool

      def private?
        attributes.fetch(:private, false)
      end
    end
  end
end
