# frozen_string_literal: true

module Site
  module Views
    module Docs
      class Show < Site::View
        include Deps["repos.doc_repo"]

        expose :doc do |slug:, version:|
          doc_repo.find(slug:, version:)
        end

        # TODO: Make real ord
        expose :org do
          "dry"
        end

        expose :page do |doc, path:|
          doc.pages[path]
        end

        expose :version, decorate: false

        expose :latest_version, decorate: false do |slug:|
          doc_repo.latest_version(slug:)
        end

        expose :other_versions, decorate: false do |slug:|
          doc_repo.versions_for(slug:)
        end

        # TODO: Move this and add ancestors to chain
        Breadcrumb = Data.define(:label, :url, :root)
        expose :breadcrumbs do |doc, org|
          [
            Breadcrumb.new(label: "Docs", url: "/docs", root: true),
            Breadcrumb.new(label: org.capitalize, url: "/docs##{org}", root: false),
            Breadcrumb.new(label: doc.title, url: doc.url_path, root: false)
          ]
        end
      end
    end
  end
end
