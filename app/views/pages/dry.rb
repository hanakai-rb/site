# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Dry < Site::View
        expose :org, decorate: false do
          "dry"
        end
      end
    end
  end
end
