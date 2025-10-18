# frozen_string_literal: true

module Site
  module Views
    module Docs
      class Index < Site::View
        include Deps["repos.doc_repo"]

        expose :docs do
          doc_repo.latest_by_org
        end

        expose :versions do
          doc_repo.all.group_by(&:org).transform_values do |org_docs|
            org_docs.group_by(&:slug).transform_values do |slug_docs|
              slug_docs.map(&:version).sort.reverse
            end
          end
        end
      end
    end
  end
end
