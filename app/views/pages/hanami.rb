# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Hanami < Site::View
        expose :org, decorate: false do
          "hanami"
        end
      end
    end
  end
end
