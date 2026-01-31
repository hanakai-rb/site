# frozen_string_literal: true

module Site
  module Views
    module Status
      class Index < Site::View
        include Deps["repos.project_repo"]

        expose(:dry_projects) { project_repo.dry_projects }
        expose(:hanami_projects) { project_repo.hanami_projects }
        expose(:rom_projects) { project_repo.rom_projects }
      end
    end
  end
end
