# frozen_string_literal: true

module Site
  module Views
    module Blog
      class Show < Site::View
        include Deps["repos.post_repo", "repos.team_member_repo"]

        expose :post do |permalink:|
          post_repo.get(permalink)
        end

        expose :author_team_member do |post|
          team_member_repo.find_by_name(post.author) if post.author
        end

        expose :org, decorate: false do |post|
          post.org
        end
      end
    end
  end
end
