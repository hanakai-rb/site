# frozen_string_literal: true

module Site
  module Repos
    # This repository provides data about Hanakai software projects
    class ProjectRepo
      PROJECTS_PATH = App.root.join("config/projects.yaml")

      def dry_projects
        dataset[:dry_projects].map { Structs::Project.new(it) }
      end

      def hanami_projects
        dataset[:hanami_projects].map { Structs::Project.new(it) }
      end

      def rom_projects
        dataset[:rom_projects].map { Structs::Project.new(it) }
      end

      private

      def dataset
        @dataset ||= YAML.load_file(PROJECTS_PATH, symbolize_names: true)
      end
    end
  end
end
