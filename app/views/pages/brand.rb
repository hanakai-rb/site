# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Brand < Site::View
        expose :page do
          Content::Page.new(
            url_base: "",
            url_path: "/brand",
            front_matter: {title: "Brand"},
            content: Content::PAGES_PATH.join("brand.md").read
          )
        end
      end
    end
  end
end
