# frozen_string_literal: true

module Site
  module Views
    module Parts
      class Guide < Views::Part
        def banner_content
          Commonmarker.to_html(banner).html_safe
        end
      end
    end
  end
end
