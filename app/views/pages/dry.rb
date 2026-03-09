# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Dry < Site::View
        expose :theme, layout: true, decorate: false do
          "dry"
        end
      end
    end
  end
end
