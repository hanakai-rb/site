# auto_register: false
# frozen_string_literal: true

module Site
  module Views
    class Context < Hanami::View::Context
      include Deps[_settings: "settings"]

      def site_url
        _settings.site_url
      end
    end
  end
end
