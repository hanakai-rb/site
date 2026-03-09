# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Rom < Site::View
        expose :org, decorate: false do
          "rom"
        end
      end
    end
  end
end
