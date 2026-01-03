# frozen_string_literal: true

module Site
  module Structs
    # This struct represents a Hanakai software project
    class Project < Dry::Struct
      attribute :repo, Types::String
      attribute :show_doc_coverage, Types::Bool.default(true)
      attribute :show_ci, Types::Bool.default(true)

      alias_method :show_doc_coverage?, :show_doc_coverage
      alias_method :show_ci?, :show_ci

      def label
        @label ||= repo.split("/").last
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

      def docs_coverage_badge_url
        "https://inch-ci.org/github/#{repo}.svg"
      end

      def docs_coverage_badge_image_url
        "https://inch-ci.org/github/#{repo}.svg"
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
