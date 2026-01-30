# frozen_string_literal: true

module Site
  module Structs
    # This struct represents a Hanakai software project
    class Project < Dry::Struct
      attribute :repo, Types::String

      def label
        @label ||= repo.split("/").last
      end

      def org
        @org ||= case repo.split("/").first
        in "dry-rb"
          :dry
        in "hanami"
          :hanami
        in "rom-rb"
          :rom
        else
          nil
        end
      end

      def github_url
        "https://github.com/#{repo}"
      end

      def issues_badge_url
        "#{github_url}/issues"
      end

      def issues_badge_image_url
        "https://img.shields.io/github/issues/#{repo}.svg"
      end

      def prs_badge_url
        "#{github_url}/pulls"
      end

      def prs_badge_image_url
        "https://img.shields.io/github/issues-pr/#{repo}.svg"
      end

      def version_badge_url
        "https://badge.fury.io/rb/#{label}"
      end

      def version_badge_image_url
        "https://badge.fury.io/rb/#{label}.svg"
      end

      def ci_badge_url
        "https://github.com/#{repo}/actions?query=workflow%3Aci+branch%3Amain"
      end

      def ci_badge_image_url
        "https://github.com/#{repo}/actions/workflows/ci.yml/badge.svg"
      end
    end
  end
end
