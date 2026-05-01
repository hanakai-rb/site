# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Colophon < Site::View
        expose :page do
          Content::Page.new(
            url_base: "",
            url_path: "/colophon",
            front_matter: {title: "Colophon"},
            content: Content::PAGES_PATH.join("colophon.md").read
          )
        end
      end
    end
  end
end
