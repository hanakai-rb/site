# frozen_string_literal: true

module Site
  module Repos
    class TeamMemberRepo < Site::DB::Repo
      def all_for(team:)
        team_members.where(team:).to_a
      end

      def all_ordered
        sort_members(team_members.where(team: "core").to_a) +
          sort_members(team_members.where(team: "maintainers").to_a)
      end

      def find_by_name(name)
        team_members.where(name:).first
      end

      private

      def sort_members(members)
        members.sort_by { |m| [m.active_since || Float::INFINITY, m.name] }
      end
    end
  end
end
