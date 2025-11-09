# frozen_string_literal: true

module Site
  module Views
    module Parts
      class Post < Views::Part
        def published_date
          published_at.strftime("%B %d, %Y")
        end

        def published_datetime
          published_at&.iso8601
        end
      end
    end
  end
end
