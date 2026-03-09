# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Rom < Site::View
        expose :theme, layout: true, decorate: false do
          "rom"
        end
      end
    end
  end
end
