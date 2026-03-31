# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Conduct < Site::View
        expose :page do
          Content::Page.new(
            url_base: "",
            url_path: "/conduct",
            front_matter: {title: "Contributor Covenant Code of Conduct"},
            content: Content::PAGES_PATH.join("conduct.md").read
          )
        end
      end
    end
  end
end
