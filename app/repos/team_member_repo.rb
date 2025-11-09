# frozen_string_literal: true

module Site
  module Repos
    class TeamMemberRepo < Site::DB::Repo
      def all_for(team:)
        team_members.where(team:).to_a
      end

      def find_by_name(name)
        team_members.where(name:).first
      end
    end
  end
end
