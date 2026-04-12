# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Community < Site::View
        include Deps["repos.team_member_repo"]

        expose :team_members do
          team_member_repo.all_ordered
        end
      end
    end
  end
end
