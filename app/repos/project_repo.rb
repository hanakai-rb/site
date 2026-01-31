# frozen_string_literal: true

module Site
  module Repos
    # This repository provides data about Hanakai software projects
    class ProjectRepo
      PROJECTS_PATH = App.root.join("content/projects.yaml")

      def dry_projects
        dataset.select { it.org == :dry }
      end

      def hanami_projects
        dataset.select { it.org == :hanami }
      end

      def rom_projects
        dataset.select { it.org == :rom }
      end

      private

      def dataset
        @dataset ||= YAML.load_file(PROJECTS_PATH, symbolize_names: true).map { Structs::Project.new(repo: it) }
      end
    end
  end
end
