# frozen_string_literal: true

module Site
  module Views
    module Pages
      class AIPolicy < Site::View
        expose :page do
          Content::Page.new(
            url_base: "",
            url_path: "/ai-policy",
            front_matter: {title: "AI contribution policy"},
            content: Content::PAGES_PATH.join("ai_policy.md").read
          )
        end
      end
    end
  end
end
