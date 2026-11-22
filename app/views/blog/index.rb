# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Index < Site::View
        include Deps["repos.post_repo"]

        decorate :posts do |page:|
          post_repo.latest(page:, per_page:)
        end

        expose :per_page
        expose :page

        private

        def per_page = 10
      end
    end
  end
end
