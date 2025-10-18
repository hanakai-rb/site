# frozen_string_literal: true

module Site
  class Settings < Hanami::Settings
    # Site URL (without trailing slash)
    setting :site_url,
      constructor: Types::String.optional.constructor(->(v) { v.sub(%r{/$}, "") }),
      default: "https://hanamirb.org"
  end
end
