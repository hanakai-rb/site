# frozen_string_literal: true

module Site
  module Content
    class Heading < Site::Struct
      attribute :text, Types::Strict::String.constructor(->(str) { str.html_safe })
      attribute :href, Types::Strict::String
      attribute :level, Types::Strict::Integer
    end
  end
end
