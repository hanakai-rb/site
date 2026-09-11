# frozen_string_literal: true

module Site
  module Views
    module Pages
      class Sponsor < Site::View
        include Deps["repos.sponsor_repo"]

        expose :individual_sponsors do
          sponsor_repo.individuals
        end
      end
    end
  end
end
